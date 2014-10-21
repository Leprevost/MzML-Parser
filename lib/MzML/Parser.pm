package MzML::Parser;

use v5.12;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use MzML::Registry;
use MzML::MzML;
use MzML::Cv;
use MzML::CvList;
use MzML::CvParam;
use MzML::SourceFile;
use MzML::SourceFileList;
use MzML::ReferenceableParamGroupList;
use MzML::ReferenceableParamGroup;
use MzML::SampleList;
use MzML::Sample;
use MzML::InstrumentConfigurationList;
use MzML::InstrumentConfiguration;
use MzML::SoftwareList;
use MzML::Software;
use MzML::SoftwareParam;
use XML::Twig;
use URI;

our $VERSION = '0.01';

my $reg = MzML::Registry->new();

sub parse {
    my $self = shift;
    my $file = shift;

    my %data;

    my $parser = XML::Twig->new(
        twig_handlers =>
        {
            mzML                        =>  \&parse_mzml,
            cvList                      =>  \&parse_cvlist,
            fileContent                 =>  \&parse_filecontent,
            sourceFileList              =>  \&parse_sourcefilelist,
            referenceableParamGroupList =>  \&parse_refparamgroup,
            sampleList                  =>  \&parse_samplelist,
            instrumentConfigurationList =>  \&parse_intrconflist,
            softwareList                =>  \&parse_softwarelist,
        },
        pretty_print => 'indented',
    );

    $parser->parsefile($file);

    return $reg;
}

sub parse_mzml {
    my ($parser, $node) = @_;

    my $mzml = MzML::MzML->new();

    $mzml->version($node->{'att'}->{'version'});
    $mzml->id($node->{'att'}->{'id'}) if defined ($node->{'att'}->{'id'});
    $mzml->accession($node->{'att'}->{'accession'}) if defined ($node->{'att'}->{'accession'});

    $reg->mzML($mzml);
}

sub parse_cvlist {
    my ($parser, $node) = @_;

    my @cv = $node->children;
    my @list;

    for my $el ( @cv ) {
        
        my $cv = MzML::Cv->new();

        $cv->uri(my $uri = URI->new($el->{'att'}->{'URI'}));
        $cv->fullName($el->{'att'}->{'fullName'});
        $cv->id($el->{'att'}->{'id'});
        $cv->version($el->{'att'}->{'version'}) if defined ($el->{'att'}->{'version'});
        
        push(@list, $cv);
    }

    my $cvlist = MzML::CvList->new();
    
    $cvlist->count($node->{'att'}->{'count'});
    $cvlist->cv(\@list);

    $reg->cvlist($cvlist);
}

sub parse_filecontent {
    my ($parser, $node) = @_;

    my @subnodes = $node->children;
    
    for my $el ( @subnodes ) {

        if ( $el->name eq 'cvParam' ) {
            
            my $cvp = get_cvParam($el);
            $reg->fileDescription->fileContent->cvParam($cvp);

        } elsif ( $el->name eq 'referenceableParamGroupRef' ) {

            my $ref = get_referenceableParamGroupRef($el);
            $reg->fileContent->referenceableParamGroupRef($ref);

        } elsif ($el->name eq 'userParam' ) {
            
            my $user = get_userParam($el);
            $reg->fileDescription->fileContent->userParam($user);

        }

    }
}

sub parse_sourcefilelist {
    my ($parser, $node) = @_;
    
    my @subnodes = $node->children;
    my @list;

    for my $el ( @subnodes ) {
        
        my $sf = MzML::SourceFile->new();

        $sf->id($el->{'att'}->{'id'});
        $sf->name($el->{'att'}->{'name'});
        $sf->location($el->{'att'}->{'location'});

        my @undernodes = $el->children;
        
        my @cvparam_list;
        my @reference_list;
        my @user_list;
        
        for my $subel ( @undernodes ) {

            if ( $subel->name eq 'cvParam' ) {
		    
    		    my $cvp = get_cvParam($subel);
                push(@cvparam_list, $cvp);

    		} elsif ( $subel->name eq 'referenceableParamGroupRef' ) {

    		    my $ref = get_referenceableParamGroupRef($subel);
    		    push(@reference_list, $ref);

    		} elsif ($subel->name eq 'userParam' ) {
		    
    		    my $user = get_userParam($subel);
    		    push(@user_list, $user);

	    	}

        }

        $sf->cvParam(\@cvparam_list);
        $sf->referenceableParamGroupRef(\@reference_list);
        $sf->userParam(\@user_list);

        push(@list, $sf);
    }

    my $slist = MzML::SourceFileList->new();

    $slist->count($node->{'att'}->{'count'});
    $slist->sourceFile(\@list);

    $reg->fileDescription->sourceFileList($slist);

}

sub parse_refparamgroup {
    my ($parser, $node) = @_;

    my @subnodes = $node->children;
    my @list;

    for my $el ( @subnodes ) {
        
        my $refgl = MzML::ReferenceableParamGroup->new();

        $refgl->id($el->{'att'}->{'id'});

        my @undernodes = $el->children;

        my @cvparam_list;
        my @user_list;

        for my $subel ( @undernodes ) {

            if ( $subel->name eq 'cvParam' ) {
		    
    		    my $cvp = get_cvParam($subel);
                push(@cvparam_list, $cvp);

    		} elsif ($subel->name eq 'userParam' ) {
		    
    		    my $user = get_userParam($subel);
                push(@user_list, $user);

	    	}

        }
        
        $refgl->cvParam(\@cvparam_list);
        $refgl->userParam(\@user_list);
        push(@list, $refgl);                                       

    }

    my $refg = MzML::ReferenceableParamGroupList->new();

    $refg->count($node->{'att'}->{'count'});
    $refg->referenceableParamGroup(\@list);

    $reg->referenceableParamGroupList($refg);

}

sub parse_samplelist {
    my ($parser, $node) = @_;

    my @subnodes = $node->children;
    my @list;

    for my $el ( @subnodes ) {

        my $sample = MzML::Sample->new();

        $sample->id($el->{'att'}->{'id'});
        $sample->name($el->{'att'}->{'name'}) if defined($el->{'att'}->{'name'});

        my @undernodes = $el->children;
        
        my @cvparam_list;
        my @reference_list;
        my @user_list;

    	for my $subel ( @undernodes ) {

    	    if ( $subel->name eq 'cvParam' ) {

                my $cvp = get_cvParam($subel);
    		    push(@cvparam_list, $cvp);

    		} elsif ( $subel->name eq 'referenceableParamGroupRef' ) {

    		    my $ref = get_referenceableParamGroupRef($subel);
    		    push(@reference_list, $ref);

    		} elsif ($subel->name eq 'userParam' ) {
		    
    		    my $user = get_userParam($subel);
    		    push(@user_list, $user);
    
    	    }

        }

        $sample->cvParam(\@cvparam_list);
        $sample->referenceableParamGroupRef(\@reference_list);
        $sample->userParam(\@user_list);

        push(@list, $sample);
        
    }

    my $sampl = MzML::SampleList->new();

    $sampl->count($node->{'att'}->{'count'});
    $sampl->sample(\@list);

    $reg->sampleList($sampl);

}

sub parse_intrconflist {
    my ($parser, $node) = @_;

    my @subnodes_1 = $node->children;
    my @list;
    my @clist;

    for my $el ( @subnodes_1 ) {
        
        my $ic = MzML::InstrumentConfiguration->new();
        $ic->id($el->{'att'}->{'id'});
        
        my @subnodes_2 = $el->children;

        my $clist;

        my @reference_list;

        my $source;
        my $analyzer;
        my $detector;

        for my $el2 ( @subnodes_2 ) {

    		if ( $el2->name eq 'referenceableParamGroupRef' ) {

    		    my $ref = get_referenceableParamGroupRef($el2);
    		    push(@reference_list, $ref);

    		} elsif ( $el2->name eq 'componentList' ) {

                undef($source);
                undef($analyzer);
                undef($detector);

                $clist = MzML::ComponentList->new();
                $clist->count($el2->{'att'}->{'count'});

                my @subnodes_3 = $el2->children;

                my (@source_cvparam_list, @analyzer_cvparam_list, @detector_cvparam_list);
                my (@source_reference_list, @analyzer_reference_list, @detector_reference_list);
                my (@source_user_list, @analyzer_user_list, @detector_user_list);

                for my $el3 ( @subnodes_3 ) {
                    
                    if ( $el3->name eq 'source' ) {
                        
                        $source = MzML::Source->new();
                        $source->order($el3->{'att'}->{'order'});

                        my @subnodes_4 = $el3->children;

                        for my $el4 ( @subnodes_4 ) {

                            if ( $el4->name eq 'cvParam' ) {

                                my $cvp = get_cvParam($el4);
                                push(@source_cvparam_list, $cvp);

                            } elsif ( $el4->name eq 'referenceableParamGroupRef' ) {

                                my $ref = get_referenceableParamGroupRef($el4);
                                push(@source_reference_list, $ref);

                            } elsif ($el4->name eq 'userParam' ) {

                                my $user = get_userParam($el4);
                                push(@source_user_list, $user);
                                
                            }
                        }
                        

                    } elsif ( $el3->name eq 'analyzer' ) {

                        $analyzer = MzML::Analyzer->new();
                        $analyzer->order($el3->{'att'}->{'order'});

                        my @subnodes_4 = $el3->children;

                        for my $el4 ( @subnodes_4 ) {

                            if ( $el4->name eq 'cvParam' ) {

                                my $cvp = get_cvParam($el4);
                                push(@analyzer_cvparam_list, $cvp);

                            } elsif ( $el4->name eq 'referenceableParamGroupRef' ) {

                                my $ref = get_referenceableParamGroupRef($el4);
                                push(@analyzer_reference_list, $ref);

                            } elsif ($el4->name eq 'userParam' ) {

                                my $user = get_userParam($el4);
                                push(@analyzer_user_list, $user);
                                
                            }
                        }

                    } elsif ( $el3->name eq 'detector' ) {

                        $detector = MzML::Detector->new();
                        $detector->order($el3->{'att'}->{'order'});

                        my @subnodes_4 = $el3->children;

                        for my $el4 ( @subnodes_4 ) {

                            if ( $el4->name eq 'cvParam' ) {

                                my $cvp = get_cvParam($el4);
                                push(@detector_cvparam_list, $cvp);

                            } elsif ( $el4->name eq 'referenceableParamGroupRef' ) {

                                my $ref = get_referenceableParamGroupRef($el4);
                                push(@detector_reference_list, $ref);

                            } elsif ($el4->name eq 'userParam' ) {

                                my $user = get_userParam($el4);
                                push(@detector_user_list, $user);
                                
                            }
                        }

                    }

                }#end el3

                $source->cvParam(\@source_cvparam_list);
                $source->userParam(\@source_user_list);
                $source->referenceableParamGroupRef(\@source_reference_list);

                $analyzer->cvParam(\@analyzer_cvparam_list);
                $analyzer->userParam(\@analyzer_user_list);
                $analyzer->referenceableParamGroupRef(\@analyzer_reference_list);

                $detector->cvParam(\@detector_cvparam_list);
                $detector->userParam(\@detector_user_list);
                $detector->referenceableParamGroupRef(\@detector_reference_list);

                $clist->source($source);
                $clist->analyzer($analyzer);
                $clist->detector($detector);

                push(@clist, $clist);

                $ic->componentList($clist);

            } elsif ( $el2->name eq 'softwareRef' ) {
                
                my $software = MzML::SoftwareRef->new();
                $software->ref($el2->{'att'}->{'ref'});
                
                $ic->softwareRef($software);

            }

        }# end el2

        push(@list, $ic);

    }# end el

    my $icl = MzML::InstrumentConfigurationList->new();
    $icl->count($node->{'att'}->{'count'});
    $icl->instrumentConfiguration(\@list);

    $reg->instrumentConfigurationList($icl);
}

sub parse_softwarelist {
    my ($parser, $node) = @_;

    my @subnodes_1 = $node->children;
    my @list;

    my $sw;
    my $sp;

    for my $el1 ( @subnodes_1 ) {

        if ( $el1->name eq 'software' ) {
            
            $sw = MzML::Software->new();
            
            $sw->id($el1->{'att'}->{'id'}) if defined ($el1->{'att'}->{'id'});
            $sw->version($el1->{'att'}->{'version'}) if defined ($el1->{'att'}->{'version'});

            my $el2 = $el1->first_child;

            $sp = MzML::SoftwareParam->new();

            $sp->accession($el2->{'att'}->{'accession'}) if defined ($el2->{'att'}->{'accession'});
            $sp->cvRef($el2->{'att'}->{'cvRef'}) if defined ($el2->{'att'}->{'cvRef'});
            $sp->name($el2->{'att'}->{'name'}) if defined ($el2->{'att'}->{'name'});
            $sp->version($el2->{'att'}->{'version'}) if defined ($el2->{'att'}->{'version'});

        }

        $sw->softwareParam($sp);
        push(@list, $sw);
        
    }

    my $swl = MzML::SoftwareList->new();
    $swl->count($node->{'att'}->{'count'});
    $swl->software(\@list);

    $reg->softwareList($swl);

}

sub get_cvParam {
    my $el = shift;

    my $cvp = MzML::CvParam->new();
    
    $cvp->accession($el->{'att'}->{'accession'});
    $cvp->cvRef($el->{'att'}->{'cvRef'});
    $cvp->name($el->{'att'}->{'name'});
    $cvp->unitAccession($el->{'att'}->{'unitAccession'}) if defined ($el->{'att'}->{'unitAccession'});
    $cvp->unitName($el->{'att'}->{'unitName'}) if defined ($el->{'att'}->{'unitName'});
    $cvp->value($el->{'att'}->{'value'}) if defined ($el->{'att'}->{'value'});

    return $cvp;
}

sub get_referenceableParamGroupRef {
    my $el = shift;

    my $ref = MzML::ReferenceableParamGroupRef->new();
    $ref->ref($el->{'att'}->{'ref'});
 
    return $ref;
}


sub get_userParam {
    my $el = shift;

    my $user = MzML::UserParam->new();

    $user->name($el->{'att'}->{'name'});
    $user->type($el->{'att'}->{'type'}) if defined ($el->{'att'}->{'type'});
    $user->unitAccession($el->{'att'}->{'unitAccession'}) if defined ($el->{'att'}->{'unitAccession'});
    $user->unitCvRef($el->{'att'}->{'unitCvRef'}) if defined ($el->{'att'}->{'unitCvRef'});
    $user->unitName($el->{'att'}->{'unitName'}) if defined ($el->{'att'}->{'unitName'});
    $user->value($el->{'att'}->{'value'}) if defined ($el->{'att'}->{'value'});

    return $user;
}





















1;
