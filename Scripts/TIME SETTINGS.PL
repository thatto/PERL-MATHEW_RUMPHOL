#  ===================================================================================================================
#  TITLE:			TIME SETTINGS.PL
#  VERSION:			1.3
#  CREATED:			01/21/2009
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture TIME, DATE, TIME ZONE and DAYLIGHT SAVINGS TIME values for a list of computers using WMI
#  ===================================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("TIME SETTINGS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("TIMEZONE"));
my $Column6 = uc(("LOCAL TIME"));
my $Column7 = uc(("REMOTE TIME"));
my $Column8 = uc(("LOCAL DATE"));
my $Column9 = uc(("REMOTE DATE"));
my $Column10 = ("GMT OFFSET");

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Time Settings:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Time Zone:";
my $ScreenLabel4 = "GMT Offset:";
my $ScreenLabel5 = "Local Time:";
my $ScreenLabel6 = "Remote Time:";
my $ScreenLabel7 = "Local Date:";
my $ScreenLabel8 = "Remote Date:";

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
my $Year;
my $Month;
my $Day;
my $Hour;
my $Minute;
my $LocalDate;
my $LocalTime;
my $RemoteDate;
my $RemoteTime;
my $TimeZone;
my $TimeZoneOffSet;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n";

# [TEST WMI CONNECTION]
my @computers = ("$ComputerName");

foreach my $Computer (@computers)
	{
	($LocalDate,$LocalTime) = &time_stamp();

	Win32::OLE->LastError(0);
	Win32::OLE->Option(Warn => 0);
	my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2");

	if (Win32::OLE->LastError != "0")
		{
		$RealComputerName = "$DetectionError";
		$VirtualNameStatus = "$UnknownStatus";
		$TimeZone = "$DetectionError";
		$RemoteTime = "$DetectionError";
		$RemoteDate = "$DetectionError";
		$TimeZoneOffSet = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$TimeZone\t$LocalTime\t$RemoteTime\t$LocalDate\t$RemoteDate\t$TimeZoneOffSet\n");
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
				$TimeZone = "$DetectionError";
				$RemoteTime = "$DetectionError";
				$RemoteDate = "$DetectionError";
				$TimeZoneOffSet = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$TimeZone\t$LocalTime\t$RemoteTime\t$LocalDate\t$RemoteDate\t$TimeZoneOffSet\n");
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
					# [CAPTURE LOCAL AND REMOTE TIME SETTINGS]
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_LocalTime", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$Year = ($objItem->{Year});

						if ((!defined $Year) or ($Year !~ m/\d/))
							{
							$Year = "$DetectionError";
							}

						$Day = ($objItem->{Day});

						if ((!defined $Day) or ($Day !~ m/\d/))
							{
							$Day = "$DetectionError";
							}
						elsif ($Day eq "1")
							{
							$Day = "01";
							}
						elsif ($Day eq "2")
							{
							$Day = "02";
							}
						elsif ($Day eq "3")
							{
							$Day = "03";
							}
						elsif ($Day eq "4")
							{
							$Day = "04";
							}
						elsif ($Day eq "5")
							{
							$Day = "05";
							}
						elsif ($Day eq "6")
							{
							$Day = "06";
							}
						elsif ($Day eq "7")
							{
							$Day = "07";
							}
						elsif ($Day eq "8")
							{
							$Day = "08";
							}
						elsif ($Day eq "9")
							{
							$Day = "09";
							}

						$Month = ($objItem->{Month});

						if ((!defined $Month) or ($Month !~ m/\d/))
							{
							$Month = "$DetectionError";
							}
						elsif ($Month eq "1")
							{
							$Month = "01";
							}
						elsif ($Month eq "2")
							{
							$Month = "02";
							}
						elsif ($Month eq "3")
							{
							$Month = "03";
							}
						elsif ($Month eq "4")
							{
							$Month = "04";
							}
						elsif ($Month eq "5")
							{
							$Month = "05";
							}
						elsif ($Month eq "6")
							{
							$Month = "06";
							}
						elsif ($Month eq "7")
							{
							$Month = "07";
							}
						elsif ($Month eq "8")
							{
							$Month = "08";
							}
						elsif ($Month eq "9")
							{
							$Month = "09";
							}

					  $Minute =  ($objItem->{Minute});

					  if ((!defined $Minute) or ($Minute !~ m/\d/))
							{
							$Minute = "$DetectionError";
							}
						elsif ($Minute eq "0")
							{
							$Minute = "00";
							}
						elsif ($Minute eq "1")
							{
							$Minute = "01";
							}
						elsif ($Minute eq "2")
							{
							$Minute = "02";
							}
						elsif ($Minute eq "3")
							{
							$Minute = "03";
							}
						elsif ($Minute eq "4")
							{
							$Minute = "04";
							}
						elsif ($Minute eq "5")
							{
							$Minute = "05";
							}
						elsif ($Minute eq "6")
							{
							$Minute = "06";
							}
						elsif ($Minute eq "7")
							{
							$Minute = "07";
							}
						elsif ($Minute eq "8")
							{
							$Minute = "08";
							}
						elsif ($Minute eq "9")
							{
							$Minute = "09";
							}

					  $Hour =  ($objItem->{Hour});

					  if ((!defined $Hour) or ($Hour !~ m/\d/))
							{
							$Hour = "$DetectionError";
							}
						elsif ($Hour eq "0")
							{
							$Hour = "00";
							}
						elsif ($Hour eq "1")
							{
							$Hour = "01";
							}
						elsif ($Hour eq "2")
							{
							$Hour = "02";
							}
						elsif ($Hour eq "3")
							{
							$Hour = "03";
							}
						elsif ($Hour eq "4")
							{
							$Hour = "04";
							}
						elsif ($Hour eq "5")
							{
							$Hour = "05";
							}
						elsif ($Hour eq "6")
							{
							$Hour = "06";
							}
						elsif ($Hour eq "7")
							{
							$Hour = "07";
							}
						elsif ($Hour eq "8")
							{
							$Hour = "08";
							}
						elsif ($Hour eq "9")
							{
							$Hour = "09";
							}

						$RemoteTime = ("$Hour:$Minute");

						if  ((!defined $RemoteTime) or ($RemoteTime !~ m/\d/))
							{
							$RemoteTime = "$DetectionError";
							}

						$RemoteDate = ("$Year-$Month-$Day");

						if ((!defined $RemoteDate) or ($RemoteDate !~ m/\d/))
							{
							$RemoteDate = "$DetectionError";
							}

						my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_TimeZone", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

						foreach my $objItem (in $colItems)
							{
							$TimeZoneOffSet = ($objItem->{Bias}/60)-($objItem->{DaylightBias}/60);

							if  ((!defined $TimeZoneOffSet) or ($TimeZoneOffSet !~ m/\d/))
								{
								$TimeZoneOffSet = "$DetectionError";
								}

							$TimeZone = "$objItem->{StandardName}";

							if ((!defined $TimeZone) or ($TimeZone !~ "."))
								{
								$TimeZone = "$DetectionError";
								}
							print "  $ScreenLabel3\t$TimeZone\n";
							print "  $ScreenLabel4\t$TimeZoneOffSet\n\n";
							print "  $ScreenLabel5\t$LocalTime\n";
							print "  $ScreenLabel6\t$RemoteTime\n\n";
							print "  $ScreenLabel7\t$LocalDate\n";
							print "  $ScreenLabel8\t$RemoteDate\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$TimeZone\t$LocalTime\t$RemoteTime\t$LocalDate\t$RemoteDate\t$TimeZoneOffSet\n");
							}
						}
					}
				}
			}
		}
	}
}
sub time_stamp
{
my ($d,$t);
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$year += 1900;
$mon++;
$d = sprintf("%4d-%2.2d-%2.2d",$year,$mon,$mday);
$t = sprintf("%2.2d:%2.2d",$hour,$min);
return($d,$t);
}
close(IN);
close(OUT);