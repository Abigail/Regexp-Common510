#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @tests = (
    [[],                       [],       { }],
    [['-bar'],                 [],       {-bar => 1}],
    [[2, '-bar'],              [],       {-foo => 2, -bar => 1}],
    [[2, '-bar', '-foo'],      [],       {-foo => 1, -bar => 1}],
    [['-foo', '-bar', '-baz'], [],       {-foo => 1, -bar => 1, -baz => 1}],

    [[],                       ['-bar'], { }],
    [['-bar'],                 ['-bar'], {-bar => []}],
    [[2, '-bar'],              ['-bar'], {-foo => 2, -bar => []}],
    [[2, '-bar', '-foo'],      ['-bar'], {-foo => 1, -bar => []}],
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
