#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => 'pattern', '%RE', 'pattern', 'name2key';

ok  defined &pattern,  "&pattern is set";
ok !defined &RE,       "&RE is not set";
ok  defined &name2key, "&name2key is set";

$Regexp::Common510::RE {foo} = "bar";

is $RE {foo}, "bar", "%Regexp::Common510::RE was exported";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
