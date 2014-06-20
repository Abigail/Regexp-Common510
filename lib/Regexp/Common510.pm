package Regexp::Common510;

use 5.010;
use strict;
use warnings;
no  warnings 'syntax';

use Scalar::Util 'reftype';

use warnings::register;

our $VERSION   = '2009112401';

my  $SEP       = "__";
my  %CACHE;
my  $ZWSP      = "\x{200B}";   # Zero Width Space

sub load_category;

sub collect_args {
    my %params = @_;
    my %out;

    my $get_names  = $params {get_names};
    my $args       = $params {args};
    my %array      = $params {array} && ref $params {array} eq 'ARRAY'
                                   ? map {$_ => 1} @{$params {array}}
                                   : ();
    my $check_args = $params {check_args};

    my ($category, $name);

    if ($get_names) {
        #
        # First one is always the category.
        #
        $category = shift @$args;
        my @names;
        while (@$args && $$args [0] !~ /^-/) {
            push @names => shift @$args;
        }
        $name     = join $ZWSP => @names;
    }

    for (my $i = 0; $i < @$args - 1; $i += 2) {
        my $key   = $$args [$i];
        my $value = $$args [$i + 1];

        unless ($key =~ /^-/) {
            require Carp;
            Carp::croak ("Parameters should start with a hyphen");
        }

        if ($array {$key}) {
            push @{$out {$key}} => ref $value eq 'ARRAY' ? @$value : $value;
        }
        else {
            $out {$key} = $value;
        }
    }

    wantarray ? $get_names ? ($category, $name,  %out) :  %out
              : $get_names ? [$category, $name, \%out] : \%out;
}


sub import {
    my $caller = caller;
    my $pkg    = shift;

    #
    # Anything that does not start with a ! or + is a category to be loaded.
    #
    my @categories = grep {!/^[!+]/} @_;

    my %export;

    #
    # If there are categories, by default, we'll export 'RE'.
    #
    if (@categories) {
        $export {RE}      = 1;
    }
    #
    # Otherwise, by default, we'll export 'pattern'.
    #
    else {
        $export {pattern} = 1;
    }

    #
    # Process !foo and +foo, allowing to override the default exports.
    #
    foreach my $arg (@_) {
        if (substr ($arg, 0, 1) eq '!') {
            delete $export {substr $arg => 1};
        }
        elsif (substr ($arg, 0, 1) eq '+') {
            $export {substr $arg => 1} = 1;
        }
    }

    #
    # Load the categories
    #
    foreach my $category (@categories) {
        load_category $category;
    }

    #
    # Export methods.
    #
    foreach my $sub (qw [RE pattern unique_name]) {
        next unless $export {$sub};

        no strict 'refs';
        *{"${caller}::${sub}"} = \&{"${pkg}::${sub}"}
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
# Check if a string is a valid capture name.
#
sub is_valid_name {
    $_ [0] =~ /^[_\p{L}][_\p{L}\p{Nd}]*$/;   # Digits or any numbers?
}

#
# Map names to keys.
#
# Names should be valid capture names.
#
sub name2key {
    my $name = shift;
    my $key  = "";
    
    my $reftype = reftype $name;
    if (!defined $reftype) {
        $key = $name
    }
    elsif ($reftype eq 'ARRAY') {
        $key =  join $SEP => grep {!reftype ($_)} @$name
    }
    $key =~ s/[^_\p{L}\p{N}]/_/g;
    return $key;
}



#
# Return a unique name, depending on the class it's called from.
#
sub unique_name {
    my  $pkg   = caller;
    my ($name) = $pkg =~ /^Regexp::Common510::([A-Z][A-Za-z0-9_]*)/ or return;

    state $cache;

    $$cache {$name} //= "aaaa";

    return "__RC_${name}_" . $$cache {$name} ++;
}


#
# Return the 'type' of pattern (string, regexp, coderef, otherwise).
#
sub pattern_type ($) {  
    my $pattern = shift;
    
    my $reftype = reftype $pattern;
    if (!defined $reftype) {
        return "STRING";
    }
    elsif ($reftype eq "SCALAR") {
        return ref ($pattern) eq 'Regexp' ? "REGEXP" : "SCALAR"
    }
    else {
        return "${reftype}REF";
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
#    + -extra_args:   extra arguments to be passed to pattern sub
#
# Returns the canonical name ($key).
#

sub pattern {
    die "pattern needs at least 2 arguments" unless @_ >= 2;

    #
    # Collect the arguments
    #
    my ($category, $name, %arg) = collect_args get_names => 1, args => \@_;

    die "Category is not valid" unless is_valid_name $category;

    foreach my $arg (qw [-pattern]) {
        next if exists $arg {$arg};
        die "Argument '$arg' to 'pattern' is required";
    }

    my $pattern      = delete $arg {-pattern};
    my $version      = delete $arg {-version} // 0;
    my $keep_pattern = delete $arg {-keep_pattern};
    my $config       = delete $arg {-config};
    my $extra_args   = delete $arg {-extra_args};

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

    $$hold {extra_args} = $extra_args if defined $extra_args;

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

    return $pattern if $keep && $keep eq 'raw';

    $pattern    =~ s{\(\?k (?: <([^>!]+)(!)?> )? :}
                    {$keep ? defined $1 ? "(?<$1>"
                                        : "("
                           : $2 ? "("
                                : "(?:"}xeg;

    $pattern;
}

#
# Retrieve a pattern
#
#  RE category, name+ [, arguments]
#
#   +  category:       Category the pattern comes from
#   +  name:           Name of the pattern
#   + -Keep:           Requesting the keep pattern
#   + -xxxx:           (All lower case): args passed on to sub
#
sub RE {
    die "RE needs at least 2 arguments" unless @_ >= 2;

    #
    # Collect the arguments.
    #
    my ($category, $name, %arg) = collect_args get_names => 1, args => \@_;

    die "Category is not valid" unless is_valid_name $category;

    #
    # Die if it isn't there.
    #
    my $hold = $CACHE {$category} {$name} or die "No pattern $category/$name";

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

        while (my ($key, $value) = each %arg) {
            if (exists $$hold {config} {$key}) {
                $config {$key} = $value;
            }
            else {
                if (warnings::enabled) {
                    require Carp;
                    Carp::carp ("Unknown parameter '$key' ignored");
                }
            }
        }

        $pattern = $pattern -> (
            %config,
            defined $Keep              ? (-Keep => $Keep)       : (),
            exists $$hold {extra_args} ? @{$$hold {extra_args}} : (),
           -Name   =>  [split $ZWSP => $name],
           -Warn   =>  warnings::enabled,
        );

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

 use Regexp::Common510;
 use Regexp::Common510 qw {Number URI};

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

For each module C<< Name >> given as parameter, the module
C<< Regexp::Common510::Name >> is loaded.

If you don't want to import the default subroutines (C<< RE >> or
C<< pattern >>), give the subroutine prepended with C<< ! >> as argument
to C<< use Regex::Common510 >>. When you want to import either subroutine
when it would not be exported, prepend C<< + >> to the subroutine name,
and add it as an argument.

  use Regexp::Common510;               # Imports 'pattern'

  use Regexp::Common510 '!pattern';    # Do not import anything.

  use Regexp::Common510 'Name';        # Load module Regexp::Common510::Name,
                                       # and import 'RE'

  use Regexp::Common510 '-RE', 'Name'; # Load module Regexp::Common510::Name,
                                       # do not import anything.

  use Regexp::Common510 'Name', '+pattern';
                                       # Load module Regexp::Common510::Name,
                                       # import both 'RE' and 'pattern'.


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
L<< git://github.com/Abigail/Regexp-Common510.git >>.

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
