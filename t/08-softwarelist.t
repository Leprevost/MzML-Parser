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

cmp_ok( $res->softwareList->count, '==', "2", "software list count" );

cmp_ok( $res->softwareList->software->[0]->id, 'eq', "Xcalibur", "software id");

cmp_ok( $res->softwareList->software->[0]->softwareParam->accession, 'eq', "MS:1000532", "software param");

