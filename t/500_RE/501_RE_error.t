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

use Regexp::Common510 -api => ['RE', 'pattern'];

pattern  Foo     => 'test',
        -config  =>  {
            -key1   =>  "value",
            -key2   =>  "value",
         },
        -pattern => sub {"foo"};

throws_ok {RE Foo => 'test', -key => "value", key => "value"}
          qr /Parameters should start with a hyphen/,
          "Parameters should start with a hyphen";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
