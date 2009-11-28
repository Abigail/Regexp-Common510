#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @tests = (
    [[],                      {}],
    [[-foo => 1],             {-foo => 1}           ],
    [[-foo => 1, -baz => 2],  {-foo => 1, -baz => 2}],
    [[-foo => 1, -foo => 2],  {-foo => 2}           ],
);

foreach my $test (@tests) {
    my ($in, $out) = @$test;
    my %args = Regexp::Common510::collect_args (args => $in);
    my $args = Regexp::Common510::collect_args (args => $in);

    is_deeply \%args, $out, "Scalar collect (list context)";
    is_deeply  $args, $out, "Scalar collect (scalar context)";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
