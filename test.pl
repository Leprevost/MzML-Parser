#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Felipe da Veiga Leprevost (Leprevost, F.V.), leprevost@cpan.org
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 19-10-2014 09:38:02
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use v5.12;
use utf8;
use lib 'lib';
use MzML::Parser;
use DDP;

my $p = MzML::Parser->new();

my $res = $p->parse("t/miape_sample.mzML");
