use strict;
use warnings;
use Test::Declare;

plan tests => blocks;

describe 'Test::More wrapper test' => run {
    test 'is' => run {
        is 'foo', 'foo';
    };
    test 'is_deeply' => run {
        is_deeply {foo => 'bar'} ,{foo => 'bar'};
    };
    test 'like' => run {
        like 'Fooooooooo', qr/Foo/;
    };
    test 'is_deeply_array' => run {
        is_deeply_array  [qw/3 2 1 4 5/], [qw/5 4 3 2 1/];
    };
    test 'cmp_ok' => run {
        cmp_ok 'foo', 'eq' , 'foo';
    };
    test 'ok' => run {
        ok 'foo' eq 'foo';
    };
    test 'isnt' => run {
        isnt 'foo', 'bar';
    };
    test 'unlike' => run {
        unlike 'Fooooooo', qr/Bar/;
    };
};

describe 'Test::More method test' => run {
    test 'use_ok' => run {
        use_ok 'Test::Deep';
    };
    test 'require_ok' => run {
        require_ok 'Test::Exception';
    };
};

