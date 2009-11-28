#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my     @valid = qw [foo bar123 baz_quux _qux];
my @not_valid = qw [123foo bar-baz quux!];

foreach my $valid (@valid) {
    ok  Regexp::Common510::is_valid_name ($valid),
                         "'$valid' is a valid name";
}

foreach my $not_valid (@not_valid) {
    ok !Regexp::Common510::is_valid_name ($not_valid),
                         "'$not_valid' is a not valid name";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
