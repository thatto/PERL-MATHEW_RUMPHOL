#  ============================================================================================================
#  TITLE:			PERF_PAGE_TABLE_ENTRIES.PL
#  VERSION:			3.3
#  CREATED:			01/13/2009
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows performance counter FREE PAGE TABLE ENTRY values for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("PAGE TABLE ENTRIES.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("AVAILABLE PTE"));
my $Column6 = uc(("PTE STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Page Table Entries:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Free PTE:";
my $ScreenLabel4 = "Status:";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "Connection Failed";
my $WMIErrorMessage = "Inquiry Failed";
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
my $PteEntryCount;

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
		$PteEntryCount = "$DetectionError";
		$PteEntryStatus = "$UnknownStatus";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PteEntryCount\t$PteEntryStatus\n");
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
				$PteEntryCount = "$DetectionError";
				$PteEntryStatus = "$UnknownStatus";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PteEntryCount\t$PteEntryStatus\n");
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
				# [CAPTURE FREE PTE INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT *  FROM Win32_PerfFormattedData_PerfOS_Memory", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$PteEntryCount = "$objItem->{FreeSystemPageTableEntries}\n";
						
						if ((!defined $PteEntryCount) or ($PteEntryCount !~ m/\d/))
							{
							$PteEntryCount = "$DetectionError";
							}
						else
							{
							$PteEntryCount =~ s/\n//; # Trim off trailing carrage return if exists
							}
						if ($PteEntryCount <= '8000')
							{
							$PteEntryStatus = "$WarningStatus";
							}
					elsif ($PteEntryCount < '3000')
							{
							$PteEntryStatus = "$CriticalStatus";
							}
					elsif ($PteEntryCount > '8000')
							{
							$PteEntryStatus = "$PassStatus";
							}
						print "  $ScreenLabel3\t$PteEntryCount\n  $ScreenLabel4\t$PteEntryStatus\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PteEntryCount\t$PteEntryStatus\n");							
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);