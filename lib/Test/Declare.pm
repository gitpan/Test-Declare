package Test::Declare;
use strict;
use warnings;
use base 'Exporter';

our $VERSION = '0.02';

my @test_more_exports;
my @test_more_method;
BEGIN {
    @test_more_method = qw(
        use_ok require_ok
        eq_array eq_hash eq_set
        can_ok
    );
    @test_more_exports = (qw(
        skip todo todo_skip
        pass fail
        plan
        diag
        BAIL_OUT
        $TODO
    ),@test_more_method);
}

use Test::More import => \@test_more_exports;
use Test::Exception;
use Test::Deep;

my @test_wrappe_method = qw(
    is_deeply_array cmp_ok ok dies_ok throws_ok
    is isnt is_deeply like unlike
    isa_ok cmp_deeply re
    prints_ok stderr_ok
);

my @test_method = (@test_wrappe_method, @test_more_method);

our @EXPORT = (@test_more_exports, @test_wrappe_method, qw/
    init cleanup run test describe blocks
/);

my $test_block_name;
sub test ($$) { ## no critic
    $test_block_name = shift;
    shift->();
}

{
    no strict 'refs'; ## no critic
    for my $sub (qw/init cleanup/) {
        *{"Test\::Declare\::$sub"} = sub (&) {
            shift->();
        };
    }
}

sub run (&) { shift } ## no critic

sub describe ($$) { ## no critic
    shift; shift->();
}

use PPI;
sub PPI::Document::find_test_blocks {
    my $self = shift;
    my $blocks = $self->find(
        sub {
            $_[1]->isa('PPI::Token::Word')
            and
            grep { $_[1]->{content} eq $_ } @test_method
        }
    )||[];
    return @$blocks
}
sub blocks {
    my @caller = caller;
    my $file = $caller[1];
    my $doc = PPI::Document->new($file) or die $!;
    return scalar( $doc->find_test_blocks );
}

## Test::More wrapper
{
    no strict 'refs'; ## no critic
    for my $sub (qw/is is_deeply like isa_ok isnt unlike/) {
        *{"Test\::Declare\::$sub"} = sub ($$;$) {
            my ($actual, $expected, $name) = @_;
            my $test_more_code = "Test\::More"->can($sub);
            goto $test_more_code, $actual, $expected, $name||$test_block_name;
        }
    }

}

sub cmp_ok ($$$;$) { ## no critic
    my ($actual, $operator, $expected, $name) = @_;
    my $test_more_code = "Test\::More"->can('cmp_ok');
    goto $test_more_code, $actual, $operator, $expected, $name||$test_block_name;
}

sub ok ($;$) { ## no critic
    my ($test, $name) = @_;
    my $test_more_code = "Test\::More"->can('ok');
    goto $test_more_code, $test, $name||$test_block_name;
}

## original method
sub is_deeply_array ($$;$) { ## no critic
    my ($actual, $expected, $name) = @_;
    is_deeply( [sort { $a cmp $b } @{$actual}], [sort { $a cmp $b } @{$expected}], $name);
}

use IO::Scalar;
sub prints_ok (&$;$) { ## no critic
    my ($code, $expected, $name) = @_;

    tie *STDOUT, 'IO::Scalar', \my $stdout;
        $code->();
        like($stdout, qr/$expected/, $name||$test_block_name);
    untie *STDOUT;
}
sub stderr_ok (&$;$) { ## no critic
    my ($code, $expected, $name) = @_;

    tie *STDERR, 'IO::Scalar', \my $stderr;
        $code->();
        like($stderr, qr/$expected/, $name||$test_block_name);
    untie *STDERR;
}

1;

__END__
=head1 NAME

Test::Declare - declarative testing

=head1 SYNOPSIS

    use strict;
    use warnings;
    use Test::Declare;
    plan tests => blocks;
    
    describe 'foo bar test' => run {
        init {
            # init..
        };
        test 'foo is bar?' => run {
            is foo, bar;
        };
        cleanup {
            # cleanup..
        };
    };

=head1 DESCRIPTION

Test::More and Test::Exception and Test::Deep wrapper module.

=head1 METHOD

=head2 describe
    outline setting.

=head2 blocks
    get test block count.

=head2 init
    definition of init block.

=head2 test
    definition of test block.

=head2 run
    run test code.

=head2 cleanup
    definition of cleanup block.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

Atsushi Kobayashi  C<< <nekokak __at__ gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Atsushi Kobayashi C<< <nekokak __at__ gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

