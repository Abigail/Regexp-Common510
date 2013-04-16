#!/usr/bin/perl

use 5.010;

use strict;

use Regexp::Common510;

use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

my $warn;
pattern Test    => "foo",
       -pattern => sub {
            my %args = @_;
            $warn    = $args {-Warn};
            '.';
        };


{
    no warnings 'Regexp::Common510';
    Regexp::Common510::RE (Test => 'foo');
    ok !$warn, "Warnings not enabled";
}
{
    use warnings 'Regexp::Common510';
    Regexp::Common510::RE (Test => 'foo');
    ok  $warn, "Warnings enabled";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
