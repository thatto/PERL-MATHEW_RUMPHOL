#  ============================================================================================================
#  TITLE:			CITRIX VERSION.PL
#  Version:			2.6
#  CREATED:			10/25/2010
#  LAST UPDATE:	02/12/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture CITRIX PRODUCT VERSION values for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::Registry;

#	[INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("CITRIX VERSION REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("PRODUCT NAME"));
my $Column6 = uc(("VERSION"));
my $Column7 = uc(("SERVICE PACK"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

#  [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Citrix Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Product Name:";
my $ScreenLabel4 = "Version:";
my $ScreenLabel5 = "Service Pack:";

#  [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

#	[NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

#	[STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%values);

#	[CUSTOM VARIABLES]
my $CitrixProductName;
my $CitrixProductVersion;
my $CitrixServicePack;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n\n";

#	[TEST REGISTRY CONNECTION]
my $RegTestPath = "SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName";
my $RegTestKey = "ComputerName";

$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
$hNode->Open ("$RegTestPath", $hKey);

if (!defined $hKey)
	{
	$RealComputerName = "$DetectionError";
	$VirtualNameStatus = "$UnknownStatus";
	$CitrixProductName = "$DetectionError";
	$CitrixProductVersion = "$DetectionError";
	$CitrixServicePack = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$CitrixProductName\t$CitrixProductVersion\t$CitrixServicePack\n");
	}
else
	{
	#	[CAPTURE THE REAL COMPUTER NAME]
	$hKey->GetValues(\%values);
	$hKey->Close ();
	$hNode->Close ();
	$RealComputerName = uc($values{$RegTestKey}[2]);
	chomp($RealComputerName);

	if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
		{
		$RealComputerName = "$DetectionError";
		$VirtualNameStatus = "$UnknownStatus";
		$CitrixProductName = "$DetectionError";
		$CitrixProductVersion = "$DetectionError";
		$CitrixServicePack = "$UnknownStatus";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$CitrixProductName\t$CitrixProductVersion\t$CitrixServicePack\n");
		}
	else
		{
		#	[DETECT VIRTUAL NAME IN SOURCE LIST]
		my @computers = ("$RealComputerName");

		foreach my $Computer (@computers)
			{
			if ($RealComputerName eq "$ComputerName")
				{
				$VirtualNameStatus = "No";
				}
			else
				{
				$VirtualNameStatus = "Yes";
				print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
				}
				#	[CAPTURE CITRIX INFORMATION]
				my $RegKeyPath = "SYSTEM\\CurrentControlSet\\Control\\Citrix";
				my $RegKey1 = "ProductName";
				my $RegKey2 = "NewProductVersion";
				my $RegKey3 = "NewServicePack";

				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$RegKeyPath", $hKey);
				{
				if (!defined $hKey)
					{
					$CitrixProductName = "$DetectionError";
					$CitrixProductVersion = "$DetectionError";
					$CitrixServicePack = "$DetectionError";
					print  "  $RegErrorMessage - Unable to Locate Citrix Information\n\n";
					print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$CitrixProductName\t$CitrixProductVersion\t$CitrixServicePack\n");
					}
				else
					{
					$hKey->GetValues(\%values);
					$hKey->Close ();
					$hNode->Close ();					
					$CitrixProductName = uc($values{$RegKey1}[2]);
					chomp($CitrixProductName);

					if ((!defined $CitrixProductName) or ($CitrixProductName !~ "."))
						{
						$CitrixProductName = "$DetectionError";
						$CitrixProductVersion = "$DetectionError";
						$CitrixServicePack = "$DetectionError";
						print( "  $ScreenLabel3\t$DetectionError\n" );
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();						
						$CitrixProductVersion = uc($values{$RegKey2}[2]);
						chomp($CitrixProductVersion);
						{
						if ((!defined $CitrixProductVersion) or ($CitrixProductVersion !~ "."))
							{
							$CitrixProductVersion = "$DetectionError";
							$CitrixServicePack = "$DetectionError";
							print  "  $ScreenLabel4\t\t$DetectionError\n\n";
							print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$CitrixProductName\t$CitrixProductVersion\t$CitrixServicePack\n");
							}
						else
							{
							$hKey->GetValues(\%values);
							$hKey->Close ();
							$hNode->Close ();
							$CitrixServicePack = uc($values{$RegKey3}[2]);
							chomp($CitrixServicePack);
							}
							if ((!defined $CitrixServicePack) or ($CitrixServicePack !~ "."))
								{
								$CitrixServicePack = "$DetectionError";
								print( "  $ScreenLabel4\t\t$DetectionError\n" );
								}
							}
						print "  $ScreenLabel3\t$CitrixProductName\n  $ScreenLabel4\t$CitrixProductVersion\n  $ScreenLabel5\t$CitrixServicePack\n\n";
						print OUT "$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$CitrixProductName\t$CitrixProductVersion\t$CitrixServicePack\n";
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);