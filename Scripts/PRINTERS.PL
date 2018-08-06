#  ============================================================================================================
#  TITLE:			PRINTERS.PL
#  VERSION:			1.4
#  CREATED:			02/02/2011
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows PRINTER information for a list of computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("PRINTER REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("PRINTER NAME"));
my $Column6 = uc(("PRINTER PORT"));
my $Column7 = uc(("LOCATION"));
my $Column8 = uc(("SHARE NAME"));
my $Column9 = uc(("DRIVER"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Printers:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Printer Name:";
my $ScreenLabel4 = "Printer Port:";
my $ScreenLabel5 = "Location:";
my $ScreenLabel6 = "Share Name:";
my $ScreenLabel7 = "Driver:";

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
my $PrinterName;
my $PrinterPort;
my $Location;
my $ShareName;
my $Driver;

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
		$PrinterName = "$DetectionError";
		$PrinterPort = "$DetectionError";
		$Location = "$DetectionError";
		$ShareName = "$DetectionError";
		$Driver = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PrinterName\t$PrinterPort\t$Location\t$ShareName\t$Driver\n");
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
				$PrinterName = "$DetectionError";
				$PrinterPort = "$DetectionError";
				$Location = "$DetectionError";
				$ShareName = "$DetectionError";
				$Driver = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PrinterName\t$PrinterPort\t$Location\t$ShareName\t$Driver\n");
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
				# [CAPTURE PRINTER INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_Printer", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$PrinterName = uc(("$objItem->{DeviceID}"));
						$PrinterPort = uc(("$objItem->{PortName}"));
						$Location = uc(("$objItem->{Location}"));
						$ShareName = uc(("$objItem->{ShareName}"));
						$Driver = uc(("$objItem->{DriverName}"));
						
						if ((!defined $PrinterName) or ($PrinterName !~ "."))
							{
							$PrinterName = "$DetectionError";
							}
						if ((!defined $PrinterPort) or ($PrinterPort !~ "."))
							{
							$PrinterPort = "$DetectionError";
							}
					elsif ($PrinterPort =~ m/\d/)
							{
							$PrinterPort =~ s/IP_//; # Trim off 'IP_' if exists
							}
						if ((!defined $Location) or ($Location !~ "."))
							{
							$Location = "$DetectionError";
							}
						if ((!defined $ShareName) or ($ShareName !~ "."))
							{
							$ShareName = "$DetectionError";
							}
						if ((!defined $Driver) or ($Driver !~ "."))
							{
							$Driver = "$DetectionError";
							}								
						print "  $ScreenLabel3 $PrinterName\n  $ScreenLabel4 $PrinterPort\n  $ScreenLabel5 $Location\n  $ScreenLabel6 $ShareName\n  $ScreenLabel7 $Driver\n  ----------------------------------------------------\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$PrinterName\t$PrinterPort\t$Location\t$ShareName\t$Driver\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);