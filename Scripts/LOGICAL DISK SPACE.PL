#  ============================================================================================================
#  TITLE:			LOGICAL DISK SPACE.PL
#  VERSION:			4.7
#  CREATED:			12/03/2008
#  LAST UPDATE:	02/27/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows LOGICAL DISK information values for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $ReportName = uc(("LOGICAL DISK SPACE REPORT.TXT"));
my $SourceList = uc(("PINGABLE.TXT"));

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DRIVE"));
my $Column6 = uc(("FILE SYSTEM"));
my $Column7 = uc(("DESCRIPTION"));
my $Column8 = uc(("SIZE (GB)"));
my $Column9 = uc(("FREE SPACE (GB)"));
my $Column10 = uc(("PERCENT FREE"));
my $Column11 = uc(("FREE SPACE STATUS"));
my $Column12 = uc(("DRIVE LETTER STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "FAIL - CANNOT OPEN FILE: $input";
open OUT, ">", $output or die "FAIL - CANNOT OPEN FILE: $output";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\t$Column11\t$Column12\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Logical Disks:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Disk:";
my $ScreenLabel4 = "Size (GB):";
my $ScreenLabel5 = "Free (GB):";
my $ScreenLabel6 = "% Free:";

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
my $PassStatus = "PASS";
my $FailStatus = "FAIL";
my $FreeSpaceStatus;
my $DriveLetterStatus;
my $HealthyStatus = "OK";
my $CriticalStatus = "CRITICAL";
my $WarningStatus = "WARNING";

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [CUSTOM VARIABLES]
my $Device;
my $FileSys;
my $DriveDescription;
my $DiskSize;
my $DiskFreeSpace;
my $TotalGigaBytes;
my $FreeGigaBytes;
my $FreeGigaBytesRatio;
my $TotalDiskSize;
my $TotalFreeSpace;

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
		$Device = "$DetectionError";
		$FileSys = "$DetectionError";
		$DriveDescription = "$DetectionError";
		$TotalDiskSize = "$DetectionError";
		$TotalFreeSpace = "$DetectionError";
		$FreeGigaBytesRatio = "$DetectionError";
		$FreeSpaceStatus = "$UnknownStatus";
		$DriveLetterStatus = "$UnknownStatus";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Device\t$FileSys\t$DriveDescription\t$TotalDiskSize\t$TotalFreeSpace\t$FreeGigaBytesRatio\t$FreeSpaceStatus\t$DriveLetterStatus\n");
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
			$Device = "$DetectionError";
			$FileSys = "$DetectionError";
			$DriveDescription = "$DetectionError";
			$TotalDiskSize = "$DetectionError";
			$TotalFreeSpace = "$DetectionError";
			$FreeGigaBytesRatio = "$DetectionError";
			$FreeSpaceStatus = "$UnknownStatus";
			$DriveLetterStatus = "$UnknownStatus";
			print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
			print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Device\t$FileSys\t$DriveDescription\t$TotalDiskSize\t$TotalFreeSpace\t$FreeGigaBytesRatio\t$FreeSpaceStatus\t$DriveLetterStatus\n");
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
				# [CAPTURE LOGICAL DISK INFORMATION]
				my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Description like 'Local%'", "WQL", wbemFlagReturnImmediately | wbemFlagForwardOnly);

				foreach my $objItem (in $colItems)
					{
					$Device = "$objItem->{DeviceID}";
					$FileSys = " $objItem->{FileSystem}";
					$DriveDescription = "$objItem->{Description}";
					$DiskSize = "$objItem->{Size}";
					$DiskFreeSpace = "$objItem->{FreeSpace}";

					if ((!defined $Device) or ($Device !~ "."))
						{
						$Device = "$DetectionError";
						$FileSys = "$DetectionError";
						$DriveDescription = "$DetectionError";
						$TotalDiskSize = "$DetectionError";
						$TotalFreeSpace = "$DetectionError";
						$FreeGigaBytesRatio = "$DetectionError";
						$FreeSpaceStatus = "$UnknownStatus";
						$DriveLetterStatus = "$UnknownStatus";
						print  "  $WMIErrorMessage\n\n";
						}
				elsif ($Device =~ ".")
						{
						$Device =~ s/://;
						}						
				elsif ((!defined $FileSys) or ($FileSys !~ "."))
						{
						$FileSys = "$DetectionError";
						$DriveDescription = "$DetectionError";
						$TotalDiskSize = "$DetectionError";
						$TotalFreeSpace = "$DetectionError";
						$FreeGigaBytesRatio = "$DetectionError";
						$FreeSpaceStatus = "$UnknownStatus";
						$DriveLetterStatus = "$UnknownStatus";
						print  "  $WMIErrorMessage\n\n";
						}
				elsif ((!defined $DriveDescription) or ($DriveDescription !~ "."))
						{
						$DriveDescription = "$DetectionError";
						$TotalDiskSize = "$DetectionError";
						$TotalFreeSpace = "$DetectionError";
						$FreeGigaBytesRatio = "$DetectionError";
						$FreeSpaceStatus = "$UnknownStatus";
						$DriveLetterStatus = "$UnknownStatus";
						print  "  $WMIErrorMessage\n\n";
						}
					if ($DiskSize =~ ".")
						{
						$TotalGigaBytes = $DiskSize/1000000000;
						}
					else
						{
						$DiskSize = "$DetectionError";
						$TotalGigaBytes = "$DetectionError";
						}						
					if ($DiskFreeSpace =~ m/\d/)
						{						
						$FreeGigaBytes = $DiskFreeSpace/1000000000;
						}
					else
						{
						$FreeGigaBytes = "$DetectionError";
						$DiskFreeSpace = "$DetectionError";
						}						
					if ($TotalGigaBytes =~ m/\d/)
						{						
						$TotalDiskSize = substr($TotalGigaBytes, 0, 6);
						}
					else
						{
						$TotalGigaBytes = "$DetectionError";
						$TotalDiskSize = "$DetectionError";
						}						
					if ($FreeGigaBytes =~ ".")
						{						
						$TotalFreeSpace = substr($FreeGigaBytes, 0, 6);
						}
					else
						{
						$FreeGigaBytes = "$DetectionError";
						$TotalFreeSpace = "$DetectionError";
						}						
					if (($FreeGigaBytes > '0') and ($TotalGigaBytes > '0'))
						{
						$FreeGigaBytesRatio = $FreeGigaBytes/$TotalGigaBytes*100;
						$FreeGigaBytesRatio = substr($FreeGigaBytesRatio, 0, 4);
						}
					else
						{
						$FreeGigaBytesRatio = "$DetectionError";
						$FreeSpaceStatus = "$UnknownStatus";
						}						
					#  [CHECK FOR MINIMUM FREE SPACE]
					if ($FreeGigaBytesRatio <= "10")
						{
						$FreeSpaceStatus = "$CriticalStatus";
						}
				elsif ($FreeGigaBytesRatio <= "15")
						{
						$FreeSpaceStatus = "$WarningStatus";
						}						
				elsif ($FreeGigaBytesRatio > "15")
						{
						$FreeSpaceStatus = "$HealthyStatus";
						}
					#  [CHECK FOR ILLEGAL DRIVE LETTERS]
					if ($Device =~ /H/)
						{
						$DriveLetterStatus = $FailStatus;
						}
				elsif ($Device =~ /Q/)
						{
						# [IF DRIVE "Q" DETECTED - CHECK FOR MSCS]
						use Win32::Service;
						my $Service = "ClusSvc";
						my %status;
						my $status;

						Win32::Service::GetStatus( "$RealComputerName","$Service", \%status);

						if ($status{CurrentState} == 1)
							{
							$DriveLetterStatus = "$PassStatus";
							}
					elsif ($status{CurrentState} == 2)
							{
							$DriveLetterStatus = "$PassStatus";
							}
					elsif ($status{CurrentState} == 3)
							{
							$DriveLetterStatus = "$PassStatus";
							}
					elsif ($status{CurrentState} == 4)
							{
							$DriveLetterStatus = "$PassStatus";
							}
						else
							{
							$DriveLetterStatus = "$FailStatus";
							}
						}
					else
						{
						$DriveLetterStatus = "$PassStatus";
						}
					print "  $ScreenLabel3 $Device $ScreenLabel4 $TotalDiskSize\t$ScreenLabel5 $TotalFreeSpace ($FreeGigaBytesRatio %)\tStatus: $FreeSpaceStatus\n\n";
					print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Device\t$FileSys\t$DriveDescription\t$TotalDiskSize\t$TotalFreeSpace\t$FreeGigaBytesRatio\t$FreeSpaceStatus\t$DriveLetterStatus\n");
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);