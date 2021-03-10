package DeatAttr;
use Attribute::Handlers;
use Sub::Util qw( subname );

sub UNIVERSAL::Dead :ATTR(CODE) {
    my ($class, $symbol) = @_;

    no strict 'refs';
    no warnings 'redefine';
    *{ $symbol } = sub { die 'Dead!' };
}

1;
