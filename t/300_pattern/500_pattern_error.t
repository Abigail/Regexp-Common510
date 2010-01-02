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
          qr /pattern needs at least 2 arguments/,
          "pattern needs at least 2 arguments";

throws_ok {pattern "Test"}
          qr /pattern needs at least 2 arguments/,
          "pattern needs at least 2 arguments";

throws_ok {pattern Test => "foo"} 
          qr /Argument '-pattern' to 'pattern' is required/ =>
          "pattern needs the -pattern argument";

throws_ok {pattern "123Test" => "foo"}
          qr /Category is not valid/,
          "Category is not valid";

throws_ok {pattern "Test" => "::foo"}
          qr /Name is not valid/,
          "Name is not valid";


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
