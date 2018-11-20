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
