#  ========================================================================================
#  TITLE:			HOTFIXES.PL
#  VERSION:			2.3
#  CREATED:			01/21/2009
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows HOTFIX information for a list of computers using WMI
#  ========================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("HOTFIX REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("HOTFIX"));
my $Column6 = uc(("DATE"));
my $Column7 = uc(("INSTALLED BY"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Hotfixes:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Hotfix:";
my $ScreenLabel4 = "Install Date:";

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
my $HotFixID;
my $HotFixInAffect;
my $InstallDate;
my $Installer;

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
		$HotFixID = "$DetectionError";
		$InstallDate = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HotFixID\t$InstallDate\n");
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
				$HotFixID = "$DetectionError";
				$InstallDate = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HotFixID\t$InstallDate\n");
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
				# [CAPTURE HOTFIX INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_QuickFixEngineering WHERE HotFixID like 'k%'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$HotFixID = uc(("$objItem->{HotFixID}"));
						$HotFixInAffect = uc(("$objItem->{ServicePackInEffect}"));
						$InstallDate = uc(("$objItem->{InstalledOn}"));
						$Installer = uc(("$objItem->{InstalledBy}"));

						if ((!defined $HotFixInAffect) or ($HotFixInAffect !~ m/\d/))
							{
							$HotFixInAffect = "$DetectionError";
							}
						if ((!defined $HotFixID) or ($HotFixID !~ "."))
							{
							$HotFixID = "$DetectionError";
							}
					elsif ($HotFixID !~ /KB/)
							{
							$HotFixID = "$HotFixInAffect";
							}
						if ((!defined $InstallDate) or ($InstallDate !~ m/\d/))
							{
							$InstallDate = "$DetectionError";
							}
						if ((!defined $Installer) or ($Installer !~ /\\/))
							{
							$Installer = "$DetectionError";
							}
						print "  $HotFixID\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HotFixID\t$InstallDate\t$Installer\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);