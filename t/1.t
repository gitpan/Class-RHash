package t::Class;

use Test::More tests => 16;

BEGIN { use_ok base => 'Class::RHash' }

my $s = __PACKAGE__->attrs(
    scalar => "hello",
    array  => [qw/hello world/],
    hash   => {qw/hello world/},
);

is ref $s, __PACKAGE__, "create object";
is $s->scalar, "hello", "scalar";
is $s->scalar("world"), "world", "set scalar";

is ref $s->array, 'ARRAY', 'get array in scalar ctx';
my @a = $s->array;
is $a[1], 'world', 'get array in list ctx';
@a = $s->array(qw/1 2 3/);
is @a, 5, 'push array';
@a = $s->array([qw/1 2 3/]);
is @a, 3, 'set array';

is ref $s->hash, 'HASH', 'get hash in scalar ctx';
my %h = $s->hash;
is $h{hello}, 'world', 'get hash in list ctx';
is $s->hash('hello'), 'world', 'get hash elem';
$s->hash(foo => 'bar');
is $s->hash('foo'), 'bar', 'set hash elem';
is $s->hash('hello'), 'world', 'set hash elem only';
%h = $s->hash({foo => 'bar'});
ok !exists $h{hello}, 'set whole hash';

$s->hash(array => []);
$s->hash(array => qw/hello world/);
@a = $s->hash('array');
is $a[1], 'world', 'arrayref as hash elem';

$s->hash(hash => {qw/hello world/});
is $s->hash('hash', 'hello'), 'world', 'hashref as hash elem';
