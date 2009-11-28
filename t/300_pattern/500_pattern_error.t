#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

BEGIN {
    eval "use Test::Exception; 1" or 
          plan skip_all => "Test::Exception required for testing exceptions";
}

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 -api => ['pattern'];

throws_ok {pattern}
          qr /pattern needs arguments/,
          "pattern needs arguments";

throws_ok {pattern -name => "foo"} 
          qr /Argument '-pattern' to 'pattern' is required/ =>
          "pattern needs the -pattern argument";

throws_ok {pattern -pattern => "foo"} 
          qr /Argument '-name' to 'pattern' is required/ =>
          "pattern needs the -name argument";



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
