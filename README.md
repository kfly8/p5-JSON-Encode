[![Build Status](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder.svg?branch=master)](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder) [![Coverage Status](https://img.shields.io/coveralls/kfly8/p5-JSON-TypeEncoder/master.svg?style=flat)](https://coveralls.io/r/kfly8/p5-JSON-TypeEncoder?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/JSON-TypeEncoder.svg)](https://metacpan.org/release/JSON-TypeEncoder)
# NAME

JSON::TypeEncoder - serialize JSON using type information

# SYNOPSIS

```perl
use JSON::TypeEncoder;
use Types::Standard -types;

my $type = Dict[a => Str, b => Int, c => Bool];

my $jsont = JSON::TypeEncoder->new;
my $encode = $jsont->encoder($type);

$encode->({ a => 'foo', b => 30, c => !!1 });
# => {"a":"foo","b":30,"c":true}
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

my $jsont = JSON::TypeEncoder->new;

my $s = $jsont->encoder(Dict[a => Str]);
$s->({a => 123}); # => {"a":"123"}

my $i = $jsont->encoder(Dict[a => Int]);
$i->({a => 123}); # => {"a":123}

my $b = $jsont->encoder(Dict[a => Bool]);
$b->({a => !!0}); # => {"a":false}
```

This will prevent unintended encoding.

### Fast

Encoding performance is improved by string eval using type information.
You can get speed comparable to JSON::XS. The results of a simple benchmark is as following.

First comes a comparison using a very short single-line JSON string (also available at http://dist.schmorp.de/misc/json/short.json).

```perl
{"method": "handleMessage", "params": ["user1", "we were just talking"], "id": null, "array":[1,11,234,-5,1e5,1e7, 1,  0]}
```

It shows the number of encodes per second. Higher is better:

```
#                       Rate JSON::PP JSON::XS w/ Types JSON::TypeEncoder JSON::XS
# JSON::PP           39739/s       --              -83%              -90%     -95%
# JSON::XS w/ Types 234056/s     489%                --              -42%     -72%
# JSON::TypeEncoder 405736/s     921%               73%                --     -51%
# JSON::XS          825118/s    1976%              253%              103%       --
```

Using a longer test string (roughly 18KB, generated from Yahoo! Locals search API (http://dist.schmorp.de/misc/json/long.json).

```
#                      Rate          JSON::PP          JSON::XS JSON::TypeEncoder
# JSON::PP            984/s                --              -96%              -97%
# JSON::XS          26946/s             2639%                --              -13%
# JSON::TypeEncoder 30919/s             3043%               15%                --
```

### Pure Perl

This module is written by pure Perl. So you can easily install it.

## **NOT** FEATURES

This module NOT supports decode JSON to Perl data structures.
You should use other modules like JSON::XS to decode.

## TYPE SPECIFICATION

[Types::Standard](https://metacpan.org/pod/Types::Standard) is used for type specification.
The basic types are as follows, you can specify the type of JSON by this combination.

### Basic Types

- `Str`

    Subtype of `Str` encodes always to string.

    ```perl
    my $encode = $jsont->encoder(Str);
    $encode->(123) # => "123"
    ```

- `Num`

    Subtype of `Num` encodes always to number.

    ```perl
    my $encode = $jsont->encoder(Num);
    $encode->(123) # => 123
    ```

- `Bool`

    Subtype of `Bool` encodes always to boolean.

    ```perl
    my $encode = $jsont->encoder(Bool);
    $encode->(123) # => true
    ```

- `Dict[...]`

    Subtype of `Dict[...]` encodes always to map.

    ```perl
    my $encode = $jsont->encoder(Dict[a => Int]);
    $encode->({ a => 123 });   # => {"a":123}
    $encode->({ a => '123' }); # => {"a":123}
    ```

- `Tuple[...]`

    Subtype of `Tuple[A, B]` encodes always to list of type A and B.

    ```perl
    my $encode = $jsont->encoder(Tuple[Int, Str]);
    $encode->([123, 456]); # => [123,"456"]
    ```

- `` ArrayRef[`a] ``

    Subtype of `ArrayRef[A]` encodes always to list of all elements type A.

    ```perl
    my $encode = $jsont->encoder(ArrayRef[Bool]);
    $encode->([1,0,undef,!!0,\0]); # => [true,false,false,false,true]
    ```

- `Maybe`

    `Maybe` encodes to undef if value is undef.

    ```perl
    my $encode = $jsont->encoder(Maybe[Str]);
    $encode->('hello'); # => "hello"
    $encode->(undef); # => null
    ```

- `` Optional[`a] ``

    `Dict[name => Str, id => Optional[Int]]` allows `{ name => "Bob" }`
    but not `{ name => "Bob", id => "BOB" }`.

    ```perl
    my $encode = $jsont->encoder(Dict[a => Optional[Str]]);
    $encode->({a => 'foo'}); # => {"a":"foo"}
    $encode->({}); # => {}
    ```

### More Example

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

# CONTRIBUTORS

- karupanerura
