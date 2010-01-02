#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

ok !defined &pattern,  "&pattern is set";
ok  defined &RE,       "&RE is set";
ok !defined &name2key, "&name2key is not set";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
