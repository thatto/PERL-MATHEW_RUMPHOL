#  ============================================================================================================
#  TITLE:			DOMAIN SUFFIX.PL
#  Version:			1.2
#  CREATED:			07/26/2011
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Validate MS Windows DOMAIN suffix for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("DOMAIN SUFFIX REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DOMAIN SUFFIX"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Domain Suffix:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Suffix:";

# [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STATUS HANDLING VARIABLES]
my $PassStatus = "Pass";
my $FailStatus = "Fail";

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%values);

# [CUSTOM VARIABLES]
my $DomainSuffix;
my $FQDN;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n\n";

# [TEST REGISTRY CONNECTION]
my $RegTestPath = "SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName";
my $RegTestKey = "ComputerName";

$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
$hNode->Open ("$RegTestPath", $hKey);

if (!defined $hKey)
	{
	$RealComputerName = "$DetectionError";
	$VirtualNameStatus = "$UnknownStatus";
	$DomainSuffix = "$DetectionError";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$DomainSuffix\n");
	}
else
	{
	# [CAPTURE THE REAL COMPUTER NAME]
	$hKey->GetValues(\%values);
	$hKey->Close ();
	$hNode->Close ();
	$RealComputerName = uc($values{$RegTestKey}[2]);
	chomp($RealComputerName);

	if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
		{
		$RealComputerName = "$DetectionError";
		$VirtualNameStatus = "$UnknownStatus";
		$DomainSuffix = "$DetectionError";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$DomainSuffix\n");
		}
	else
		{
		# [DETECT NAME MISMATCH IN SOURCE LIST]
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
				# [CAPTURE DNS SUFFIX]
				my $RegKeyPath = "SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters";
				my $RegKey = "Domain";

				$HKEY_LOCAL_MACHINE->Connect ($RealComputerName, $hNode);
				$hNode->Open ("$RegKeyPath", $hKey);
					{
					if (defined $hKey)
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$DomainSuffix = uc($values{$RegKey}[2]);
						chomp($DomainSuffix);
						}
				if ((!defined $DomainSuffix) or ($DomainSuffix eq ""))
					{
					$VirtualNameStatus = "";
					$DomainSuffix = "$DetectionError";
					print  "  $RegErrorMessage - Unable to Capture the Domain Suffix\n\n";
					}
				else
					{
					print "\n  $ScreenLabel3 $DomainSuffix\n\n";
					print OUT ("$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$DomainSuffix\n");
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);