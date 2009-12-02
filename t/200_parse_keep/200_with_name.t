#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

use Regexp::Common510;

my @tests = (
    ['foo bar'     => 'foo bar',             'foo bar'],
    ['(?k<F>:foo)' => '(?:foo)',             '(?<F>foo)'],
    ['(?k<ABC>:foo) bar (?k<ABC>:baz)'
                   => '(?:foo) bar (?:baz)', '(?<ABC>foo) bar (?<ABC>baz)'],
    ['(?k<DEF>:(?k<GHIJ>:(?k<DEF>:foo)))'
                   => '(?:(?:(?:foo)))',     '(?<DEF>(?<GHIJ>(?<DEF>foo)))'],
    ['foo (?k<XYZ123>:bar)'
                   => 'foo (?:bar)',         'foo (?<XYZ123>bar)'],
);

foreach my $test (@tests) {
    my ($pattern, $no_keep, $keep) = @$test;
    my $out1 = Regexp::Common510::parse_keep pattern => $pattern,
                                             keep    =>  0;

    my $out2 = Regexp::Common510::parse_keep pattern => $pattern,
                                             keep    =>  1;

    is $out1, $no_keep, "$pattern parsed correctly with -keep => 0";
    is $out2,    $keep, "$pattern parsed correctly with -keep => 1";
}


Test::NoWarnings::had_no_warnings () if $r;

done_testing;
