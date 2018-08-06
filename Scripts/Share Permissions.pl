#!/usr/bin/perl -w

use strict;
use Win32::Perms;
use vars qw ( @List @Mask );

my $Dir = new Win32::Perms( $ARGV[0] );

$Dir->Dump( \@List );

foreach my $shareRef ( @List ) {
    print "\n" , $shareRef->{'Domain'} , '/' , $shareRef->{'Account'} 
+, "\n\n";
    Win32::Perms::DecodeMask ( $shareRef, \@Mask );
    foreach ( @Mask ) {
    print "\t" , $_ , "\n";
    }
}
