#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use PDF::API2;
use File::Spec;
use File::Basename;

unless (@ARGV) {
  die "USAGE: carton exec -- perl ./$0 [--alternately|--left|--right] [file ...]\n";
}

my ($alternately, $left, $right);
GetOptions('alternately' => \$alternately, 'left' => \$left, 'right' => \$right);

die "Please set filename you want to change!\n" unless @ARGV;
die "Please set [--alternately|--left|--right]\n" unless $alternately || $left || $right;

print "Rotate: ".($alternately ? "alternately" : $left ? "left" : $right ? "right" : "")."\n";

my @files;
if (@ARGV == 1) {
  my $file = shift(@ARGV);
  if (index($file, '*') >= 0) {
    @files = <$file>;
  }
  else {
    @files = $file;
  }
}
else {
  @files = @ARGV;
}
print "Target Files : @files\n";

for my $file (@files) {
  my $file_abs_path = File::Spec->rel2abs($file);
  my $newfile = File::Spec->catfile(dirname($file_abs_path), "converted_".basename($file_abs_path));
  print "========================================================\n";
  print "File Name           : $file\n";
  print "Converted File Name : $newfile\n";

  my $pdf = PDF::API2->open($file);

  for my $page_number (1..$pdf->pages) {
    if ($alternately) {
      $pdf->openpage($page_number)
        ->rotate($page_number % 2 ? 270 : 90);
    }
    elsif ($left) {
      $pdf->openpage($page_number)->rotate(270);
    }
    elsif ($right) {
      $pdf->openpage($page_number)->rotate(90);
    }
  }

  $pdf->saveas($newfile);
}
