package Regexp::Common510;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

use Scalar::Util 'reftype';

our $VERSION     = '2009112401';

my  $SEP       = "__";
my  %CACHE;

sub load_category;

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

    my %args   = collect_args default => "-categories",
                              array   => ["-api", "-categories"],
                              args    => \@_;

    my $api = delete $args {'-api'} // ["RE"];

    if (my $categories = delete $args {'-categories'}) {
        foreach my $category (@$categories) {
            load_category $category;
        }
    }

    foreach (@$api) {
        no strict 'refs';
        when ("pattern")     {*{"${caller}::pattern"}  = \&{"${pkg}::pattern"}}
        when ("RE")          {*{"${caller}::RE"}       = \&{"${pkg}::RE"}}
        when ("name2key")    {*{"${caller}::name2key"} = \&{"${pkg}::name2key"}}
        when ("unique_name") {
            *{"${caller}::unique_name"} = \&{"${pkg}::unique_name"}
        }
        default           {die "Unknown API point: $_\n"}
    }

    if (%args) {
        my @keys = keys %args;
        local $" = ", ";
        die "Unknown import parameters: @keys\n";
    }
}

#
# Load a category of patterns.
#
sub load_category {
    my $category = shift;

    my $package = __PACKAGE__ . "::$category";
    eval "require $package; 1" or do {
        my $error = $@ // "Unknown error";
        die "Importing $category failed: $error\n";
    };
}

#
# Return a unique, valid, name to be used as capture.
# All names will start with __RC__
#
sub unique_name () {
    state $tag = "aaaaa";
    "__RC__" . $tag ++;
}

#
# Check if a string is a valid capture name.
#
sub is_valid_name {
    my $_ = shift;
    /^[_\p{L}][_\p{L}\p{Nd}]*$/;   # Digits or any numbers?
}

#
# Map names to keys.
#
# Names should be valid capture names.
#
sub name2key {
    my $name = shift;
    my $key  = "";
    
    given (reftype $name) {
        when (undef)   {$key = $name}
        when ("ARRAY") {$key =  join $SEP => grep {!reftype ($_)} @$name}
    }
    $key =~ s/[^_\p{L}\p{N}]/_/g;
    return $key;
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
# pattern category, name, [arguments];

# It takes the following arguments:
#    + category:      category of pattern
#    + name:          name of the pattern
#    + -pattern:      pattern or sub returning a pattern (required)
#    + -keep_pattern: pattern or sub returning a pattern (optional)
#    + -version:      minimal perl version
#    + -config:       configuration
#
# Returns the canonical name ($key).
#

sub pattern {
    die "pattern needs at least 2 arguments" unless @_ >= 2;

    my $category = shift;
    my $name     = shift;

    die "Category is not valid" unless is_valid_name $category;

    #
    # Collect the arguments
    #
    my %arg = collect_args args => \@_;

    foreach my $arg (qw [-pattern]) {
        next if exists $arg {$arg};
        die "Argument '$arg' to 'pattern' is required";
    }

    my $pattern      = delete $arg {-pattern};
    my $version      = delete $arg {-version} // 0;
    my $keep_pattern = delete $arg {-keep_pattern};
    my $config       = delete $arg {-config};

    #
    # Sanity checks.
    #
    die "Illegal argument '-pattern' given to 'pattern'\n"
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

    my $old = $CACHE {$category} {$name};

    $CACHE {$category} {$name} = $hold;

    !!$old;
}

#
# Parses out (?k:) and (?k<name>:) constructs.
#
sub parse_keep {
    my %args    = @_;
    my $pattern = $args {pattern};
    my $keep    = $args {keep};

    $pattern    =~ s{\(\?k (?: <([^>]+)> )? :}
                    {$keep ? defined $1 ? "(?<$1>"
                                        : "("
                           : "(?:"}xeg;

    $pattern;
}

#
# Retrieve a pattern
#
#  RE category, name [, arguments]
#
#   +  category:       Category the pattern comes from
#   +  name:           Name of the pattern
#   + -Keep:           Requesting the keep pattern
#   + -xxxx:           (All lower case): args passed on to sub
#
sub RE {
    die "RE needs at least 2 arguments" unless @_ >= 2;

    my $category = shift;
    my $name     = shift;

    die "Category is not valid" unless is_valid_name $category;

    #
    # Load the category if it doesn't exist yet.
    #
    unless (exists $CACHE {$category}) {
        load_category $category;
    }

    #
    # Die if it isn't there.
    #
    my $hold = $CACHE {$category} {$name} or die "No pattern $category/$name";

    #
    # Collect the arguments.
    #
    my %arg  = collect_args args => \@_;

    #
    # Grab the global parameters.
    #
    my $Keep = delete $arg {-Keep};

    my $pattern;
    my $need_parse;    # If true, extract (?k: ) constructs.

    #
    # Do we need to parse (?k:) constructs?
    #
    if ($Keep && exists $$hold {keep_pattern}) {
        $pattern = $$hold {keep_pattern};
    }
    else {
        $pattern    = $$hold {pattern};
        if (  !exists $$hold {keep_pattern}
            && pattern_type $pattern eq "STRING") {
            $need_parse = 1;
        }
    }

    if (pattern_type $pattern eq "CODEREF") {
        my %config   = %{$$hold {config} || {}};
        $config {$_} = delete $arg {$_} foreach grep {/^-\p{Ll}/} keys %arg;
        $pattern = $pattern -> (%config);
        if (  !exists $$hold {keep_pattern}
            && pattern_type $pattern eq "STRING") {
            $need_parse = 1;
        }
    }

    if ($need_parse) {
        my $parsed_pattern = parse_keep  pattern => $pattern,
                                         keep    => $Keep;

        $pattern = $parsed_pattern;
    }

    $pattern;
}



1;

__END__

=head1 NAME

Regexp::Common510 - Abstract

=head1 SYNOPSIS

 use Regexp::Common510 qw {number URI}, -api => 'pattern', 'RE';

=head1 DESCRIPTION

=head2 Export

By default, C<< Regexp::Common510 >> exports a single subroutine; either
C<< pattern >>, or C<< RE >>. 

If C<< Regexp::Common510 >> is used without a list of modules, it's assumed
the using package is a package that registers new patterns. In such a case,
the subroutine C<< pattern >> is exported. Otherwise (that is, a list
of modules is used when C<< use >>ing C<< Regexp::Common510 >>), it's assumed
the using package is package that wants to query for patterns. Then C<< RE >>
is exported.

In either case, the default can be overruled by using C<< -api LIST >> 
in the usage list, where C<< LIST >> is a (possibly empty) list of things
to import. C<< LIST >> is either a list of strings, or an anonymous array
of strings. The following subroutines and variables can be imported:

=over 4

=item C<< pattern >>

Register new patterns.

=item C<< RE >>

Query patterns.

=item C<< %RE >>

Old interface. (Possible. May never happen.)

=back

For a detailed description of the items above, see below.

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
