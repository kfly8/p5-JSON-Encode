package JSON::TypeEncoder;
use 5.012002;
use strict;
use warnings;

use Types::Standard -types;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    bless { }, $class;
}

sub encoder {
    my ($self, $type) = @_;
    my $src = sprintf('sub {
        my $obj = shift;
        return %s
    }', $self->_json_src('$obj', $type));

    my $code = eval $src; ## no critic
    die "error string eval: $@, src: $src" if $@;
    return $code;
}

sub _json_src {
    my ($self, $obj_src, $type) = @_;

    my $maybe;
    if (_is_subtype($type, Maybe)) {
        $type = $type->parameters->[0];
        $maybe = !!1;
    }

    my $src = _is_subtype($type, Dict)     ? $self->_json_src_dict($obj_src, $type)
            : _is_subtype($type, Tuple)    ? $self->_json_src_tuple($obj_src, $type)
            : _is_subtype($type, ArrayRef) ? $self->_json_src_arrayref($obj_src, $type)
            : _is_subtype($type, Bool)     ? $self->_json_src_bool($obj_src)
            : _is_subtype($type, Num)      ? $self->_json_src_num($obj_src)
            : _is_subtype($type, Str)      ? $self->_json_src_str($obj_src)
            : die "cannot parse type: $type";

    if ($maybe) {
        $src = qq!defined($obj_src) ? $src : 'null'!
    }

    return $src;
}

sub _json_src_dict {
    my ($self, $obj_src, $type) = @_;
    my @src;
    my %types = @{$type->parameters};
    my @keys = sort keys %types;
    for (my $i = 0; $i < @keys; $i++) {
        my $key      = $keys[$i];
        my $stype    = $types{$key};
        my $sobj_src = "${obj_src}->{$key}";

        my $optional;
        if (_is_subtype($stype, Optional)) {
            $stype = $stype->parameters->[0];
            $optional = !!1;
        }

        my $value_src = $self->_json_src($sobj_src, $stype);
        my $comma     = $i == 0 ? '' : ',';
        my $src       = qq!$comma"$key":' . ($value_src) . '!;

        if ($optional) {
            $src = qq!' . (exists($sobj_src) ? '$src' : '') . '!
        }

        push @src => $src;
    }

    sprintf(q!'{%s}'!, join "", @src);
}

sub _json_src_tuple {
    my ($self, $obj_src, $type) = @_;
    my @src;
    my @types = @{$type->parameters};
    for my $i (0 .. $#types) {
        my $src = $self->_json_src("${obj_src}->[$i]", $types[$i]);
        $src = qq!' . ($src) . '!;
        push @src => $src;
    }
    sprintf(q!'[%s]'!, join ",", @src);
}

sub _json_src_arrayref {
    my ($self, $obj_src, $type) = @_;
    my @src;
    my $stype = $type->parameters->[0];
    my $src = $self->_json_src('$_', $stype);
    sprintf(q!'[' . (do {my $src; for (@{%s}) { $src .= (%s) . ',' }; substr($src,0,-1) }) . ']'!, $obj_src, $src);
}

sub _json_src_str {
    my ($self, $value_src) = @_;
    qq!'"' . $value_src . '"'!
}

sub _json_src_num {
    my ($self, $value_src) = @_;
    qq!$value_src+0!
}

sub _json_src_bool {
    my ($self, $value_src) = @_;
    qq[$value_src ? 'true' : 'false']
}

sub _is_subtype {
    my ($type, $other) = @_;
    return unless $type;
    $type->name eq $other->name || _is_subtype($type->parent, $other)
}

1;
__END__

=encoding utf-8

=head1 NAME

JSON::TypeEncoder - serialize JSON using type information

=head1 SYNOPSIS

    use JSON::TypeEncoder;
    use Types::Standard -types;

    my $type = Dict[name => Str, age => Int];

    my $json = JSON::TypeEncoder->new;
    my $encode = $json->encoder($type);

    $encode->({ name => 'Perl', age => 30 });
    # => {"age":30,"name":"Perl"}

=head1 DESCRIPTION

JSON::TypeEncoder serialize Perl data structures to JSON using type information.
This module goal is to be B<correct> and B<fast>.

=head2 FEATURES

=head3 Correct

This module encodes according to the specified type information.
For example, it encodes as following:

    use JSON::TypeEncoder;
    use Types::Standard -types;

    my $e = JSON::TypeEncoder->new;

    my $s = $e->encoder(Dict[str => Str]);
    $s->({str => 123}); # => {"str":"123"}

    my $i = $e->encoder(Dict[int => Int]);
    $i->({int => '456'}); # => {"int":456}

    my $b = $e->encoder(Dict[fg => Bool]);
    $b->({fg => !!0}); # => {"fg":false}

This will prevent unintended encoding.

=head3 Fast

Encoding performance is improved by string eval using type information.
You can get speed comparable to JSON::XS. The results of a simple benchmark is as following:

    use Benchmark qw(cmpthese);

    use JSON::XS qw(encode_json);
    use JSON::TypeEncoder;
    use JSON::Types;

    use Types::Standard -types;
    my $type = Dict[name => Str, age => Int];
    my $encode = JSON::TypeEncoder->new->encoder($type);

    cmpthese -1, {
        'JSON::XS'          => sub { encode_json({ name => 'Perl', age => 30 }) },
        'JSON::TypeEncoder' => sub { $encode->({ name => 'Perl', age => 30 }) },
        'JSON::XS w/ Types' => sub { encode_json({ name => string 'Perl', age => number 30 }) },
    };

    #                        Rate JSON::XS w/ Types         JSON::XS JSON::TypeEncoder
    # JSON::XS w/ Types  869501/s                --             -32%              -48%
    # JSON::XS          1279827/s               47%               --              -24%
    # JSON::TypeEncoder 1679704/s               93%              31%                --

=head3 Pure Perl

This module is written by pure Perl. So you can easily install it.

=head2 TYPE SPECIFICATION

L<Types::Standard> is used for type specification.
The basic types are as follows, you can specify the type of JSON by this combination.

=head3 Example

    use Types::Standard -types;
    use JSON::TypeEncoder;

    my $type = ArrayRef[
        Dict[
            name => Str,
            fg => Bool,
            foo => Optional[Str],
            bar => Maybe[Num]
        ]
    ];

    my $encode = JSON::TypeEncoder->new->encoder($type);
    $encode->(
        [
            { name => 'a', fg => !!1, foo => '1', bar => '10' },
            { name => 'b', fg => !!0,             bar => '11' },
            { name => 'c', fg => !!1, foo => '2', bar => undef },
            { name => 'd', fg => !!0,             bar => undef },
        ]
    );

    # =>
    # [
    #   {"bar":10,"fg":true,"foo":"1","name":"a"},
    #   {"bar":11,"fg":false,"name":"b"},
    #   {"bar":null,"fg":true,"foo":"2","name":"c"},
    #   {"bar":null,"fg":false,"name":"d"}
    # ]

=head3 Basic Types

=over

=item C<< Str >>

Subtype of C<< Str >> type encodes always to string.

=item C<< Num >>

Subtype of C<< Num >> type encodes always to number.

=item C<< Bool >>

Subtype of C<< Bool >> type encodes always to boolean.

=item C<< Dict[...] >>

Subtype of C<< Dict[...] >> encodes always to map.

=item C<< Tuple[...] >>

Subtype of C<< Tuple[A, B] >> encodes always to list of type A and B.

=item C<< ArrayRef[`a] >>

Subtype of C<< ArrayRef[A] >> encodes always to list of all elements type A.

=item C<< Maybe >>

C<< Maybe >> encodes to undef if value is undef.

=item C<< Optional[`a] >>

C<< Dict[name => Str, id => Optional[Int]] >> allows C<< { name => "Bob" } >>
but not C<< { name => "Bob", id => "BOB" } >>.

=back

=head1 SEE ALSO

L<JSON::XS>

L<JSON::Types>

L<Types::Standard>

=head1 LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kfly8 E<lt>kfly@cpan.orgE<gt>

=cut

