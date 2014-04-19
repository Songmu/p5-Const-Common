package Const::Common;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

require Exporter;
use Data::Lock;

sub import {
    my $pkg   = caller;
    shift;
    my %constants = @_ == 1 ? %{ $_[0] } : @_;

    Data::Lock::dlock my $locked = \%constants;
    {
        no strict 'refs';
        ${ "$pkg\::constants" } = $locked;
        for my $key (keys %$locked) {
            my $value = $locked->{$key};
            *{ "$pkg\::$key" } = sub () { $value };
        }

        for my $method (qw/const constants constant_names/) {
            *{ "$pkg\::$method" } = \&{ __PACKAGE__ . "::$method" };
        }

        push @{"$pkg\::ISA"}, ('Exporter');
        push @{"$pkg\::EXPORT"}, (keys %$locked);
    }
}

sub const {
    my ($pkg, $constant_name) = @_;
    $pkg->constants->{$constant_name};
}

sub constants {
    no strict 'refs';
    my $pkg = shift;
    ${ "$pkg\::constants" };
}

sub constant_names {
    my $pkg = shift;
    sort keys %{ $pkg->constants };
}

1;
__END__

=encoding utf-8

=head1 NAME

Const::Common - It's new $module

=head1 SYNOPSIS

    use Const::Common;

=head1 DESCRIPTION

Const::Common is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut

