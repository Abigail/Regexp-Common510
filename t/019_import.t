#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

my $x;

$x = eval q !use Regexp::Common510 -api => ["garbage"]!;
ok !$x && $@ =~ /Unknown API point: garbage/, "-api sanity check";

$x = eval q !use Regexp::Common510 -foo => "bar"!;
ok !$x && $@ =~ /Unknown import parameters: -foo/, "import args sanity check";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
