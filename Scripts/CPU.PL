#  ============================================================================================================
#  TITLE:			CPU.PL
#  VERSION:			3.1
#  CREATED:			10/14/2004
#  LAST UPDATE:	03/26/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture CPU information from the registry for a list of Windows computers
#  ============================================================================================================
# use strict;
# use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("CPU REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("CPU"));
my $Column6 = uc(("DESCRIPTION"));
my $Column7 = uc(("SPEED"));;

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
open(STDERR, "/dev/null");
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Processors:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";

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
my ($hNode,$hKey,%Values);
my $RegKeyPath;
my $RegValue;
my $Values;

# [CUSTOM VARIABLES]
my $RegKeyPathArray;
my $y;
my $starty;
my $CpuNumber;
my $Description;
my $ClockSpeed;
my $Gigahertz;

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
	$NameMismatchStatus = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\n");
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
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\n");
		}
	else
		{
		# [DETECT NAME MISMATCH IN SOURCE LIST]
		my @computers = ("$RealComputerName");

		foreach my $Computer (@computers)
			{
			if ($RealComputerName eq "$ComputerName")
				{
				$NameMismatchStatus = "No";
				}
			else
				{
				$NameMismatchStatus = "Yes";
				print "  $NameMismatchDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
				}
				# [CAPTURE CPU INFORMATION]
				my $RegKey1 = "~MHz";
				my $RegKey2 = "ProcessorNameString";

				my @RegKeyPathArray = (
				["Hardware\\Description\\System\\CentralProcessor\\0", "Hardware\\Description\\System\\CentralProcessor\\1",
				"Hardware\\Description\\System\\CentralProcessor\\2", "Hardware\\Description\\System\\CentralProcessor\\3",
				"Hardware\\Description\\System\\CentralProcessor\\4", "Hardware\\Description\\System\\CentralProcessor\\5",
				"Hardware\\Description\\System\\CentralProcessor\\6", "Hardware\\Description\\System\\CentralProcessor\\7",
				"Hardware\\Description\\System\\CentralProcessor\\8", "Hardware\\Description\\System\\CentralProcessor\\9",
				"Hardware\\Description\\System\\CentralProcessor\\10", "Hardware\\Description\\System\\CentralProcessor\\11",
				"Hardware\\Description\\System\\CentralProcessor\\12", "Hardware\\Description\\System\\CentralProcessor\\13",
				"Hardware\\Description\\System\\CentralProcessor\\14", "Hardware\\Description\\System\\CentralProcessor\\15",
				"Hardware\\Description\\System\\CentralProcessor\\16", "Hardware\\Description\\System\\CentralProcessor\\17",
				"Hardware\\Description\\System\\CentralProcessor\\18", "Hardware\\Description\\System\\CentralProcessor\\19",
				"Hardware\\Description\\System\\CentralProcessor\\20", "Hardware\\Description\\System\\CentralProcessor\\21",
				"Hardware\\Description\\System\\CentralProcessor\\22", "Hardware\\Description\\System\\CentralProcessor\\23",
				"Hardware\\Description\\System\\CentralProcessor\\24", "Hardware\\Description\\System\\CentralProcessor\\25",
				"Hardware\\Description\\System\\CentralProcessor\\26", "Hardware\\Description\\System\\CentralProcessor\\27",
				"Hardware\\Description\\System\\CentralProcessor\\28", "Hardware\\Description\\System\\CentralProcessor\\29",
				"Hardware\\Description\\System\\CentralProcessor\\30", "Hardware\\Description\\System\\CentralProcessor\\31",],);

				for ($starty = $y = 0; $y < 32; $y++)
					{
					$RegKeyPath = $RegKeyPathArray[null][$y];
					$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
					$hNode->Open ("$RegKeyPath", $hKey);

					if ($hKey eq "")
						{
						if ($y eq 0)
							{
							print( "$RegErrorMessage $ComputerName\n" );
							print OUT "$ComputerName\RegErrorMessage\n";
							}
						else
							{
							print( "" );
							}
						}
					else
						{
						$hKey->GetValues(\%Values);
						$ClockSpeed = $Values{$RegKey1}[2];
						chomp($ClockSpeed);
						
						$hKey->GetValues(\%Values);
						$hKey->Close ();
						$hNode->Close ();
						$Description = $Values{$RegKey2}[2];
						chomp($Description);

					if ($ClockSpeed < 999)
						{
						print( " CPU $y = $ClockSpeed Mhz\n" );
						print OUT ("$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\tCPU $y\t$Description\t$ClockSpeed\n");
						}
					else
						{
						$ClockSpeed = $ClockSpeed/1000;
						print( " CPU $y	\t$Description	$ClockSpeed Ghz\n" );
						print OUT ("$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\tCPU $y\t$Description\t$ClockSpeed\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);