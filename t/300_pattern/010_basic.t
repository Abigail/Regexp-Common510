#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => ['pattern'];

my @tests = ([Test => 'test1'],
             [Test => 'test2'],
             [Foo  => 'bar'],
             [Test => 'test2'],);

my %seen;

foreach my $test (@tests) {
    my ($category, $name) = @$test;
    my  $s = $seen {$category} {$name} ++;
    my  $r = pattern $category => $name, -pattern => "";

    ok !($s xor $r), "pattern called succesfully";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
