#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

BEGIN {
    eval "use Test::Warn; 1" or 
          plan skip_all => "Test::Warn required for testing warnings";
}

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510 "+RE", "+pattern";
use warnings 'Regexp::Common510';

pattern  Foo     => 'test',
        -config  =>  {
            -key1   =>  "value",
            -key2   =>  "value",
         },
        -pattern => sub {"foo"};

warning_like {RE Foo => 'test', -key1 => "value", -key3 => "value"}
          qr /Unknown parameter '-key3' ignored/,
          "Ignoring unknown parameters";

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
