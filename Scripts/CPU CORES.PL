#  ============================================================================================================
#  TITLE:			CPU CORES.PL
#  VERSION:			1.0
#  CREATED:			07/25/2013
#  LAST UPDATE:	07/25/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
# 						** Note: Windows 2003 SP2 requires KB932370 hotfix for core count functionality **
#  PURPOSE:			Capture MS Windows CPU CORE COUNT information for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("CPU CORE REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("CPU DESC"));
my $Column6 = uc(("SOCKET COUNT"));
my $Column7 = uc(("CORE COUNT"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Processor Cores:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Processor CpuDescription:";
my $ScreenLabel4 = "Socket Count:";
my $ScreenLabel5 = "Core Count:";

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

# [CUSTOM VARIABLES]
my $ComputerModel;
my $CpuDescription;
my $SocketID;
my %SocketID;
my $CoreCount;

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
		
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuDescription\t$CoreCount\n");
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
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuDescription\t$CoreCount\n");
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
				# [CAPTURE CPU CORE INFORMATION]
				my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_Processor", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

				foreach my $objItem (in $colItems)
					{
					if (Win32::OLE->LastError != "0")
						{
						$CoreCount = "$DetectionError";
						$CpuDescription = "$DetectionError";
						print  "  $WMIErrorMessage - Aborting Query\n\n";
						print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuDescription\t$CoreCount\n");
						}
					else
						{
						$CpuDescription = ("$objItem->{Name}");
						$SocketID = ("$objItem->{SocketDesignation}");
						$CoreCount = ("$objItem->{NumberOfCores}");

						if ((!defined $CpuDescription) or ($CpuDescription !~ "."))
							{
							$CpuDescription = "$DetectionError";
							}
						if ((!defined $SocketID) or ($SocketID !~ "."))
							{
							$SocketID = "$DetectionError";
							}
						if ((!defined $CoreCount) or ($CoreCount !~ "."))
							{
							$CoreCount = "$DetectionError";
							}					
						$SocketID{$objItem->{SocketDesignation}}=1;
						}
					}
				print "  $ScreenLabel3\t$CpuDescription\n\n  $ScreenLabel4\t\t\t".scalar(keys %SocketID)."\n  $ScreenLabel5\t\t\t$CoreCount\n";
				print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuDescription\t".scalar(keys %SocketID)."\t$CoreCount\n");
				}
			}
		}
	}
}
close(IN);
close(OUT);