package Regexp::Common510;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

our $VERSION = '2009112401';

sub  pattern {1;};
sub  RE      {1;};
our %RE;

sub import {
    my $caller = caller;
    my $pkg    = shift;

    my %args   = @_;

    if (exists $args {'-modules'}) {
        my $modules = delete $args {'-modules'};
        foreach my $module (@$modules) {
            my $package = __PACKAGE__ . "::$module";
            eval "require $package; 1" or do {
                my $error = $@ // "Unknown error";
                die "Importing $package failed: $error\n";
            };
        }
    }

    my $api = exists $args {'-api'} ? delete $args {'-api'}
                                    : [qw [%RE RE pattern]];

    foreach (@$api) {
        no strict 'refs';
        when ("pattern") {*{"${caller}::pattern"} = \&{"${pkg}::pattern"}}
        when ("RE")      {*{"${caller}::RE"}      = \&{"${pkg}::RE"}}
        when ("%RE")     {*{"${caller}::RE"}      = \%{"${pkg}::RE"}}
        default          {die "Unknown API point: $_\n"}
    }

    if (%args) {
        my @keys = keys %args;
        local $" = ", ";
        die "Unknown import parameters: @keys\n";
    }
}
    

1;

__END__

=head1 NAME

Regexp::Common510 - Abstract

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

=head1 TODO

=head1 SEE ALSO

=head1 DEVELOPMENT

The current sources of this module are found on github,
L<< git://github.com/Abigail/Regexp--Common510.git >>.

=head1 AUTHOR

Abigail, L<< mailto:cpan@abigail.be >>.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2009 by Abigail.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),   
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 INSTALLATION

To install this module, run, after unpacking the tar-ball, the 
following commands:

   perl Makefile.PL
   make
   make test
   make install

=cut
