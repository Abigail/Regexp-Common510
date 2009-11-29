#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => "RE", "pattern";

pattern foo =>          -pattern => "123";
pattern qw [foo bar] => -pattern => "456";

my @tests = (
   [["foo"]         =>  "123"],
   [["foo", "bar"]  =>  "456"],
);

foreach my $test (@tests) {
    my ($name, $pattern) = @$test;
    my $Pat1 = RE          @$name;
    my $Pat2 = RE           $name;
    my $Pat3 = RE -Name => @$name;
    my $Pat4 = RE -Name =>  $name;

    is $Pat1, $pattern, "Retrieve (list)";
    is $Pat2, $pattern, "Retrieve (arrayref)";
    is $Pat3, $pattern, "Retrieve (named/list)";
    is $Pat4, $pattern, "Retrieve (named/arrayref)";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
