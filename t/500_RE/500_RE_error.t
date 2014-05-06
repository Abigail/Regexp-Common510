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

use Regexp::Common510 "+RE";

throws_ok {RE}
          qr /RE needs at least 2 arguments/,
          "RE needs at least 2 arguments";

throws_ok {RE "Test"}
          qr /RE needs at least 2 arguments/,
          "RE needs at least 2 arguments";

throws_ok {RE "123Test" => "foo"}
          qr /Category is not valid/,
          "Category is not valid";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
