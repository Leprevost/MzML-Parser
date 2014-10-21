package MzML::DataProcessing;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;
use MzML::SoftwareRef;

has 'id' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'softwareRef' => (
    is  =>  'rw',
    isa =>  'MzML::SoftwareRef',
    default => sub {
        my $self = shift;
        return my $obj = MzML::SoftwareRef->new();
        }
    );

has 'processingMethod' => (
    is  =>  'rw',
    isa =>  'ArrayRef[MzML::ProcessingMethod]',
    );

1;
