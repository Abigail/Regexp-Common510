package Regexp::Common510;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

use Scalar::Util 'reftype';

our $VERSION     = '2009112401';

my  $DEFAULT_API = [qw [RE]];
my  %ALL_API     = map {$_ => 1} qw [RE %RE pattern];

sub  RE      {1;};
our %RE;

my  $SEP       = "__";
my  %CACHE;


sub collect_args {
    my %args = @_;
    my %out;

    my $key   = $args {default};
    my %array = $args {array} && ref $args {array} eq 'ARRAY'
                               ? map {$_ => 1} @{$args {array}}
                               : ();

    my $saw_arg = 0;
    foreach my $param (@{$args {args}}) {
        if ($param =~ /^-/) {
            $key = $param;
            $saw_arg = 0;
            #
            # Set a default.
            #
            $out {$key} = $array {$key} ? [] : 1;
            next;
        }
        if (!defined $key) {
            die "Cannot collect without a default key\n";
        }
        if ($array {$key}) {
            push @{$out {$key}} => ref $param eq 'ARRAY' ? @$param : $param;
            next;
        }
        else {
            if ($saw_arg ++) {
                die "Cannot have more than one parameter for '$param'";
            }
            $out {$key} = $param;
        }
    }

    wantarray ? %out : \%out;
}



sub import {
    my $caller = caller;
    my $pkg    = shift;

    my %args   = collect_args default => "-modules",
                              array   => ["-api", "-modules"],
                              args    => \@_;

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
                                    : $DEFAULT_API;

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


#
# Map names to keys.
#
sub name2key {
    my $name = shift;
    
    given (reftype $name) {
        when (undef)   {return $name}
        when ("ARRAY") {return join $SEP => @$name}
    }
    return;
}


#
# Return the 'type' of pattern (string, regexp, coderef, otherwise).
#
sub pattern_type ($) {  
    my $pattern = shift;
    
    given (reftype $pattern) {
        when (undef)    {return "STRING"}
        when ("SCALAR") {
            return ref ($pattern) eq 'Regexp' ? "REGEXP" : "SCALAR"
        }
        default {
            return "${_}REF";
        }
    }
}


#
# Return true if it's a pattern we can deal with.
#
sub check_pattern_type {
    my $pattern = shift;
    
    my $type = pattern_type $pattern;
        
    return $type eq "STRING" ||
           $type eq "REGEXP" ||
           $type eq "CODEREF";
}                     




    

#
# pattern is the routine that registers a (set of) patterns.
# 
# It takes the following arguments:
#    - name:         name of the pattern (required)
#    - pattern:      pattern or sub returning a pattern (required)
#    - keep_pattern: pattern or sub returning a pattern (optional)
#    - version:      minimal perl version
#    - config:       configuration
#

sub pattern {
    if (!@_ || @_ % 2) {
        die "pattern takes a non-empty hash as argument";
    }

    my %arg = @_;

    foreach my $arg (qw [name pattern]) {
        next if exists $arg {$arg};
        die "Argument '$arg' to 'pattern' is required";
    }

    my $pattern      = delete $arg {pattern};
    my $name         = delete $arg {name};
    my $version      = delete $arg {version} // 0;
    my $keep_pattern = delete $arg {keep_pattern};
    my $config       = delete $arg {config};

    #
    # Sanity checks.
    #
    my $key = name2key $name;
    die "Illegal argument 'name' given to 'pattern'\n"
         unless defined $key;

    die "Illegal argument 'pattern' given to 'pattern'\n"
         unless check_pattern_type $pattern;

    #
    # If a version is given, compare it with the current version of Perl.
    # Return if Perl is too old.
    #
    return if $version =~ /^[0-9]+(?:\.[0-9]+)$/ &&
              $version >  $];


    my $hold;   # Hashref which will be stored in registry.

    $$hold {pattern} = $pattern;


    #
    # Parse optional arguments.
    #
    if (defined $keep_pattern) {
        die "Illegal argument 'pattern' given to 'pattern'\n"
             unless check_pattern_type $pattern;

        $$hold {keep_pattern} = $keep_pattern;
    }

    if ($config) {
        unless (reftype ($config) && reftype ($config) eq "HASH") {
            die "Illegal parameters 'config' to 'pattern'\n";
        }

        unless (                 pattern_type (     $pattern) eq 'CODEREF' ||
                $keep_pattern && pattern_type ($keep_pattern) eq 'CODEREF') {
            warnings::warnif ("Useless parameter 'config' to 'pattern'\n");
        }
        else {
            $$hold {config} = {%$config};
        }
    }

    $CACHE {$key} = $hold;
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
