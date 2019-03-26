#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
#use Unicode::Normalize;
use Encode qw(encode decode);
use Term::ANSIColor qw(:constants);

my $enc = 'utf-8';
my $pointsGood = 0;
my $pointsBad = 0;
my $total = 0;
my $OUT;

open my $ARTIKLE, "< Data/converted_database_test" or die "Please provide the database!\n"; #/Users/cristianarleyvelandiahuerto/Desktop/PracticeGerman/words.list";
my $game_option = $ARGV[0] or die "Please, select the game:\nChoose 1 for article number or 2 for article write\n";
my $name = $ARGV[1];
my $limit = 20; #Define the number of scores to test
my (%dict,%complete,%complete2);

while (my $in =<$ARTIKLE>){
    chomp $in;
    my @all = split /\s+|\t/, $in, 4;
    my $score = $all[-1]; my @test = split /\s+|\t/, $score; $score = $test[-1];
    pop @test; my $modified = join " ", @test;
    push @{ $dict{$score}{$all[0]}{$all[1]}{$all[2]} }, $modified;
}
my $question = "Hallo! Which is the right german article for this noun?";
print BLACK ON_WHITE, encode($enc, $question), RESET;
print "\n";
&choose_game($game_option);
close $ARTIKLE;


######SUBS

sub choose_game {
    my $selection = shift;
    if ($selection == 1){
        &game_article_write(%dict);
    } elsif ($selection == 2){
        &game_article_number(%dict)
    }
}

sub game_article_write { #Give a score depending your answers on a limited number of words.
    my %all = @_;
    foreach my $scores ((sort { $b <=> $a } keys %all)[0..$limit]){
        #my $articles = $all{$scores};
        foreach my $art (keys %{ $all{$scores} }){
            my $color = &define_color($art);
            foreach my $singular (keys %{ $all{$scores}{$art} }){
                foreach my $plural (keys %{ $all{$scores}{$art}{$singular} }){
                    my $meaning = $all{$scores}{$art}{$singular}{$plural};
                    my $complete;
                    foreach my $all (@{$meaning}){
                        $complete .= "/$all";
                    }
                    my $worte = decode($enc, "$singular / $plural");
                    print WHITE ON_BLACK, encode($enc, $worte), RESET;
                    print "\t";
                    print BLUE ON_YELLOW, $complete, RESET;
                    print "\n";
                    $total++;
                    my $response = <STDIN>; #or die "Please, write der, die or das!\n"; 
                    chomp $response;
                    $response = decode($enc, $response);
                    if(exists $all{$scores}{$response}{$singular}){
                        &print_example($worte, $complete, $color);
                        $pointsGood++;
                        system("clear");
                    } else {
                        print "No! the answer is:\n";
                        &print_example($worte, $complete, $color);
REPEAT:
                        $pointsBad++;
                        print "Please write it again:\n";
                        my $answer = <STDIN>;
                        chomp $answer;
                        $answer = decode($enc, $answer);
                        if(exists $all{$scores}{$answer}{$singular}){
                            &print_example($worte, $complete, $color);
                            system("clear");
                            next;
                        } else {
                            #system("clear");
                            goto REPEAT;
                        }
                    }
                }
            }
        }
    }
    my $val = 1;
    &print_final_score($val);
}

sub game_article_number { 
    my %all = @_;
    foreach my $scores (sort { $b <=> $a } keys %all){ #Answer as much as you can! Get the best record!
        foreach my $art (keys %{ $all{$scores} }){
            my $color = &define_color($art);
            foreach my $singular (keys %{ $all{$scores}{$art} }){
                foreach my $plural (keys %{ $all{$scores}{$art}{$singular} }){
                    my $meaning = $all{$scores}{$art}{$singular}{$plural};
                    my $complete;
                    foreach my $all (@{$meaning}){
                        $complete .= "/$all";
                    }
                    my $worte = decode($enc, "$singular / $plural");
                    print WHITE ON_BLACK, encode($enc, $worte), RESET;
                    print "\t";
                    print BLUE ON_YELLOW, $complete, RESET;
                    print "\n";
                    $total++;
                    my $response = <STDIN>; #or die "Please, write der, die or das!\n"; 
                    chomp $response;
                    $response = decode($enc, $response);
                    if(exists $all{$scores}{$response}{$singular}){
                        &print_example($worte, $complete, $color);
                        $pointsGood++;
                        system("clear");
                        next;
                    } else {
                        &print_example($worte, $complete, $color);
                        #system("clear");
                        goto FIN;
                    }
                }
            }
        }
    }
FIN:    
    my $val = 2;
    &print_final_score($val);
}


sub print_example {
   my ($wort, $complet, $color) = @_;
   print $color, encode($enc, $wort), RESET;
   print "\t";
   print BLUE ON_YELLOW, $complet, RESET;
   print "\n";
}

sub define_color {
    my $artic = shift;
    my $color;
    if($artic eq "die"){
        $color = WHITE ON_RED;
    } elsif ($artic eq "das"){
        $color = WHITE ON_GREEN;
    } elsif ($artic eq "der"){
        $color = WHITE ON_BLUE;
    } else {
        $color = BLACK;
    }
    return $color;
}

sub print_final_score {
    my $mode = shift;
    if($mode == 1){
        print "#####Score###\n";
        print "Today you have:\nRight=$pointsGood\nFail=$pointsBad\n";
        #my $total = $pointsGood + $pointsBad;
        my $percentage = ($pointsGood/$total) * 100;
        print "Your score is about $percentage\% of the total articles!\n";
        print "#############\n\n";
    } elsif ($mode == 2){
        print "#####Score###\n";
        print "Today you have:\n$pointsGood of $total right\n";
        my $percentage = ($pointsGood/$total) * 100;
        print "Your score is about $percentage\% of the total articles!\n";
        open $OUT, "> .scores_german_temp" or die "Sorry, I could not create a record! you are not authorized!";
        my $datestring = localtime();
        print $OUT "$percentage\t$pointsGood\t$total\t$datestring\t$name\n";
        &new_record($pointsGood);
        print "#############\n\n";
    }
}

sub new_record{
    my $test = shift;
    if (!-e ".scores_german") {
        system("mv .scores_german_temp .scores_german");
        print "First record saved!\n#############\n\n";
    } else {
    open my $INN, "< .scores_german" or die "First record saved!\n#############\n\n";
    while (<$INN>){
        chomp;
        my @all1 = split /\t|\s+/, $_;
        if($test > $all1[1]){
            print "Your beat the record!!\n";
            system("mv .scores_german_temp .scores_german");
        } else {
            system("rm .scores_german_temp");
        }
    }
close $INN;
    }
}

