package Class::RHash;

use strict;
use warnings;

use Carp;
use Hash::Util qw/lock_keys unlock_keys/;
use NEXT;

our $VERSION = "0.02";

=head1 NAME

Class::RHash - objects based on a restricted hash

=head1 SYNOPSIS

    package My::Class;

    use base qw/Class::RHash/;

    sub new {
        my $c = shift;
	return $c->attrs(
	    scalar => "hello world",
	    array  => [ "hello", "world" ],
	    hash   => { hello => "world" },
	);
    }

    package main;

    my $obj = My::Class->new;
    
    print $obj->scalar;
    print ( $obj->array )[1];
    print $obj->hash("hello");

    $obj->scalar("foobar");
    $obj->array("foo", "bar");    # pushes onto the array
    $obj->array(["foo", "bar"]);  # sets the array
    $obj->hash( foo => "bar" );   # changes a key
    $obj->hash( {foo => "bar"} ); # sets all keys

=head1 DESCRIPTION

Creates objects based on a restricted hash, with intelligent AUTOLOADed 
accessor methods. You should use this as a base class.

=head1 METHODS

=head2 attrs

Sets and gets the allowed attributes of the object (keys of the hash).

=over 4

=cut

sub attrs {
    my $s = shift;

=item $obj->attrs

Returns a list of the attributes of the object.

=cut

    ref $s and not @_ and return keys %$s;
    
=item Class->attrs(foo => "bar")

Creates a new object with the given attributes. The type of each
attribute (scalar, arrayref or hashref) will be fixed.

=item $obj->attrs(foo => "bar")

Adds attributes to an existing object. This is to construct objects
in subclasses, e.g.

    sub new {
        my $c = shift;
	my $s = $c->SUPER::new();
	return $s->attrs(
	    new => "attrs",
	);
    }

. Croaks if any of the given attrs exist already, to help prevent
classes treading on each other.

=cut

    $s = ref $s ? $s : bless {}, $s;
    unlock_keys %$s;

    while (my $k = shift) {
        my $v = shift;
	exists $s->{$k} and croak qq{attribute "$k" already exists};
	$s->{$k} = $v;
    }

    lock_keys %$s;
    return $s;
}

our $AUTOLOAD;

=back

=head2 AUTOLOAD

Provides accessors for the elements of the hash. Attempts to call a
method which does not have a corresponding key in the hash will pass the
call to NEXT::ACTUAL::AUTOLOAD (see L<NEXT>).

The behaviour of the method depends on whether the value of the attribute
is a hashref, an arrayref or some other type of scalar. In the descriptions
below, {} refers to a hashref argument, [] to an arrayref and "" to some
other scalar.

=over 4

=cut

sub AUTOLOAD {
    my $s = shift;
    
    ref $s and UNIVERSAL::isa $s, __PACKAGE__
    	or $s->NEXT::ACTUAL::AUTOLOAD(@_);

    (my $attr = $AUTOLOAD) =~ s/.*:://;

    unlock_keys %$s;
    exists $s->{$attr} or $s->NEXT::ACTUAL::AUTOLOAD(@_);
    lock_keys %$s;

    my $value = \($s->{$attr});

new_value:

=item Hashref values

=over 4

=cut

    if (ref $$value eq 'HASH') {

        if (@_) {
	    my $k = shift;
	    
=item $obj->hash( {} )

Sets all the keys in the hash to those given. Returns the new
value, as a list in list context or a hashref in scalar context.

=cut

            if (ref $k eq 'HASH') {
	        $$value = { %$k };
	    }

=item $obj->hash( "" )

Returns the entry in the hash with the given key.

=item $obj->hash( "", ... )

Sets or gets the entry in the hash with the given key. What happens depends
on its type, in the same way as for attributes; so if the value is an
arrayref, a scalar will be pushed or an arrayref will set the whole thing;
if the value is a hashref then C<< $obj->hash( "key1", "key2" ) >> will
return C<< $obj->{key1}{key2} >>; &c.

=cut
	    
            else {
	        $value = \( $$value->{$k} );
		goto new_value;
	    }
        }

=item $obj->hash

Returns the whole hash, as a list in list context or a hashref in 
scalar context.

=cut
	
        return wantarray ? %$$value : $$value;
    }

=back

=item Arrayref values

These always return the (new) array, as a list in list context or
an arrayref in scalar context.

=over 4

=item $obj->array( [] )

Sets the whole array.

=item $obj->array( "", ... )

Pushes values onto the array.

=item $obj->array

Just returns the array.

=cut
	
    if (ref $$value eq 'ARRAY') {

        if (@_) {
           ref $_[0] eq 'ARRAY'   ?
           $$value = [ @{$_[0]} ] :
           push @$$value, @_;
        }

        return wantarray ? @$$value : $$value;
    }

=back

=item Other scalar values

=over 4

=item $obj->scalar

Returns the value.

=item $obj->scalar( "" )

Sets and returns the new value.

=back

=back

=cut
    
    else {
        @_ and $$value = shift;
        return $$value;
    }
}

=head1 SEE ALSO

L<Hash::Util|Hash::Util>

=head1 AUTHOR

Ben Morrow E<lt>Class-RHash@morrow.me.ukE<gt>

=head1 COPYRIGHT

Copyright (c) 2004 Ben Morrow

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
