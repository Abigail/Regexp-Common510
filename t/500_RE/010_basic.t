#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 "+RE", "+pattern";

pattern Test => foo => -pattern => "123";
pattern Test => bar => -pattern => "456";

my @tests = (
   [qw [Test  foo 123]],
   [qw [Test  bar 456]],
   [qw [Test2 baz 789]],
   [qw [Test  foo 000]],
);

foreach my $test (@tests) {
    my ($category, $name, $pattern) = @$test;
    pattern $category => $name, -pattern => $pattern;

    my $Pat = RE $category, $name;

    is $Pat, $pattern, "Retrieved ($category/$name)";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
