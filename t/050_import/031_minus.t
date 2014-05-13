#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 '!pattern';

ok !defined &pattern,     "&pattern is not set";
ok !defined &RE,          "&RE is not set";
ok !defined &unique_name, "&unique_name is not set";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
