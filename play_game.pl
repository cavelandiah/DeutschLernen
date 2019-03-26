#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
#use Unicode::Normalize;
use Encode qw(encode decode);

my $enc = 'utf-8';

open my $ARTIKLE, "< $ARGV[0]"; #/Users/cristianarleyvelandiahuerto/Desktop/PracticeGerman/words.list";

my (%dict,%complete,%complete2);

while (my $in =<$ARTIKLE>){
    chomp $in;
    my @all = split /\s+|\t/, $in;
    $all[1] =~ s/\,//g;
    $dict{$all[1]}{$all[0]}{$all[2]} = 1;
    $complete{$all[1]} = "$all[0] $all[1] $all[2]";
    $complete2{"$all[0] $all[1] $all[2]"} = "$all[0] $all[1] $all[2]";
}

my $question = "Hallo!\t Which is the right german article for this word?\n";
print encode($enc, $question);
&game(\%dict, \%complete, \%complete2);

######SUBS
sub game {
    my $all = shift;
    my $complet = shift;
    my $complet2 = shift;
    my $pointsGood = 0;
    my $pointsBad = 0;
    foreach my $word (keys %{ $all }){
        print encode($enc, $word);
        print "\n";
        my $response = <STDIN>;
        chomp $response;
        if(exists $all->{$word}{$response}){
            print encode($enc, $complet->{$word});
            print "\n";
            $pointsGood++;
        } else {
            print "No! the answer is:\n";
            print encode($enc, $complet->{$word});
            print "\n";
REPEAT:            
            $pointsBad++;
            print "Please write it again:\n";
            my $answer = <STDIN>;
            chomp $answer;
            $answer = decode($enc, $answer);
            if(exists $complet2->{$answer}){
                next;
            } else {
                goto REPEAT;
            }
        }
    }
    print "#####Score###\n";
    print "Today you have:\nRight=$pointsGood\nFail=$pointsBad\n";
    my $total = $pointsGood + $pointsBad;
    my $percentage = ($pointsGood/$total) * 100;
    print "Your score is about $percentage\% of the total articles!\n";
}

