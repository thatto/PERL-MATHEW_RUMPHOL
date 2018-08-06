#  ============================================================================================================
#  TITLE:			SNMP COMMUNITY.PL
#  Version:			1.1
#  CREATED:			04/11/2011
#  LAST UPDATE:	02/13/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture SNMP values for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("SNMP COMMUNITY REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("COMMUNITY NAME"));
my $Column6 = uc(("RIGHTS"));
my $Column7 = uc(("STATUS"));



my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "SNMP Community Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Community Name:";
my $ScreenLabel4 = "Rights:";
my $ScreenLabel5 = "Status:";


# [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [STATUS HANDLING VARIABLES]
my $PassStatus = "Pass";
my $FailStatus = "Fail";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%values);

# [CUSTOM VARIABLES]
my $SnmpCommunityName;
my $SnmpRights;
my $SnmpCommunityStatus;

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
	$SnmpCommunityName = "$DetectionError";
	$SnmpRights = "$DetectionError";
	$SnmpCommunityStatus = "$UnknownStatus";
	print "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT "$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$SnmpCommunityName\t$SnmpRights\t$SnmpCommunityStatus\n";
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
		$SnmpCommunityName = "$DetectionError";
		$SnmpRights = "$DetectionError";
		$SnmpCommunityStatus = "$UnknownStatus";
		print "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT "$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$SnmpCommunityName\t$SnmpRights\t$SnmpCommunityStatus\n";
		}
	else
		{
		# [DETECT VIRTUAL NAME IN SOURCE LIST]
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
				# [ENUMERATE SNMP COMMUNITY NAMES]
				my $RegKeyPath1 = "SYSTEM\\CurrentControlSet\\Services\\SNMP\\Parameters\\ValidCommunities";
				my (%ComKey_List, $ComKey);

				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$RegKeyPath1", $hKey);
				{
			if (!defined $hKey)
					{
					$SnmpCommunityName = "$DetectionError";
					$SnmpRights = "$DetectionError";
					$SnmpCommunityStatus = "$UnknownStatus";
					print "  $RegErrorMessage - Unable to Capture SNMP Information\n\n";
					print OUT "$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$SnmpCommunityName\t$SnmpRights\t$SnmpCommunityStatus\n";
					}
				else
					{
					$hKey->GetValues(\%ComKey_List);
					foreach $ComKey (%ComKey_List)
						{
						if ($ComKey !~ "ARRAY")
							{
							$SnmpCommunityName = "$ComKey";
							if ((!defined $SnmpCommunityName) or ($SnmpCommunityName !~ "."))
								{
								$SnmpCommunityName = "$DetectionError";
								}
							else
								{
							# [CAPTURE SNMP COMMUNITY RIGHTS]
								my $RegKey1 = "$SnmpCommunityName";
								$hKey->GetValues(\%values);
								$hKey->Close ();
								$hNode->Close ();
								$SnmpRights = $values{$RegKey1}[2];
								chomp($SnmpRights);

								if ((!defined $SnmpRights) or ($SnmpRights !~ "."))
									{
									$SnmpRights = "$DetectionError";
									}
							elsif ($SnmpRights == '1')
									{
									$SnmpRights = "NONE";
									}
							elsif ($SnmpRights == '4')
									{
									$SnmpRights = "READ ONLY";
									}
							elsif ($SnmpRights == '8')
									{
									$SnmpRights = "READ WRITE";
									}
							elsif ($SnmpRights == '16')
									{
									$SnmpRights = "READ CREATE";
									}
								}
							print "  $ScreenLabel3\t$SnmpCommunityName\n  $ScreenLabel4\t\t$SnmpRights\n  $ScreenLabel4\t\t$SnmpCommunityStatus\n\n";
							print OUT "$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$SnmpCommunityName\t$SnmpRights\t$SnmpCommunityStatus\n";
							}
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);