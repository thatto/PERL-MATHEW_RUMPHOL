#  ============================================================================================================
#  TITLE:			RECOVERY_OPTIONS.PL
#  VERSION:			1.6
#  CREATED:			02/15/2011
#  LAST UPDATE:	11/06/2014
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture STARTUP & RECOVERY OPTION values for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

#	 INPUT AND OUTPUT VARIABLES
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("RECOVERY OPTIONS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("AUTO REBOOT"));
my $Column6 = uc(("ADMIN ALERT"));
my $Column7 = uc(("DUMP FILE"));
my $Column8 = uc(("EVENT LOG ENTRY"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Startup & Recovery Options:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Auto Reboot:";
my $ScreenLabel4 = "Send Admin Alert:";
my $ScreenLabel5 = "Dump File Type:";
my $ScreenLabel6 = "Write to Event Log:";

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
my $AutoReboot;
my $AdminAlert;
my $DumpFile;
my $EventLogWrite;

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
		$AutoReboot = "$DetectionError";
		$AdminAlert = "$DetectionError";
		$DumpFile = "$DetectionError";
		$EventLogWrite = "$DetectionError";		
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$AutoReboot\t$AdminAlert\t$DumpFile\t$EventLogWrite\n");
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
				$AutoReboot = "$DetectionError";
				$AdminAlert = "$DetectionError";
				$DumpFile = "$DetectionError";
				$EventLogWrite = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t\t$AutoReboot\t$AdminAlert\t$DumpFile\t$EventLogWrite\n");
				}
			else
				{
				# [DETECT NAME MISMATCH IN SOURCE LIST]
				if ($RealComputerName eq "$ComputerName")
					{
					$VirtualNameStatus = "No";
					}
				else
					{
					$VirtualNameStatus = "Yes";
					print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
					}
				# [CAPTURE SERIAL NUMBER INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_OSRecoveryConfiguration", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$AutoReboot = uc(("$objItem->{AutoReboot}"));
						$AdminAlert = uc(("$objItem->{SendAdminAlert}"));
						$DumpFile = uc(("$objItem->{DebugInfoType}"));
						$EventLogWrite = uc(("$objItem->{WriteToSystemLog}"));
						
						if ((!defined $AutoReboot) or ($AutoReboot !~ m/\d/))
							{
							$AutoReboot = "$DetectionError";
							}
					elsif ($AutoReboot eq "0")
							{
							$AutoReboot = "No";
							}
					elsif ($AutoReboot eq "1")
							{
							$AutoReboot = "Yes";
							}
						if ((!defined $AdminAlert) or ($AdminAlert !~ m/\d/))
							{
							$AdminAlert = "$DetectionError";
							}
					elsif ($AdminAlert eq "0")
							{
							$AdminAlert = "No";
							}
					elsif ($AdminAlert eq "1")
							{
							$AdminAlert = "Yes";
							}
						if ((!defined $DumpFile) or ($DumpFile !~ m/\d/))
							{
							$DumpFile = "$DetectionError";
							}
					elsif ($DumpFile !~ m/\d/)
							{
							$DumpFile = "$DetectionError";
							}
					elsif ($DumpFile eq "0")
							{
							$DumpFile = "No Dump File";
							}
					elsif ($DumpFile eq "1")
							{
							$DumpFile = "Complete Memory Dump";
							}							
					elsif ($DumpFile eq "2")
							{
							$DumpFile = "Kernel Memory Dump";
							}
					elsif ($DumpFile eq "3")
							{
							$DumpFile = "Mini Memory Dump";
							}
					elsif ($DumpFile eq "7")
							{
							$DumpFile = "Automatic Memory Dump";
							}							
						if ((!defined $EventLogWrite) or ($EventLogWrite !~ m/\d/))
							{
							$EventLogWrite = "$DetectionError";
							}
					elsif ($EventLogWrite eq "0")
							{
							$EventLogWrite = "No";
							}
					elsif ($EventLogWrite eq "1")
							{
							$EventLogWrite = "Yes";
							}
						print "  $ScreenLabel3\t\t$AutoReboot\n  $ScreenLabel4\t$AdminAlert\n  $ScreenLabel5\t$DumpFile\n  $ScreenLabel6\t$EventLogWrite\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$AutoReboot\t$AdminAlert\t$DumpFile\t$EventLogWrite\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);