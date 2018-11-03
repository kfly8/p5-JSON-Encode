[![Build Status](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder.svg?branch=master)](https://travis-ci.org/kfly8/p5-JSON-TypeEncoder) [![Coverage Status](https://img.shields.io/coveralls/kfly8/p5-JSON-TypeEncoder/master.svg?style=flat)](https://coveralls.io/r/kfly8/p5-JSON-TypeEncoder?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/JSON-TypeEncoder.svg)](https://metacpan.org/release/JSON-TypeEncoder)
# NAME

JSON::TypeEncoder - It's new $module

# SYNOPSIS

```perl
use JSON::TypeEncoder;
use Types::Standard -types;

my $type = Dict[name => Str, age => Int];

my $json = JSON::TypeEncoder->new;
my $code = $json->encoder($type);

$code->({ name => 'Perl', age => 30 });
```

# DESCRIPTION

JSON::TypeEncoder is ...

# LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kfly8 <kfly@cpan.org>
