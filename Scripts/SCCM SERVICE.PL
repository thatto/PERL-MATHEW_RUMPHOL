#  ============================================================================================================
#  TITLE:			SCCM SERVICE.PL
#  VERSION:			1.2
#  CREATED:			09/20/2011
#  LAST UPDATE:	03/12/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Audit SYSTEM CENTER MANAGEMENT service settings for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::Service;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("SCCM REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("SERVICE NAME"));
my $Column6 = uc(("SERVICE STATE"));
my $Column7 = uc(("STARTUP MODE"));
my $Column8 = uc(("SERVICE STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "SCCM Audit:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Service Name:";
my $ScreenLabel4 = "Current State:";
my $ScreenLabel5 = "Startup Mode:";
my $ScreenLabel6 = "Status:";


# [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $NameMismatchDetection = "*** NAME MISMATCH DETECTED ***";
my $NameMismatchStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [AUDIT CRITERIA VARIABLES]
my $PassStatus = "PASS";
my $FailStatus = "FAIL";
my $GoodStatus = "OK";
my $BadStatus = "INCORRECT";

# [CUSTOM VARIABLES]
my $Service = "HealthService";
my $ServiceName = "SYSTEM CENTER MANAGEMENT";
my $ServiceState;
my $ServiceMode;
my $ServiceStateStatus;
my $ServiceModeStatus;
my $ServiceStatus;
my $hNode;
my $hKey;
my $Values;
my %Values;
my $Status;
my %Status;


print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n";

# [TEST REGISTRY CONNECTION]
my $RegTestPath = "SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName";
my $RegTestKey = "ComputerName";

$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
$hNode->Open ("$RegTestPath", $hKey);

if (!defined $hKey)
	{
	$RealComputerName = "$DetectionError";
	$NameMismatchStatus = "$UnknownStatus";
	$ServiceState = "$DetectionError";
	$ServiceMode = "$DetectionError";
	$ServiceModeStatus = "$UnknownStatus";
	$ServiceStatus = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$ServiceName\t$ServiceState\t$ServiceMode\t$ServiceStatus\n");
	}
else
	{
	# [CAPTURE THE REAL COMPUTER NAME]
	$hKey->GetValues(\%Values);
	$hKey->Close ();
	$hNode->Close ();
	$RealComputerName = uc($Values{$RegTestKey}[2]);
	chomp($RealComputerName);

	if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
		{
		$RealComputerName = "$DetectionError";
		$NameMismatchStatus = "$UnknownStatus";
		$ServiceState = "$DetectionError";
		$ServiceMode = "$DetectionError";
		$ServiceModeStatus = "$UnknownStatus";
		$ServiceStatus = "$UnknownStatus";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$ServiceName\t$ServiceState\t$ServiceMode\t$ServiceStatus\n");
		}
	else
		{
		# [DETECT NAME MISMATCH IN SOURCE LIST]
		my @computers = ("$RealComputerName");

		if ($RealComputerName eq "$ComputerName")
			{
			$NameMismatchStatus = "No";
			}
		else
			{
			$NameMismatchStatus = "Yes";
			print "  $NameMismatchDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
			}
			# [CAPTURE THE SERVICE INFORMATION]
			foreach my $Computer (@computers)
				{
				# [CAPTURE STARTUP MODE OF SERVICE]
				my $RegKeyPath = "SYSTEM\\CurrentControlSet\\Services\\$Service";
				my $StartupRegKey = "Start";
				my $RegValue;

				$HKEY_LOCAL_MACHINE->Connect ($RealComputerName, $hNode);
				$hNode->Open ("$RegKeyPath", $hKey);

				if (!defined $hKey)
					{
					$ServiceMode = "$DetectionError";
					$ServiceState = "$DetectionError";
					$ServiceModeStatus = "$BadStatus";
					}
				else
					{
					$hKey->GetValues(\%Values);
					$ServiceMode = $Values{$StartupRegKey}[2];

					if ((!defined $ServiceMode) or ($ServiceMode !~ "."))
						{
						$ServiceMode = "$DetectionError";
						$ServiceState = "$DetectionError";
						$ServiceModeStatus = "$UnknownStatus";
						}
				elsif ($ServiceMode == '2')
						{
						$ServiceMode = "AUTOMATIC";
						$ServiceModeStatus = "$GoodStatus";
						}
				elsif ($ServiceMode == '3')
						{
						$ServiceMode = "MANUAL";
						$ServiceModeStatus = "$BadStatus";
						}
				elsif ($ServiceMode == '4')
						{
						$ServiceMode = "DISABLED";
						$ServiceModeStatus = "$BadStatus";
						}
					}
				if ($ServiceMode ne "$DetectionError")
					{
					# [CAPTURE CURRENT RUNNING STATE OF SERVICE]
					Win32::Service::GetStatus( "$RealComputerName","$Service", \%Status);

				if ((!defined($Status{CurrentState})) or (($Status{CurrentState} !~ ".")))
					{
					$ServiceState = "$DetectionError";
					$ServiceStateStatus = "UnknownStatus";
					}
			elsif ($Status{CurrentState} == '1')
					{
					$ServiceState = "STOPPED";
					$ServiceStateStatus = "$BadStatus";
					}
			elsif ($Status{CurrentState} == '2')
					{
					$ServiceState = "STARTING";
					$ServiceStateStatus = "$BadStatus";
					}
			elsif ($Status{CurrentState} == '3')
					{
					$ServiceState = "STOPPING";
					$ServiceStateStatus = "$BadStatus";
					}
			elsif ($Status{CurrentState} == '4')
					{
					$ServiceState = "RUNNING";
					$ServiceStateStatus = "GoodStatus";
					}
			elsif ($Status{CurrentState} == '5')
					{
					$ServiceState = "RESUME PENDING";
					$ServiceStateStatus = "$BadStatus";
					}
			elsif ($Status{CurrentState} == '6')
					{
					$ServiceState = "PAUSE PENDING";
					$ServiceStateStatus = "$BadStatus";
					}
			elsif ($Status{CurrentState} == '7')
					{
					$ServiceState = "PAUSED";
					$ServiceStateStatus = "$BadStatus";
					}
				}
			# [TEST AUDIT CRITERIA BASED ON RESULTS]
			if (($ServiceModeStatus eq "$BadStatus") or ($ServiceStateStatus eq "$BadStatus"))
				{
				$ServiceStatus = "$FailStatus";
				}
		elsif (($ServiceModeStatus eq "$UnknownStatus") or ($ServiceStateStatus eq "$UnknownStatus"))
				{
				$ServiceStatus = "$UnknownStatus";
				}
		elsif (($ServiceModeStatus eq "$GoodStatus") or ($ServiceStateStatus eq "$GoodStatus"))
				{
				$ServiceStatus = "$PassStatus";
				}
			print "  $ScreenLabel3\t\t$ServiceName\n  $ScreenLabel4\t$ServiceState\n  $ScreenLabel5\t\t$ServiceMode\n\n  $ScreenLabel6\t\t$ServiceStatus\n\n";
			print OUT ("$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$ServiceName\t$ServiceState\t$ServiceMode\t$ServiceStatus\n");
			}
		}
	}
}
close(IN);
close(OUT);