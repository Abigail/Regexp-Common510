#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my $ZWSP  = "\x{200B}";

my @Names = qw [foo bar baz];
my $C     = "Category";

my @tests = (
    [[],                      {}],
    [[-foo => 1],             {-foo => 1}           ],
    [[-foo => 1, -baz => 2],  {-foo => 1, -baz => 2}],
    [[-foo => 1, -foo => 2],  {-foo => 2}           ],
);


foreach my $test (@tests) {
    my ($in, $out) = @$test;

    for (my $i = 0; $i <= @Names; $i ++) {
        next if $i == 1;
        my @names = @Names [0 .. $i - 1];
        my $exp_name = join $ZWSP => @names;

        my ($c1, $n1, %args) =
            Regexp::Common510::collect_args (get_names => 1,
                                             args => [$C, @names, @$in]);
        my  $results         =
            Regexp::Common510::collect_args (get_names => 1,
                                             args => [$C, @names, @$in]);

        my ($c2, $n2, $args) = @$results;

        is         $c1,   $C,        "Category name (list context)";
        is         $c2,   $C,        "Category name (scalar context)";
        is         $n1,   $exp_name, "Name (list context)";
        is         $n2,   $exp_name, "Name (scalar context)";
        is_deeply \%args, $out,      "Argument collect (list context)";
        is_deeply  $args, $out,      "Argument collect (scalar context)";
    }
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
