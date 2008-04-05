use strict;
use warnings;
use Test::Declare;

plan tests => blocks;

describe 'stderr test' => run {
    test 'test block' => run {
        stderr_ok(sub {print STDERR 'foo'}, 'foo');
    };
};

