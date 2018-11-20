[![Build Status](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder.svg?branch=master)](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder) [![Coverage Status](https://img.shields.io/coveralls/kfly8/p5-JSON-TypeEncoder/master.svg?style=flat)](https://coveralls.io/r/kfly8/p5-JSON-TypeEncoder?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/JSON-TypeEncoder.svg)](https://metacpan.org/release/JSON-TypeEncoder)
# NAME

JSON::TypeEncoder - serialize JSON using type information

# SYNOPSIS

```perl
use JSON::TypeEncoder;
use Types::Standard -types;

my $type = Dict[name => Str, age => Int];

my $json = JSON::TypeEncoder->new;
my $encode = $json->encoder($type);

$encode->({ name => 'Perl', age => 30 });
# => {"age":30,"name":"Perl"}
```

# DESCRIPTION

JSON::TypeEncoder serialize Perl data structures to JSON using type information.
This module goal is to be **correct** and **fast**.

## FEATURES

### Correct

This module encodes according to the specified type information.
For example, it encodes as following:

```perl
use JSON::TypeEncoder;
use Types::Standard -types;

my $e = JSON::TypeEncoder->new;

my $s = $e->encoder(Dict[str => Str]);
$s->({str => 123}); # => {"str":"123"}

my $i = $e->encoder(Dict[int => Int]);
$i->({int => '456'}); # => {"int":456}

my $b = $e->encoder(Dict[fg => Bool]);
$b->({fg => !!0}); # => {"fg":false}
```

This will prevent unintended encoding.

### Fast

Encoding performance is improved by string eval using type information.
You can get speed comparable to JSON::XS. The results of a simple benchmark is as following:

```perl
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
```

### Pure Perl

This module is written by pure Perl. So you can easily install it.

## TYPE SPECIFICATION

[Types::Standard](https://metacpan.org/pod/Types::Standard) is used for type specification.
The basic types are as follows, you can specify the type of JSON by this combination.

### Example

```perl
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
```

### Basic Types

- `Str`

    Subtype of `Str` type encodes always to string.

- `Num`

    Subtype of `Num` type encodes always to number.

- `Bool`

    Subtype of `Bool` type encodes always to boolean.

- `Dict[...]`

    Subtype of `Dict[...]` encodes always to map.

- `Tuple[...]`

    Subtype of `Tuple[A, B]` encodes always to list of type A and B.

- `` ArrayRef[`a] ``

    Subtype of `ArrayRef[A]` encodes always to list of all elements type A.

- `Maybe`

    `Maybe` encodes to undef if value is undef.

- `` Optional[`a] ``

    `Dict[name => Str, id => Optional[Int]]` allows `{ name => "Bob" }`
    but not `{ name => "Bob", id => "BOB" }`.

# SEE ALSO

[JSON::XS](https://metacpan.org/pod/JSON::XS)

[JSON::Types](https://metacpan.org/pod/JSON::Types)

[Types::Standard](https://metacpan.org/pod/Types::Standard)

# LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kfly8 <kfly@cpan.org>
