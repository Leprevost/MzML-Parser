package MzML::SpectrumList;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;

has 'count' => (
    is  =>  'rw',
    isa =>  'Int',
    );

has 'spectrum' => (
    is  =>  'rw',
    isa =>  'ArrayRef[MzML::Spectrum]',
    );

1;
