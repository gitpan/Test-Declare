use strict;
use warnings;
use Test::Declare;

plan tests => blocks;

describe 'prints_ok test' => run {
    test 'test block' => run {
        prints_ok(sub {print 'foo'}, 'foo');
    };
};

