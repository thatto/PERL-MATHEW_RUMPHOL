#  ============================================================================================================
#  TITLE:			VA_SETUP.PL
#  VERSION:			4.4
#  CREATED:			01/13/2009
#  LAST UPDATE:	05/12/2011
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with computer names
#  PURPOSE:			Create a VisionApp Remote Desktops import file from a list of computers
#  ============================================================================================================
use strict;
# use warnings;

my $input = "..\\INPUT\\EQUIPMENT.TXT";
my $output = "..\\VA_SETUP.VRD";

open IN, "<", $input or die "cannot open input: $input";
open OUT, ">", $output or die "cannot open output: $output";

# [CREATE XML FILE HEADER]
print OUT '<?xml version="1.0" encoding="utf-16"?>',"\n";
print OUT '<vRDConfigurationFile>',"\n";
print OUT ' <Folder Name="IMPORT" Description="" Credentials="00000000-0000-0000-0000-000000000000" Sorted="false">',"\n";

while (<IN>)
{
chomp;
# [CREATE XML FILE CONTENT FOR EACH COMPUTER IN LIST]
my $ComputerName = uc(("$_"));

print OUT "    <Connection Name=\"$ComputerName\" ServerName=\"$ComputerName\">\n";
print OUT '       <Description></Description>',"\n";
print OUT '       <Credentials>00000000-0000-0000-0000-000000000000</Credentials>',"\n";
print OUT '       <Audio>2</Audio>',"\n";
print OUT '       <AutoSize>true</AutoSize>',"\n";
print OUT '       <Console>true</Console>',"\n";
print OUT '       <InheritCredentials>true</InheritCredentials>',"\n";
print OUT '       <LocalDrives>false</LocalDrives>',"\n";
print OUT '       <Printer>false</Printer>',"\n";
print OUT '       <ResolutionX>1024</ResolutionX>',"\n";
print OUT '       <ResolutionY>768</ResolutionY>',"\n";
print OUT '       <Serial>false</Serial>',"\n";
print OUT '       <SmartCard>false</SmartCard>',"\n";
print OUT '       <Port>3389</Port>',"\n";
print OUT '       <SeparateWindow>false</SeparateWindow>',"\n";
print OUT '       <Clipboard>0</Clipboard>',"\n";
print OUT '       <ColorDepth>24</ColorDepth>',"\n";
print OUT '       <KeyboardMode>1</KeyboardMode>',"\n";;
print OUT '       <PerformanceFlags>9</PerformanceFlags>',"\n";
print OUT '       <BitmapCaching>true</BitmapCaching>',"\n";
print OUT '    </Connection>',"\n";
}
print OUT ' </Folder>',"\n";
print OUT '</vRDConfigurationFile>',"\n";

print "\n";
print " VisionApp import file created:   $output";
print "\n";

close(IN);
close(OUT);