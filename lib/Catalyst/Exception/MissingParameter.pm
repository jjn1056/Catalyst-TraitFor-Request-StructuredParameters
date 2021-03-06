package Catalyst::Exception::MissingParameter;

use Moose;
use namespace::clean -except => 'meta';

extends 'Catalyst::Exception::StructuredParameter';

has 'param' => (is=>'ro', required=>1);

sub error { "Required parameter '@{[ $_[0]->param ]}' is missing." }
 
__PACKAGE__->meta->make_immutable;
