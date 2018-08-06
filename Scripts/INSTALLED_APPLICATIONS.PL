#  ============================================================================================================
#  TITLE:			INSTALLED_APPLICATIONS.PL
#  VERSION:			1.1
#  CREATED:			01/21/2009
#  LAST UPDATE:	05/12/2009
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows SERVICES information for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $ReportName = "INSTALLED_APPLICATIONS_REPORT.TXT";
my $SourceList = uc(("PINGABLE.TXT"));

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("SERVER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("VIRTUAL NAME"));
my $Column5 = uc(("APPLICATION"));
my $Column6 = uc(("DATE"));
my $Column7 = uc(("VERSION"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "FAIL - CANNOT OPEN FILE: $input";
open OUT, ">", $output or die "FAIL - CANNOT OPEN FILE: $output";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Applications:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Application:";
my $ScreenLabel4 = "Install Date:";
my $ScreenLabel5 = "Version:";

# [ERROR HANDLING VARIABLES]
my $SuccessMessage = "Connected";
my $ErrorMessage = "Connection Failed";
my $AuditErrorMessage = "Inquiry Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** VIRTUAL NAME DETECTED ***";
my $VirtualNameStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my $Application;
my $InstallDate;
my $AppVersion;

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
		$Application = "$DetectionError";
		$InstallDate = "$DetectionError";
		$AppVersion = "$DetectionError";

		print  "  $ScreenLabel3\t$ErrorMessage\n  $ScreenLabel4\n  $ScreenLabel5\n\n";
		print OUT ("$ErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Application\t$InstallDate\t$AppVersion\n");
		}
	else
		{
		# [CAPTURE THE REAL COMPUTER NAME]
		my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_OperatingSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

		foreach my $objItem (in $colItems)
			{
			$RealComputerName = uc(("$objItem->{CSName}"));

			if ($RealComputerName !~ ".")
				{
				$RealComputerName = "$DetectionError";
				$VirtualNameStatus = "$UnknownStatus";
				$Application = "$DetectionError";
				$InstallDate = "$DetectionError";
				$AppVersion = "$DetectionError";
				print  "  $ScreenLabel3\t$AuditErrorMessage\n  $ScreenLabel4\n  $ScreenLabel5\n\n";
				print OUT ("$AuditErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Application\t$InstallDate\t$AppVersion\n");
				}
			else
				{
				# [DETECT VIRTUAL NAME IN SOURCE LIST]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					if ($RealComputerName eq "$ComputerName")
						{
						$VirtualNameStatus = "No";
						}
					else
						{
						$VirtualNameStatus = "Yes";
						print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
						}
					# [CAPTURE INSTALLED APPLICATIONS]
					my @computers = ("$RealComputerName");

					foreach my $Computer (@computers)
						{
						my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32Reg_AddRemovePrograms", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

						foreach my $objItem (in $colItems)
							{
							$Application = ($objItem->{DisplayName});

							if (!defined $Application)
								{
								$Application = "$DetectionError";
								}

							$InstallDate = ($objItem->{InstallDate});

							if (!defined $InstallDate)
								{
								$InstallDate = "$DetectionError";
								}

							$AppVersion = ($objItem->{Version});

							if (!defined $AppVersion)
								{
								$AppVersion = "$DetectionError";
								}
							print " $ScreenLabel3\t$Application\n";
							print " $ScreenLabel4\t$InstallDate\n";
							print " $ScreenLabel5\t$AppVersion\n\n";
							print OUT ("$SuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$Application\t$InstallDate\t$AppVersion\n");
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