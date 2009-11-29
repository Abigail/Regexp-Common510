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

use Regexp::Common510 -api => ['RE'];

throws_ok {RE}
          qr /RE needs arguments/,
          "RE needs arguments";

throws_ok {RE -Keep => 1} 
          qr /Argument '-Name' to 'RE' is required/ =>
          "RE needs the -Name argument";

throws_ok {RE -Name => "123"} 
          qr /Illegal -Name argument to 'RE'/ =>
          "RE needs a valid name";

throws_ok {RE -Name => "foo"}
          qr /No pattern with that name/ =>
          "RE needs an existing name";



Test::NoWarnings::had_no_warnings () if $r;

done_testing;
