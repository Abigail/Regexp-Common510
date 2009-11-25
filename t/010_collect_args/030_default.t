#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @tests = (
    [[],                [],       { }],
    [[1],               [],       {-foo => 1}],
    [[1, '-bar', 2],    [],       {-foo => 1, -bar => 2}],
    [[1, '-foo', 2],    [],       {-foo => 2,}],

    [[],                ['-foo'], { }],
    [[1],               ['-foo'], {-foo => [1]}],
    [[1, 2],            ['-foo'], {-foo => [1, 2]}],
    [[1, 2, '-foo', 3], ['-foo'], {-foo => [3]}],
    [[1, 2, '-bar', 3], ['-foo'], {-foo => [1, 2], -bar => 3}],
);

foreach my $test (@tests) {
    my ($in, $array, $out) = @$test;
    my   @params =  (args  => $in, default => '-foo');
    push @params => (array => $array) if $array && @$array;
    my %args = Regexp::Common510::collect_args (@params);
    my $args = Regexp::Common510::collect_args (@params);

    is_deeply \%args, $out, "Collect with default (list context)";
    is_deeply  $args, $out, "Collect with default (scalar context)";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
