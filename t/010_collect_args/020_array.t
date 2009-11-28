#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @tests = (
    [[],                     [],             {}],
    [[],                     [qw [-foo]],    {}],
    [['-foo', 1],            [qw [-foo]],    {-foo => [1]}],
    [['-foo', 1, 2, 3],      [qw [-foo]],    {-foo => [1, 2, 3]}],
    [['-foo', 1, '-bar', 2], [qw [-foo]],    {-foo => [1], -bar => 2}],
    [['-foo', 1, '-bar', 2, '-foo', 3, '-bar', 4],
                             [qw [-foo]],    {-foo => [3], -bar => 4}],
    [['-foo', 1, 2, '-bar', 3, '-foo', 4, 5, 6, '-bar', 7],
                             [qw [-foo]],    {-foo => [4, 5, 6], -bar => 7}],
    [['-foo', 1, 2, '-bar', 3, '-foo', 4, 5, 6, '-bar', 7],
                             [qw [-foo -bar]],
                             {-foo => [4, 5, 6], -bar => [7]}],
);

foreach my $test (@tests) {
    my ($in, $array, $out) = @$test;
    my %args = Regexp::Common510::collect_args (args => $in, array => $array);
    my $args = Regexp::Common510::collect_args (args => $in, array => $array);

    is_deeply \%args, $out, "Array collect (list context)";
    is_deeply  $args, $out, "Array collect (scalar context)";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
