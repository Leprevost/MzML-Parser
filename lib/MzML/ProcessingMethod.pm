package MzML::ProcessingMethod;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;

with 'MzML::CommonParams';

has 'order' => (
    is  =>  'rw',
    isa =>  'Int',
    );

has 'softwareRef' => (
    is  =>  'rw',
    isa =>  'Str',
    );

1;
