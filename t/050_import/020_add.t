#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 '+RE';

ok  defined &pattern,  "&pattern is set";
ok  defined &RE,       "&RE is set";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
