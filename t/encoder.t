use strict;
use warnings;
use Test::More;

use JSON::Encode;
use Types::Standard -types;

my @test = (
    [ Str, 'hello', '"hello"' ],
    [ Str, 123, '"123"' ],

    [ Num, 123, '123' ],
    [ Num, '123', '123' ],

    [ Bool, 123, 'true' ],
    [ Bool, 1, 'true' ],
    [ Bool, !!1, 'true' ],
    [ Bool, \0, 'true' ], # CAUTION: \0 is true.
    [ Bool, 0, 'false' ],
    [ Bool, !!0, 'false' ],

    [ Dict[name => Str], { name => 'hello' }, '{"name":"hello"}' ],
    [ Dict[name => Maybe[Str]], { name => 'hello' }, '{"name":"hello"}' ],
    [ Dict[name => Maybe[Str]], { name => undef }, '{"name":null}' ],

    [ Dict[age => Int], { age => 123 }, '{"age":123}' ],
    [ Dict[age => Int], { age => '123' }, '{"age":123}' ],
    [ Dict[age => Maybe[Int]], { age => 123 }, '{"age":123}' ],
    [ Dict[age => Maybe[Int]], { age => undef }, '{"age":null}' ],
 
    [ Dict[fg => Bool], { fg => 1 }, '{"fg":true}' ],
    [ Dict[fg => Bool], { fg => '1' }, '{"fg":true}' ],
    [ Dict[fg => Bool], { fg => \1 }, '{"fg":true}' ],
    [ Dict[fg => Maybe[Bool]], { fg => 1 }, '{"fg":true}' ],
    [ Dict[fg => Maybe[Bool]], { fg => undef }, '{"fg":null}' ],


    [ Dict[fg => Bool], { fg => 0 }, '{"fg":false}' ],
    [ Dict[fg => Bool], { fg => '0' }, '{"fg":false}' ],
    [ Dict[fg => Bool], { fg => \0 }, '{"fg":true}' ],
    [ Dict[fg => Maybe[Bool]], { fg => 0 }, '{"fg":false}' ],
    [ Dict[fg => Maybe[Bool]], { fg => undef }, '{"fg":null}' ],
 
    [ ArrayRef[Int], [1,2], '[1,2]' ],
    [ ArrayRef[Int], ['1','2'], '[1,2]' ],
    [ ArrayRef[Int], ['1',2], '[1,2]' ],
    [ ArrayRef[Int], [1,'2'], '[1,2]' ],
    [ ArrayRef[Maybe[Int]], [1,2], '[1,2]' ],
    [ ArrayRef[Maybe[Int]], [1,undef], '[1,null]' ],
    [ ArrayRef[Maybe[Int]], [undef,2], '[null,2]' ],

    [ Tuple[Int, Str], [1,2], '[1,"2"]' ],
    [ Tuple[Int, Str], ['1','2'], '[1,"2"]' ],
    [ Tuple[Int, Str], ['1',2], '[1,"2"]' ],
    [ Tuple[Int, Str], [1,'2'], '[1,"2"]' ],
    [ Tuple[Maybe[Int], Str], [1,2], '[1,"2"]' ],
    [ Tuple[Maybe[Int], Str], [undef,2], '[null,"2"]' ],

    # complex case:
    [ 
        Dict[
            page => Int,
            list => ArrayRef[Dict[name => Str, num => Num]]
        ],
        {
            page => 123,
            list => [
                { name => 'foo', num => 1.2 },
                { name => 'bar', num => 3.4 },
            ]
        },
        '{"list":[{"name":"foo","num":1.2},{"name":"bar","num":3.4}],"page":123}',
    ],

    [
        Dict[
            tuple => Tuple[Int, Str, ArrayRef[Str]],
        ],
        {
            tuple => [123, "foo", ["a", "b", "c"]],
        },
        '{"tuple":[123,"foo",["a","b","c"]]}'
    ],

);

for (@test) {
    my ($type, $obj, $json_str) = @$_;
    my $json = JSON::Encode->new;
    my $code = $json->encoder($type);

    my $r = is $code->($obj), $json_str, $type->display_name;

    unless ($r) {
        note 'object:';
        note explain $obj;
    }
}

done_testing;
