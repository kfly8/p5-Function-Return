use strict;
use warnings;
use Test::More;
use Test::Fatal;
use B::Hooks::EndOfScope;

# 1. 
use Function::Return;

# 2.
BEGIN {
    on_scope_end {
        # The subroutine `foo` is defined after this BEGIN clause,
        # but the meta information can be retrieved.
        my $meta = Function::Return::Meta->get(\&foo);
        isa_ok $meta, 'Sub::Meta';
    }
};

# 3.
sub foo :Return() { '123' }

like exception { foo() }, qr/^Too many return values for fun foo/;

done_testing;
