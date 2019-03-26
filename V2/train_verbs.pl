#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Unicode::Normalize;
use Encode qw(encode decode);
use Term::ANSIColor qw(:constants);

my $enc = 'utf-8';
my $pointsGood = 0;
my $pointsBad = 0;

open my $VERB, "< ./practice.txt" or die "Please provide the verbs file: verbs_test.list\n";
#Infinitiv      Präsens Präteritum      Perfeckt        Spanish
#beginnen        beginnt begann  hat_begonnen    empezar
my (%dict,%complete,%complete2, %present3, %prateritum, %perfect, %meaning);
my (%prase, %prate, %perfe, %trans);
my (%prase1, %prate1, %perfe1, %trans1);
while (my $in =<$VERB>){
    chomp $in;
    next if $in =~ /^\#/;
    my @all = split /\s+|\t/, $in;
    $dict{$all[0]}{$all[1]}{$all[2]}{$all[3]}{$all[4]} = 1;
    $complete{$all[0]} = "$all[0] $all[1] $all[2] $all[3] $all[4]";
    $complete2{"$all[0] $all[1] $all[2] $all[3] $all[4]"} = "$all[0] $all[1] $all[2] $all[3] $all[4]";
    $present3{"$all[0]"} = "$all[1]";
    $prateritum{"$all[0] $all[1]"} = "$all[2]";
    $perfect{"$all[0] $all[1] $all[2]"} = "$all[3]";
    $meaning{"$all[0] $all[1] $all[2] $all[3]"} = "$all[4]";
    #######
    $prase{$all[0]}{$all[1]} = 1; #beginnen -> beginnt
    $prate{$all[0]}{$all[2]} = 1; #beginnen -> begann
    $perfe{$all[0]}{$all[3]} = 1; #beginnen -> hat_begonnen
    $trans{$all[0]}{$all[4]} = 1; #beginnen -> empezar
    ######
    $prase1{$all[0]} = $all[1]; #beginnen -> beginnt
    $prate1{$all[0]} = $all[2]; #beginnen -> begann
    $perfe1{$all[0]} = $all[3]; #beginnen -> hat_begonnen
    $trans1{$all[0]} = $all[4]; #beginnen -> empezar
}

my $question = "Welcome! Let's start to play with some german verbs!\n";
print BOLD, RED ON_BLACK, "#############", RESET;
print "\n";
print BOLD, MAGENTA ON_BLACK, $question, RESET;
print BOLD, RED ON_BLACK, "#############", RESET;
print "\n";
&game(\%dict, \%complete, \%complete2, \%present3, \%prateritum, \%perfect, %meaning);

close $VERB;

######SUBS

sub test { #answer, hash_to_test, msj
    my $answer = shift;
    my $mode = shift; #1 = präsens, 2= präteritum, 3=Perfeck, 4=Meaning
    my $main = shift;
    if ($mode == 1){ #1 = präsens
	    $answer = encode($enc, $answer);
        if (exists $prase{$main}{$answer}){
            my $ans = $prase1{$main};
	    &correct($main, $ans);
        } else {
            my $ans = $prase1{$main};
            &incorrect($main, $ans);
        }
    } elsif ($mode == 2){ # 2= präteritum
        if (exists $prate{$main}{$answer}){
             my $ans = $prate1{$main};
	     &correct($main, $ans);
        } else {
            my $ans = $prate1{$main};
            &incorrect($main, $ans);
        } 
    } elsif ($mode == 3){ # 3=Perfeck 
        if (exists $perfe{$main}{$answer}){
            my $ans = $perfe1{$main};
	    &correct($main, $ans);
        } else {
            my $ans = $perfe1{$main};
            &incorrect($main, $ans);
        } 
    } elsif ($mode == 4){ # 4=Meaning
        if (exists $trans{$main}{$answer}){
            my $ans = $trans1{$main};
	    &correct($main, $ans);
        } else {
            my $ans = $trans1{$main};
            &incorrect($main, $ans);
        } 
    }
}

sub correct {
    my $word = shift;
    my $answerT = shift;
    print "$word -> $answerT"; #Highlight!
    print "\n";
    #print decode($enc, $pres{$word});
    #print " ";
    $pointsGood++;
}

sub incorrect {
    my $word = shift;
    my $answerTrue = shift;
    print "No! the answer is:\n";
    print "$word -> $answerTrue\n";
    #print decode($enc, $answerTrue);
    print "\n";
    $pointsBad++;
    &repeat($word, $answerTrue);
}    

sub repeat {
    my $word = shift;
    my $true = shift;
REPEAT:
    print "Please write it again:\n";
    print "$word:\n$true\n";
    my $answer = <STDIN>;  
    chomp $answer;
    $answer = decode($enc, $answer);   
    $true = decode($enc, $true);
    if("$answer" eq "$true"){                                                            
	; #next;
    } else {        
        goto REPEAT;
    }
}

sub score {
    system("clear");
    print RED ON_BLACK, "#####Score###", RESET;
    print "\n";
    print GREEN ON_BLACK, "Today you have:", RESET;
    print "\n";
    print GREEN ON_BLACK, "Right=$pointsGood", RESET;
    print "\n";
    print GREEN ON_BLACK, "Fail=$pointsBad", RESET;
    print "\n";
    my $total = $pointsGood + $pointsBad;
    my $percentage = ($pointsGood/$total) * 100;
    print GREEN ON_BLACK, "Your score is about $percentage\% of the total verbs!", RESET;
    print "\n";
    print RED ON_BLACK, "##########", RESET;
    print "\n";
}

sub game {
    my $all = shift;
    my $complet = shift;
    my $complet2 = shift;
    my $pres = shift;
    my $prat = shift;
    my $perf = shift;
    my $meaning = shift;
    	foreach my $word (keys %{ $all }){ #Iterate in all verbs
        print BOLD, GREEN ON_BLACK , $word, "\n", RESET;
        print BLACK ON_WHITE, "Please, write the Präsens form:\n", RESET;
        my $response = <STDIN>;
        chomp $response;
        $response = decode($enc, $response);
        &test($response, 1, $word);
	system("clear");
	print BLACK ON_WHITE, "Please, write the Präteritum form:\n", RESET;
	$response = <STDIN>;
        chomp $response;
        $response = decode($enc, $response);
	&test($response, 2, $word);
	system("clear");
	print BLACK ON_WHITE, "Please, write the Perfekt form:\n", RESET;
	$response = <STDIN>;
        chomp $response;
        $response = decode($enc, $response);
	&test($response, 3, $word);
	system("clear");
	print BLACK ON_WHITE, "Please, write the meaning:\n", RESET;
	$response = <STDIN>;
        chomp $response;
        $response = decode($enc, $response);
	&test($response, 4, $word);
	}
	&score()
}
