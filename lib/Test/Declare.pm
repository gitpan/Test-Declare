package Test::Declare;
use strict;
use warnings;
use base 'Exporter';

our $VERSION = '0.04';

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
use Test::Warn;
use Test::Output;
use Test::Deep;

my @test_wrapper_method = qw(
    cmp_ok ok dies_ok throws_ok
    is isnt is_deeply like unlike
    isa_ok cmp_deeply re cmp_bag
    prints_ok stderr_ok
    warning_like warnings_like warning_is warnings_are
    stdout_is stdout_isnt stdout_like stdout_unlike
    stderr_is stderr_isnt stderr_like stderr_unlike
    combined_is combined_isnt combined_like combined_unlike
    output_is output_isnt output_like output_unlike
);

my @test_method = (@test_wrapper_method, @test_more_method);

our @EXPORT = (@test_more_exports, @test_wrapper_method, qw/
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
        *{"Test::Declare::${sub}"} = sub (&) {
            goto $_[0];
        };
    }
}

sub run (&) { $_[0] } ## no critic

sub describe ($$) { ## no critic
    goto $_[1];
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
        *{"Test::Declare::${sub}"} = sub ($$;$) {
            push @_, $test_block_name if @_ == 2;
            goto \&{"Test::More::${sub}"};
        }
    }

}

sub cmp_ok ($$$;$) { ## no critic
    push @_, $test_block_name if @_ == 3;
    goto \&Test::More::cmp_ok;
}

sub ok ($;$) { ## no critic
    push @_, $test_block_name if @_ == 1;
    goto \&Test::More::ok;
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

=head1 SEE ALSO

This test module's core modules

L<Test::More> and L<Test::Exception> and L<Test::Deep> and L<PPI>

Test::Declare's sample tests

L<DBIx::Class::TableNames> 's 01_table_names.t

L<DBIx::Class::ProxyTable> 's 01_proxy.t

=head1 AUTHORS

Atsushi Kobayashi  C<< <nekokak __at__ gmail.com> >>
tokuhirom

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Atsushi Kobayashi C<< <nekokak __at__ gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

