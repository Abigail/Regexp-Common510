#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use lib 't';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 qw [dummy];

ok !defined &pattern,  "&pattern is not set";
ok  defined &RE,       "&RE is set";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
