#  ============================================================================================================
#  TITLE:			PHYSICAL DISKS.PL
#  VERSION:			7.3
#  AUTHOR:			MATHEW RUMPHOL
#  CREATED:			01/15/2009
#  LAST UPDATE:	02/07/2013
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows PHYSICAL DISK information values for a list of computers using WMI
# 						This script accounts for testing Microsoft MSCS servers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("PHYSICAL DISKS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DESCRIPTION"));
my $Column6 = uc(("DISK ID"));
my $Column7 = uc(("SIZE (GB)"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Physical Disk Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Description:";
my $ScreenLabel4 = "Device ID:";
my $ScreenLabel5 = "Size (GB):";

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
my $Description;
my $DiskID;
my $LunSize;
my $TotalGigaBytes;
my $TotalDiskSize;

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
		$Description = "$UnknownStatus";
		$DiskID = "$UnknownStatus";
		$TotalDiskSize = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Description\t$DiskID\t$TotalDiskSize\n");
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
			$Description = "$UnknownStatus";
			$DiskID = "$UnknownStatus";
			$TotalDiskSize = "$DetectionError";
			print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
			print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Description\t$DiskID\t$TotalDiskSize\n");
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
			# [CAPTURE PHYSICAL DISK INFORMATION]
			my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_DiskDrive WHERE MediaType LIKE '%hard disk media%'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$DiskID = " $objItem->{DeviceID}";
						$LunSize = "$objItem->{Size}";
						$Description = "$objItem->{Model}";	
					
						if ((!defined $DiskID) or ($DiskID !~ "."))
							{
							$DiskID = "$DetectionError";
							}
						else
							{
							$DiskID =~ s/ \\\\\.\\//; # strip off the preceeding junk
							$DiskID =~ s/PHYSICALDRIVE/DISK /; # Normalize name of disk ID

							}
						if ((!defined $LunSize) or ($LunSize !~ "."))
							{
							$LunSize = "$DetectionError";
							$TotalGigaBytes = "$DetectionError";
							$TotalDiskSize = "$DetectionError";
							}
						else
							{
							$TotalGigaBytes = $LunSize/1000000000; # Convert bytes to gigabytes
							$TotalDiskSize = substr($TotalGigaBytes, 0, 6); # Limit number of digits displayed
							}
						if ((!defined $Description) or ($Description !~ /./))
							{
							$Description = "$DetectionError";
							}
						print "  $ScreenLabel3\t$Description\n  $ScreenLabel4\t$DiskID\n  $ScreenLabel5\t$TotalDiskSize\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Description\t$DiskID\t$TotalDiskSize\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);