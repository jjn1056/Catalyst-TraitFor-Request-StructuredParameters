package Catalyst::Plugin::StructuredParameters;

our $VERSION = '0.001';

use Moose::Role;
use Scalar::Util;

sub structured_body { return shift->req->structured_body(@_) }
sub structured_data { return shift->req->structured_data(@_) }
sub structured_query { return shift->req->structured_query(@_) }

sub isa_structured_parameter_exception {
  my ($self, $obj) = @_;
  return 0 unless Scalar::Util::blessed($obj);
  return $obj->isa('Catalyst::Exception::StructuredParameter') ? 1:0;
}

around request_class_traits => sub {
  my ($orig, $self, @args) = @_;
  my $traits = $self->$orig(@args);
  return [ @{$traits||[]}, 'Catalyst::TraitFor::Request::StructuredParameters' ];
};

1;

=head1 NAME

Catalyst::Plugin::StructuredParameters - Plug to add the structured parameter request trait plus proxy methods

=head1 SYNOPSIS

  package MyApp;
  use Catalyst 'StructuredParameters';
  
  MyApp->setup;

  package MyApp::Controller::Root;

  sub body :Local {
    my ($self, $c) = @_;
    my %clean = $c->structured_body
      ->permitted(['person'], +{'email' => []})
      ->namespace(['person'])
      ->permitted(
          'name',
          'age',
          'address' => ['street' => ['number', 'zip'],
          +{'credit_cards' => [
              'number',
              'exp' => [qw/year month day/],
          ]},
      )->to_hash;

    ## Do something with the sanitized body parameters
  }

  ## Don't forget to add code to handle any exceptions

  sub end :Action {
    my ($self, $c) = @_;
    if(my $error = $c->last_error) {
      $c->clear_errors; ## Clear the error stack unless you want the default Catalyst error
      if($c->isa_strong_parameter_exception($error)) {
        ## Something here like return a Bad Request 4xx view or similar.
      }
    }
  }

  ## Alternatively handle with L<CatalystX::Errors> (don't forget to add the plugin to your 
  ## application class.)
  
  sub end :Action Does(RenderErrors) { }

You should review L<Catalyst::TraitFor::Request::StrongParameters> for a more detailed SYNOPSIS and
explanation of how all this works.

=head1 DESCRIPTION

This plugin will add in the L<Catalyst::TraitFor::Request::StructuredParameters> request class trait 
and proxy some of its methods to the context. You might find this a bit less typing.

All the main documentation is in L<Catalyst::TraitFor::Request::StructuredParameters>.

NOTE: This plugin only works with For L<Catalyst> v5.90090 or greater.  If you must use an older
version of L<Catalyst> you'll need to use the workaround described in the SYNOPSIS of
L<Catalyst::TraitFor::Request::StructuredParameters>.

=head1 METHODS

This role defines the following methods:

=head2 structured_body

=head2 structured_data

=head2 structured_query

These just proxy to the same methods under the L<Catalyst::Request> object.

=head2 isa_structured_parameter_exception

This is just a convenience method that returns true if a possible exception is both a blessed
object and ISA L<Catalyst::Exception::StructuredParameter>.  Since you need to add checking for
this everytime I added this method to save a bit of trouble.

=head1 AUTHOR

See L<Catalyst::TraitFor::Request::StructuredParameters>

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::TraitFor::Request::StructuredParameters>

=head1 COPYRIGHT & LICENSE

See L<Catalyst::TraitFor::Request::StructuredParameters>

=cut
