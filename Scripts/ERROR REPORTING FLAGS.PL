#  ============================================================================================================
#  TITLE:			ERROR REPORTING FLAGS.PL
#  Version:			2.6
#  CREATED:			12/03/2008
#  LAST UPDATE:	02/13/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows ERROR REPORTING registry values for a list of computers
#  ============================================================================================================
use strict;
use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("ERROR REPORTING FLAGS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("ERROR REPORTING"));
my $Column6 = uc(("LOCAL NOTIFICATION"));
my $Column7 = uc(("ERROR REPORTING STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Error Reporting Setting:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Error Reporting Flag:";
my $ScreenLabel4 = "Notification Flag:";

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
my $PassStatus = "PASS";
my $FailStatus = "FAIL";

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%values);

#[CUSTOM VARIABLES]
my $ErrorReportingStatus;
my $ErrorReportingFlag;
my $ErrorNotifyFlag;

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
	$ErrorReportingFlag = "$DetectionError";
	$ErrorNotifyFlag = "$DetectionError";
	$ErrorReportingStatus = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ErrorReportingFlag\t$ErrorNotifyFlag\t$ErrorReportingStatus\n");
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
		$ErrorReportingFlag = "$DetectionError";
		$ErrorNotifyFlag = "$DetectionError";
		$ErrorReportingStatus = "$UnknownStatus";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ErrorReportingFlag\t$ErrorNotifyFlag\t$ErrorReportingStatus\n");
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
				# [CAPTURE ERROR REPORTING SETTING]
				my $RegKeyPath = "SOFTWARE\\Microsoft\\PCHealth\\ErrorReporting";
				my $RegKey = "DoReport";
		
				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$RegKeyPath", $hKey);
				{
				if (!defined $hKey)
					{
					$ErrorReportingFlag = "$DetectionError";
					$ErrorNotifyFlag = "$DetectionError";
					$ErrorReportingStatus = "$UnknownStatus";
					print  "  $RegErrorMessage - Aborting Query\n\n";
					print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ErrorReportingFlag\t$ErrorNotifyFlag\t$ErrorReportingStatus\n");
					}
				else
					{
					$hKey->GetValues(\%values);
					$hKey->Close ();
					$ErrorReportingFlag = uc($values{$RegKey}[2]);
					chomp($ErrorReportingFlag);
	
					if ((!defined $ErrorReportingFlag) or ($ErrorReportingFlag !~"."))
						{
						$ErrorReportingFlag = "$RegErrorMessage";
						$ErrorReportingStatus = "$UnknownStatus";
						print( "  $ScreenLabel3\t\t$RegErrorMessage\n" );
						}				
				elsif ($ErrorReportingFlag eq "0")
						{
						$ErrorReportingFlag = "OFF";
						$ErrorReportingStatus = "$PassStatus";
						print( "  $ScreenLabel3\t\t$ErrorReportingFlag\t$ErrorReportingStatus\n" );
						}
				elsif ($ErrorReportingFlag eq "1")
						{
						$ErrorReportingFlag = "ON";
						$ErrorReportingStatus = "$FailStatus";
						print( "  $ScreenLabel3\t\t$ErrorReportingFlag\t$ErrorReportingStatus\n" );
						}
						#  CAPTURE LOCAL NOTIFICATION SETTING
						my $RegKeyPath = "SOFTWARE\\Microsoft\\PCHealth\\ErrorReporting";
						my $RegKey = "ShowUI";
	
						$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
						$hNode->Open ("$RegKeyPath", $hKey);
						{
						if (!defined $hKey)
							{
							$ErrorNotifyFlag = "$DetectionError";
							$ErrorReportingStatus = "$UnknownStatus";
							print  "  $RegErrorMessage - Aborting Query\n\n";
							print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ErrorReportingFlag\t$ErrorNotifyFlag\t$ErrorReportingStatus\n");
							}
						else
							{
							$hKey->GetValues(\%values);
							$hKey->Close ();
							$hNode->Close ();
							$ErrorNotifyFlag = uc($values{$RegKey}[2]);
							chomp($ErrorNotifyFlag);
	
							if ((!defined $ErrorNotifyFlag) or ($ErrorNotifyFlag !~ "."))
								{
								$ErrorNotifyFlag = "$RegErrorMessage";
								$ErrorReportingStatus = "$UnknownStatus";
								print( "  $ScreenLabel4\t\t$ErrorNotifyFlag\n" );
								}
						elsif ($ErrorNotifyFlag eq "0")
								{
								$ErrorNotifyFlag = "OFF";
								$ErrorReportingStatus = "$PassStatus";
								print( "  $ScreenLabel4\t\t$ErrorNotifyFlag\t$ErrorReportingStatus\n" );
								}
						elsif ($ErrorNotifyFlag eq "1")
								{
								$ErrorNotifyFlag = "ON";
								$ErrorReportingStatus = "$FailStatus";
								print( "  $ScreenLabel4\t\t$ErrorNotifyFlag\t$ErrorReportingStatus\n" );
								}
							}
						print OUT "$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ErrorReportingFlag\t$ErrorNotifyFlag\t$ErrorReportingStatus\n";
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);