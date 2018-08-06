#  ============================================================================================================
#  TITLE:			DISK MAPPING.PL
#  VERSION:			1.2
#  CREATED:			10/11/2011
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows PHYSICAL DISK to LOGICAL DRIVE letter mapping for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $ReportName = uc(("DISK MAPPING REPORT.TXT"));
my $SourceList = uc(("PINGABLE.TXT"));

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DRIVE"));
my $Column6 = uc(("DISK ID"));
my $Column7 = uc(("PARTITION"));


my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Microsoft Windows Disk Mapping:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Drive Letter:";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "WMI Connection Failed";
my $WMIErrorMessage = "WMI Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $NameMismatchDetection = "*** NAME MISMATCH DETECTED ***";
my $NameMismatchStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [AUDIT CRITERIA VARIABLES]

# [CUSTOM VARIABLES]
my $LogicalDrive;
my $PhysicalDisk;

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
		$NameMismatchStatus = "$UnknownStatus";
		$LogicalDrive = "$DetectionError";
		$PhysicalDisk = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$LogicalDrive\t$PhysicalDisk\n");
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
			$NameMismatchStatus = "$UnknownStatus";
			$LogicalDrive = "$DetectionError";
			$PhysicalDisk = "$DetectionError";
			print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
			print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$LogicalDrive\t$PhysicalDisk\n");
			}
		else
			{
			# [DETECT NAME MISMATCH IN SOURCE LIST]
			if ($RealComputerName eq "$ComputerName")
				{
				$NameMismatchStatus = "No";
				}
			else
				{
				$NameMismatchStatus = "Yes";
				print "  $NameMismatchDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
				}
				# [CAPTURE DISK INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_LogicalDiskToPartition", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$LogicalDrive = uc(("$objItem->{Dependent}"));
						$PhysicalDisk = uc(("$objItem->{Antecedent}"));
						
						if ((!defined $LogicalDrive) or ($LogicalDrive !~ "."))
							{
							$LogicalDrive = "$DetectionError";
							}
						else
							{
							$LogicalDrive =~ s/\\\\$RealComputerName\\ROOT\\CIMV2:WIN32_LOGICALDISK\.DEVICEID=\"//ig;
							$LogicalDrive =~ s/\"//;
							$LogicalDrive =~ s/://;
							}
						if ((!defined $PhysicalDisk) or ($PhysicalDisk !~ "."))
							{
							$PhysicalDisk = "$DetectionError";
							}
						else
							{
							$PhysicalDisk =~ s/\\\\$RealComputerName\\ROOT\\CIMV2:WIN32_DISKPARTITION\.DEVICEID=\"//ig;
							$PhysicalDisk =~ s/\"//;
							$PhysicalDisk =~ s/\#//ig;
							$PhysicalDisk =~ s/, /\t/;
							}
						print "  $ScreenLabel3 $LogicalDrive = $PhysicalDisk\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$LogicalDrive\t$PhysicalDisk\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);