package MzML::Registry;

use strict;
use warnings;
use v5.12;
use Moose;
use namespace::autoclean;
use MzML::FileDescription;
use MzML::ReferenceableParamGroupList;
use MzML::SampleList;
use MzML::InstrumentConfigurationList;

has 'mzML' => (
    is  =>  'rw',
    isa =>  'MzML::MzML',
    );

has 'cvlist' => (
    is  =>  'rw',
    isa =>  'MzML::CvList',
    );

has 'fileDescription' => (
    is  =>  'rw',
    isa =>  'MzML::FileDescription',
    default => sub {
        my $self = shift;
        return my $obj = MzML::FileDescription->new();
        }
    );

has 'referenceableParamGroupList' => (
    is  =>  'rw',
    isa =>  'MzML::ReferenceableParamGroupList',
    default => sub {
        my $self = shift;
        return my $obj = MzML::ReferenceableParamGroupList->new();
        }
    );

has 'sampleList' => (
    is  =>  'rw',
    isa =>  'MzML::SampleList',
    default => sub {
        my $self = shift;
        return my $obj = MzML::SampleList->new();
        }
    );

has 'instrumentConfigurationList' => (
    is  =>  'rw',
    isa =>  'MzML::InstrumentConfigurationList',
    default => sub {
        my $self = shift;
        return my $obj = MzML::InstrumentConfigurationList->new();
        }
    );

1;
