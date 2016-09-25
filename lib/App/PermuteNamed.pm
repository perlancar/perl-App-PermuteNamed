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
    },
    examples => [
        {
            argv => ['bool,0,1','x,foo,bar,baz'],
        },
    ],
};
sub permute_named {
    require Permute::Named::Iter;

    my %args = @_;

    my @fields;
    my @permute;
    for my $aos (@{$args{aoaos}}) {
        my $k = shift @$aos;
        push @permute, $k, $aos;
        push @fields, $k
    }

    my $iter = Permute::Named::Iter::permute_named_iter(@permute);
    my @res;
    while (my $h = $iter->()) {
        push @res, $h;
    }

    [200, "OK", \@res, {'table.fields'=>\@fields}];
}

1;
#ABSTRACT:

=head1 SEE ALSO

L<Permute::Named>, L<Permute::Named::Iter>, L<PERLANCAR::Permute::Named>.

L<Set::Product>, L<Set::CrossProduct> (see more similar modules in the POD of
Set::Product) and CLI scripts <cross>, L<cross-pericmd>.
