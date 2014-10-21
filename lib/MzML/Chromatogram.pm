package MzML::Chromatogram;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;
use MzML::BinaryDataArrayList;

with 'MzML::CommonParams';

has 'dataProcessingRef' => (
    is  =>  'rw ',
    isa =>  'Str',
    );

has 'defaultArrayLength' => (
    is  =>  'rw',
    isa =>  'Int',
    );

has 'id' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'index' => (
    is  =>  'rw',
    isa =>  'Int',
    );

has 'nativeID' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'binaryDataArrayList' => (
    is  =>  'rw',
    isa =>  'MzML::BinaryDataArrayList',
    default => sub {
        my $self = shift;
        return my $obj = MzML::BinaryDataArrayList->new();
        }
    );

1;
