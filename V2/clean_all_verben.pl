#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

open my $IN, "< alle_verben.temp" or die;

while(<$IN>){
	chomp;
	my @all = split /\,/, $_;
	print "$all[0]\t$all[3]\t$all[6]\t$all[-1]\_$all[-5]\n";	
}
close $IN;
