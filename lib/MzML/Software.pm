package MzML::Software;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;
use MzML::SoftwareParam;

has 'id' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'version' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'softwareParam' => (
    is  =>  'rw',
    isa =>  'MzML::SoftwareParam',
    default => sub {
        my $self = shift;
        return my $obj = MzML::SoftwareParam->new();
        }
    );

1;
