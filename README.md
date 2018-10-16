# NAME

JSON::TypeEncoder - It's new $module

# SYNOPSIS

    use JSON::TypeEncoder;
    use Types::Standard -types;

    my $type = Dict[name => Str, age => Int];

    my $json = JSON::TypeEncoder->new;
    my $code = $json->encoder($type);

    $code->({ name => 'Perl', age => 30 });

# DESCRIPTION

JSON::TypeEncoder is ...

# LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kfly8 <kfly@cpan.org>
