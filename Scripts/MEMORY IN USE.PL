#  ============================================================================================================
#  TITLE:			MEMORY IN USE.PL
#  VERSION:			3.3
#  CREATED:			11/30/2015
#  LAST UPDATE:	05/12/2011
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows MEMORY IN USE performance counter information values for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("MEMORY IN USE REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("TOTAL MEMORY (MB)"));
my $Column6 = uc(("FREE MEMORY (MB)"));
my $Column7 = uc(("USED MEMORY (MB)"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;
# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Memory In Use:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Total Memory (MB):";
my $ScreenLabel4 = "Free Memory (MB):";
my $ScreenLabel5 = "Used Memory (MB):";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "WMI Connection Failed";
my $WMIErrorMessage = "WMI Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STATUS HANDLING VARIABLES]
my $PassStatus = "Healthy";
my $FailStatus = "Fail";
my $WarningStatus = "Warning";
my $CriticalStatus = "Critical";
my $PteEntryStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [CUSTOM VARIABLES]
my $TotalBytes;
my $MegaBytes;
my $Memory;
my $FreeBytes;
my $FreeMegaBytes;
my $FreeMemory;
my $UsedMemory;

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
		$Memory = "$DetectionError";
		$FreeMemory = "$DetectionError";
		$UsedMemory = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Memory\t$FreeMemory\t$UsedMemory\n");
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
				$Memory = "$DetectionError";
				$FreeMemory = "$DetectionError";
				$UsedMemory = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Memory\t$FreeMemory\t$UsedMemory\n");
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
				# [CAPTURE MEMORY INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$TotalBytes = "$objItem->{TotalPhysicalMemory}";

						if ((!defined $TotalBytes) or ($TotalBytes !~ m/\d/))
							{
							$Memory = "$DetectionError";
							}
						else
							{
							$MegaBytes = $TotalBytes/1000000; # Convert bytes to megabytes
							$Memory = substr($MegaBytes, 0, 6); # Limit number of digits to display
							$Memory =~ s/\..*//; # Trim off trailing '.' if exists
							}
						# [CAPTURE MEMORY IN USE INFORMATION]
						my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_PerfFormattedData_PerfOS_Memory", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

						foreach my $objItem (in $colItems)
							{
							$FreeBytes = "$objItem->{AvailableBytes}";

							if ((!defined $FreeBytes) or ($FreeBytes !~ m/\d/))
								{
								$FreeMemory = "$DetectionError";
								$UsedMemory = "$DetectionError";
								}
							else
								{
								$FreeMegaBytes = $FreeBytes/1000000; # Convert bytes to megabytes
								$FreeMemory = substr($FreeMegaBytes, 0, 6); # Limit number of digits to display
								$FreeMemory =~ s/\..*//; # Trim off trailing '.' if exists
								$UsedMemory = ($Memory - $FreeMemory);
								}
							}
						print "  $ScreenLabel3\t$Memory\n  $ScreenLabel4\t$FreeMemory\n  $ScreenLabel5\t$UsedMemory\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Memory\t$FreeMemory\t$UsedMemory\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);