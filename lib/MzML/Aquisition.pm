package MzML::Aquisition;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;

with 'MzML::CommonParams';

has 'externalNativeID' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'externalSpectrumID' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'number' => (
    is  =>  'rw',
    isa =>  'Int',
    );

has 'sourceFileRef' => (
    is  =>  'rw',
    isa =>  'Str',
    );

has 'spectrumRef' => (
    is  =>  'rw',
    isa =>  'Str',
    );

1;
