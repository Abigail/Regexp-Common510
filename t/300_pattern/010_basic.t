#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => ['pattern'];

my @tests = (["foo", ["foo"]],
             ["foo__bar", ["foo", "bar"]]);

foreach my $test (@tests) {
    my ($key, $name) = @$test;
    my  $r1 = pattern -name    => $name,
                      -pattern => "";
    my  $r2 = pattern -name    => @$name,
                      -pattern => "";

    is $r1, $key, "pattern called succesfully";
    is $r2, $key, "pattern called succesfully";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
