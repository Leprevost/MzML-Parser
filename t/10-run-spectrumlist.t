#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use lib 'lib';
use MzML::Parser;

plan tests => 3;

my $p = MzML::Parser->new();
my $res = $p->parse("t/miape_sample.mzML");

cmp_ok( $res->run->spectrumList->spectrum->[47]->precursorList->precursor->[0]->spectrumRef, 'eq', "controllerType=0 controllerNumber=1 scan=43", "precursor spectrumRef" );

cmp_ok( $res->run->spectrumList->spectrum->[47]->precursorList->precursor->[0]->selectedIonList->selectedIon->[0]->cvParam->[0]->value, 'eq', "882.53999999999996", "selectedionlist cvparam value" );

cmp_ok( $res->run->spectrumList->spectrum->[47]->binaryDataArrayList->binaryDataArray->[0]->encodedLength, '==', "3048", "binary encoded length" );

