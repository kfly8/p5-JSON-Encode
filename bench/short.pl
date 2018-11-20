use Benchmark qw(cmpthese);

use JSON::TypeEncoder;
use Types::Standard -types;
use JSON::XS ();
use JSON::PP ();
use JSON::Types;

# http://dist.schmorp.de/misc/json/short.json
my $data = {
    'id' => undef,
    'params' => [
                'user1',
                'we were just talking'
              ],
    'array' => [
               1,
               11,
               234,
               -5,
               1e5,
               1e7,
               1,
               0
             ],
    'method' => 'handleMessage'
};

my $type = Dict[
    id     => Maybe[Int],
    params => ArrayRef[Str],
    array  => ArrayRef[Num],
    method => Str,
];

my $jsont = JSON::TypeEncoder->new;
my $encode = $jsont->encoder($type);

cmpthese -1, {
    'JSON::XS'          => sub { JSON::XS::encode_json($data) },
    'JSON::PP'          => sub { JSON::PP::encode_json($data) },
    'JSON::TypeEncoder' => sub { $encode->($data) },
    'JSON::XS w/ Types' => sub {
        JSON::XS::encode_json({
            'id' => undef,
            'params' => [
                        string 'user1',
                        string 'we were just talking'
                      ],
            'array' => [
                       number 1,
                       number 11,
                       number 234,
                       number -5,
                       number 1e5,
                       number 1e7,
                       number 1,
                       number 0
                     ],
            'method' => string 'handleMessage'
        })
    },
};

#                       Rate JSON::PP JSON::XS w/ Types JSON::TypeEncoder JSON::XS
# JSON::PP           39739/s       --              -83%              -90%     -95%
# JSON::XS w/ Types 234056/s     489%                --              -42%     -72%
# JSON::TypeEncoder 405736/s     921%               73%                --     -51%
# JSON::XS          825118/s    1976%              253%              103%       --
