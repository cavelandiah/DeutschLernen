#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Unicode::Normalize;
use Encode qw(encode decode);

my $enc = 'utf-8';

open my $ARTIKLE, "< $ARGV[0]"; #/Users/cristianarleyvelandiahuerto/Desktop/PracticeGerman/words.list";
#lieben liebt   hat_geliebt
my (%dict,%complete,%complete2, %present3, %perfect);

while (my $in =<$ARTIKLE>){
    chomp $in;
    my @all = split /\s+|\t/, $in;
    #$all[1] =~ s/\,//g;
    #$all[0] = decode($enc, $all[0]);
    #$all[1] = decode($enc, $all[1]);
    #$all[2] = decode($enc, $all[2]);
    $dict{$all[0]}{$all[1]}{$all[2]} = 1;
    $complete{$all[0]} = "$all[0] $all[1] $all[2]";
    $complete2{"$all[0] $all[1] $all[2]"} = "$all[0] $all[1] $all[2]";
    $present3{"$all[0]"} = "$all[1]";
    $perfect{"$all[0] $all[1]"} = "$all[2]";
}

my $question = "Hallo! How do you write the pärtizipt II of this verb?\n";
print encode($enc, $question);
&game(\%dict, \%complete, \%complete2, \%present3, \%perfect);

######SUBS
sub game {
    my $all = shift;
    my $complet = shift;
    my $complet2 = shift;
    my $pres = shift;
    my $perf = shift;
    my $pointsGood = 0;
    my $pointsBad = 0;
    foreach my $word (keys %{ $all }){
        #$word = decode($enc, $word);
        print "$word\n";
        my $response = <STDIN>;
        chomp $response;
        $response = decode($enc, $response);
        if(exists $all->{$word}{$response}){
            print "Now, write the Perfek form:\n";
            #print encode($enc, $word);
            print "$word";
            print " ";
            print decode($enc, $pres->{$word});
            print " ";
            $pointsGood++;
            my $past = <STDIN>;
            chomp $past;
            $past = decode($enc, $past);
            if(exists $all->{$word}{$response}{$past}){
                print "######\t";
                print "$complet->{$word}";
                #print "\t";
                #print encode($enc, $all->{$word}{$past});
                print "\t######\n";
                $pointsGood++;
            } else {
                print "The Perfect is wrong! The answer is:\n";
                print "$complet->{$word}";
                #print encode($enc, $complet->{$word});
                print "\n";
REP2:                
                $pointsBad++;
                print "Please write it again:\n";
                my $answer2 = <STDIN>;
                chomp $answer2;
                #$answer2 = decode($enc, $answer2);
                if(exists $complet2->{$answer2}){
                    next;
                } else {
                    goto REP2;
                }
            }
        } else {
            print "No! the answer is:\n";
            print "$word ";
            print decode($enc, $pres->{$word});
            print "\n";
REPEAT:            
            $pointsBad++;
            print "Please write it again:\n";
            my $answer = <STDIN>;
            chomp $answer;
            $answer = decode($enc, $answer);
            if(exists $perf->{$answer}){
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
    print "Your score is about $percentage\% of the total verbs!\n";
}

