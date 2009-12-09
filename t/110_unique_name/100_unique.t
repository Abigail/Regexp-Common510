#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => 'unique_name';

my $RUNS = 1000;

my %cache;

foreach (1 .. $RUNS) {
    ok my $k = unique_name, "Got name from unique_name";
    ok !$cache {$k} ++, "Name is unique";
    ok $k =~ /^[_\p{L}][_\p{L}\p{Nd}]*$/, "Valid unique name";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
