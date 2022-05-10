#!/usr/bin/env perl

use strict;
use warnings;

my $statFile = "";


if ($ARGV[0]) {
   $statFile = $ARGV[0];
} else {
   print "Usage: $0 statFile\n";
   exit 1;
}

my $start = rindex($statFile, '/') + 1 ;
my $end = rindex($statFile, '.csv');
my $filename = substr($statFile, $start , $end - $start);

my $last = "";
open(my $fh, '<:encoding(UTF-8)', $statFile)
  or die "Could not open file '$statFile' $!";
my $first = <$fh>;

while( my $line = <$fh> ) { 
	$last = $line ;
	# print "last $last";
}
close $fh;
chomp($first);
chomp($last);

my @metrics = split(',',$first);
my @metricsValues = split(',',$last);

#skip timestamp
my $counter = 1;
open(OUT, '>', "/tmp/".$filename.".prom") or die $!;
while ($counter < $#metrics) {
  my $metr = $metrics[$counter];
  my $metrVal = $metricsValues[$counter];
  $metr =~ s/^\s+|\s+$//g;
  $metr =~ s/'//g;
  $metr =~ s/-/_/g;
  if ($metrVal eq "") {$metrVal = 0};
  print OUT $filename."_".$metr." ".$metrVal."\n";
  $counter++;
}
close OUT