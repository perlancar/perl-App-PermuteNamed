package App::PermuteNamed;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{permute_named} = {
    v => 1.1,
    summary => 'Permute multiple-valued key-value pairs',
    description => <<'_',

This is a CLI for `Permute::Named::*` module (currently using
`Permute::Named::Iter`).

To enter a pair with multiple values, you enter a comma-separated list with the
first element is the key name and the rest are values.

The return will be array of hashes.

_
    args => {
        aoaos => {
            'x.name.is_plural' => 1,
            'x.name.singular' => 'aos',
            schema => ['array*', {
                min_len => 2,
                of => ['array*', {
                    min_len => 1,
                    of => 'str*',
                    'x.perl.coerce_rules' => ['str_comma_sep']
                }],
            }],
            req => 1,
            pos => 0,
            greedy => 1,
        },
        separator => {
            summary => 'Separator character to use',
            schema => 'str*',
            cmdline_aliases => {s => {}},
        },
    },
    examples => [
        {
            argv => ['bool,0,1','x,foo,bar,baz'],
        },
        {
            src => '[[prog]] bool,0,1 x,foo,bar,baz --format json-pretty --naked-res',
            src_plang => 'bash',
            summary => 'Like previous example, but outputs JSON',
        },
    ],
};
sub permute_named {
    require Permute::Named::Iter;

    my %args = @_;
    my $sep = $args{separator};

    my @fields;
    my @permute;
    for my $aos (@{$args{aoaos}}) {
        my $k = shift @$aos;
        push @permute, $k, $aos;
        push @fields, $k
    }

    my $resmeta = {};
    my $iter = Permute::Named::Iter::permute_named_iter(@permute);
    my @res;
    while (my $h = $iter->()) {
        if (defined $sep) {
            push @res, join($sep, @{$h}{@fields});
        } else {
            push @res, $h;
        }
    }

    unless (defined $sep) {
        $resmeta->{'table.fields'} = \@fields;
    }

    [200, "OK", \@res, $resmeta];
}

1;
#ABSTRACT:

=head1 SEE ALSO

L<Permute::Named>, L<Permute::Named::Iter>, L<PERLANCAR::Permute::Named>.

L<Set::Product>, L<Set::CrossProduct> (see more similar modules in the POD of
Set::Product) and CLI scripts <cross>, L<cross-pericmd>.
