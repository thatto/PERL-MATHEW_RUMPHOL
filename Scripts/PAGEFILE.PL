# ============================================================================================================
#  TITLE:			PAGEFILE.PL
#  VERSION:			4.4
#  CREATED:			12/03/2008
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows PAGEFILE information values for a list of computers using WMI
#  ============================================================================================================
use strict;
use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("PAGEFILE REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DRIVE"));
my $Column6 = uc(("INITIAL SIZE (MB)"));
my $Column7 = uc(("MAXIMUM SIZE (MB)"));
my $Column8 = uc(("CURRENT SIZE (MB)"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "PageFile Settings:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Drive:";
my $ScreenLabel4 = "Initial (MB):";
my $ScreenLabel5 = "Max (MB):";
my $ScreenLabel6 = "Current (MB):";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "WMI Connection Failed";
my $WMIErrorMessage = "WMI Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [CUSTOM VARIABLES]
my $LogicalDrive;
my $InitSize;
my $MaxSize;
my $CurrentSize;
my $TotalSize;
my $TotalSize1;
my $TotalSize2;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n";

# [TEST WMI CONNECTION]
my @computers = ("$ComputerName");

foreach my $Computer (@computers)
	{
	Win32::OLE->LastError(0);
	Win32::OLE->Option(Warn => 0);
	my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2");

	if (Win32::OLE->LastError != "0")
		{
		$RealComputerName = "$DetectionError";
		$VirtualNameStatus = "$UnknownStatus";
		$LogicalDrive = "$DetectionError";
		$InitSize = "$DetectionError";
		$MaxSize = "$DetectionError";
		$CurrentSize = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$LogicalDrive\t$InitSize\t$MaxSize\t$CurrentSize\n");
		}
	else
		{
		# [CAPTURE THE REAL COMPUTER NAME]
		my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_OperatingSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);
	
		foreach my $objItem (in $colItems)
			{
			$RealComputerName = uc(("$objItem->{CSName}"));
	
			if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
				{
				$RealComputerName = "$DetectionError";
				$VirtualNameStatus = "$UnknownStatus";
				$LogicalDrive = "$DetectionError";
				$InitSize = "$DetectionError";
				$MaxSize = "$DetectionError";
				$CurrentSize = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$LogicalDrive\t$InitSize\t$MaxSize\t$CurrentSize\n");
				}
			else
				{
				# [DETECT VIRTUAL NAME IN SOURCE LIST]
				if ($RealComputerName eq "$ComputerName")
					{
					$VirtualNameStatus = "No";
					}
				else
					{
					$VirtualNameStatus = "Yes";
					print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
					}
				# [CAPTURE PAGEFILE INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_PageFile", "WQL", wbemFlagReturnImmediately | wbemFlagForwardOnly);
					if (Win32::OLE->LastError != "0")
						{
						$LogicalDrive = "$DetectionError";
						$InitSize = "$DetectionError";
						$MaxSize = "$DetectionError";
						$CurrentSize = "$DetectionError";
						print  "  $WMIErrorMessage - Aborting Query\n\n";
						print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$LogicalDrive\t$InitSize\t$MaxSize\t$CurrentSize\n");
						}
					else
						{
						foreach my $objItem (in $colItems)
							{
							$LogicalDrive = uc("$objItem->{Drive}");
							$InitSize = "$objItem->{InitialSize}";
							$MaxSize = "$objItem->{MaximumSize}";
							$CurrentSize = "$objItem->{FileSize}";

							if ((!defined $LogicalDrive) or ($LogicalDrive !~ "."))
								{
								$LogicalDrive = "$DetectionError";
								}
							if ((!defined $InitSize) or ($InitSize !~ "."))
								{
								$InitSize = "$DetectionError";
								}
						elsif ($InitSize eq "0")
								{
								$InitSize = "Auto";
								}
							if ((!defined $MaxSize) or ($MaxSize !~ "."))
								{
								$MaxSize = "$DetectionError";
								}
						elsif ($MaxSize eq "0")
								{
								$MaxSize = "Auto";
								}
							if ((!defined $CurrentSize) or ($CurrentSize !~ "."))
								{
								$CurrentSize = "$DetectionError";
								}
						elsif ($CurrentSize !~ m/\d/)
								{
								$CurrentSize = "$UnknownStatus";
								}								
						elsif ($CurrentSize =~ m/\d/)
								{
								$CurrentSize = $CurrentSize / 1000000;
								$CurrentSize = substr($CurrentSize, 0, 5);
								$CurrentSize =~ s/\.//;
								}
							print "  $ScreenLabel3 $LogicalDrive\t$ScreenLabel4 $InitSize\t$ScreenLabel5 $MaxSize\t$ScreenLabel6 $CurrentSize\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$LogicalDrive\t$InitSize\t$MaxSize\t$CurrentSize\n");
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