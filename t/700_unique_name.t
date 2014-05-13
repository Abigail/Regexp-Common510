#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
no  warnings 'syntax';

use Test::More 0.88;

our $r = eval "require Test::NoWarnings; 1";

{
    package Regexp::Common510::Foo;
    use Test::More 0.88;

    use Regexp::Common510 '+unique_name';

    my $name1 = unique_name;
    ok $name1 =~ /^__RC_Foo_[a-z]+$/, "Unique name 1 ok";

    my $name2 = unique_name;
    ok $name2 =~ /^__RC_Foo_[a-z]+$/, "Unique name 2 ok";

    ok $name1 ne $name2, "Names differ";
}


{
    package Regexp::Common510::Bar::Baz;
    use Test::More 0.88;

    use Regexp::Common510 '+unique_name';

    my $name1 = unique_name;
    ok $name1 =~ /^__RC_Bar_[a-z]+$/, "Unique name 1 ok";

    my $name2 = unique_name;
    ok $name2 =~ /^__RC_Bar_[a-z]+$/, "Unique name 2 ok";

    ok $name1 ne $name2, "Names differ";
}


{
    package Something::Else;
    use Test::More 0.88;

    use Regexp::Common510 '+unique_name';

    my $name = unique_name;
    ok !defined $name, "No unique_name for non-Regexp::Common510 package";
}

Test::NoWarnings::had_no_warnings () if $r;

done_testing;
