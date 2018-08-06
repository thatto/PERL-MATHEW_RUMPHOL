#  ============================================================================================================
#  TITLE:			NICINFO.PL
#  VERSION:			2.2
#  CREATED:			07/13/2010
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture CONNECTED NETWORK ADAPTER INFORMATION on remote Windows systems using WMI

#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("NICINFO REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("ADAPTER"));
my $Column6 = uc(("DESCRIPTION"));
my $Column7 = uc(("STATUS"));
my $Column8 = uc(("SPEED"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Network Adapter Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Adapter:";
my $ScreenLabel4 = "Description:";
my $ScreenLabel5 = "Status:";
my $ScreenLabel6 = "Speed:";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "Connection Failed";
my $WMIErrorMessage = "Inquiry Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** VIRTUAL NAME DETECTED ***";
my $VirtualNameStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [CUSTOM VARIABLES]
my $ConnectionStatus;
my $NetworkAdapterDescription;
my $NicCaption;
my $NicName;
my $NicSpeed;

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
		$ConnectionStatus = "$DetectionError";
		$NetworkAdapterDescription = "$DetectionError";
		$NicCaption = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$NicCaption\t$NetworkAdapterDescription\t$ConnectionStatus\n");
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
				$ConnectionStatus = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$NicCaption\t$NetworkAdapterDescription\t$ConnectionStatus\n");
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
					# [CAPTURE NETWORK ADAPTER INFORMATION]
					my @computers = ("$RealComputerName");

					foreach my $Computer (@computers)
						{
						my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_NetworkAdapter WHERE NetConnectionStatus = '2'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

						foreach my $objItem (in $colItems)
							{
							if (Win32::OLE->LastError != "0")
								{
								$ConnectionStatus = "$DetectionError";
								$NetworkAdapterDescription = "$DetectionError";
								$NicCaption = "$DetectionError";
								$NicSpeed = "$DetectionError";
								}
							else
								{
								$ConnectionStatus = "$objItem->{NetConnectionStatus}";
								$NetworkAdapterDescription = "$objItem->{NetConnectionID}";
								$NicCaption = "$objItem->{Caption}";
								$NicSpeed = "$objItem->{Speed}";
								}
							if ((!defined $ConnectionStatus) or ($ConnectionStatus !~ "."))
								{
								$ConnectionStatus = "$DetectionError";
								}
						elsif ($ConnectionStatus == '2')
								{
								$ConnectionStatus = "Connected";
								}								
							if ((!defined $NetworkAdapterDescription) or ($NetworkAdapterDescription !~ "."))
								{
								$NetworkAdapterDescription = "$DetectionError";
								}
							if ((!defined $NicCaption) or ($NicCaption !~ "."))
								{
								$NicCaption = "$DetectionError";
								}
							if ((!defined $NicSpeed) or ($NicSpeed !~ "."))
								{
								$NicSpeed = "$DetectionError";
								}								
						elsif ($NicSpeed > '1')
								{
								$NicSpeed = $NicSpeed/1000000; # Convert bytes to megabits
								}
							print "  $ScreenLabel3\t$NicCaption\n  $ScreenLabel4\t$NetworkAdapterDescription\n  $ScreenLabel5\t$ConnectionStatus\n  $ScreenLabel6\t$NicSpeed\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$NicCaption\t$NetworkAdapterDescription\t$ConnectionStatus\t$NicSpeed\n");
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