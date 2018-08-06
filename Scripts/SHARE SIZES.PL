#  ============================================================================================================
#  TITLE:         SHARE SIZES.PL
#  VERSION:       2.2
#  CREATED:			10/13/2008
#  LAST UPDATE:   03/26/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows SHARE SIZE information for a list of computers
#  ============================================================================================================
use strict;
#use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("SHARE SIZES REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("SHARE NAME"));
my $Column6 = uc(("PATH"));
my $Column7 = uc(("SIZE (Bytes)"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Share Sizes:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Share Name:";
my $ScreenLabel4 = "Share Path:";
my $ScreenLabel5 = "Size (Bytes):";

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
my $ShareName;
my $SharePath;
my $UNCSharePath;
my $ShareSize;
my $UNCDrive;
my $UNCPath;
my $Directory;

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
		my $ShareName = "$DetectionError";
		my $SharePath = "$DetectionError";
		my $UNCSharePath = "$DetectionError";
		my $ShareSize = "$DetectionError";
		my $UNCDrive = "$DetectionError";
		my $UNCPath = "$DetectionError";
		my $Directory = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ShareName\t$SharePath\t$ShareSize\n");
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
				my $ShareName = "$DetectionError";
				my $SharePath = "$DetectionError";
				my $UNCSharePath = "$DetectionError";
				my $ShareSize = "$DetectionError";
				my $UNCDrive = "$DetectionError";
				my $UNCPath = "$DetectionError";
				my $Directory = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ShareName\t$SharePath\t$ShareSize\n");
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
						# [CAPTURE SHARE INFORMATION]
						my @computers = ("$RealComputerName");

						foreach my $Computer (@computers)
							{
							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2");

							my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_Share WHERE Type = '0'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

							foreach my $objItem (in $colItems)
								{
								$ShareName = "$objItem->{Name}";
								$SharePath = " $objItem->{Path}";
								$SharePath =~ s/ //; # strip off the spaces
								$UNCDrive = substr($SharePath, 0, 1); # get the drive letter
								$UNCPath = substr($SharePath, 3, 255); # get the remainder of the path

								if ((!defined $ShareName) or ($ShareName !~ "."))
									{
									$ShareName = "$DetectionError";
									}
							elsif ((!defined $SharePath) or ($SharePath !~ "."))
									{
									$SharePath = "$DetectionError";
									}
								else
									{
									my $Directory = "\\\\$RealComputerName\\$UNCDrive\$\\$UNCPath";
									my ($ShareSize)=((qx{dir /s "$Directory"})[-2]=~/([\d,]+) bytes/);

								if ($ShareSize eq "")
									{
									$ShareSize = "0";
									}
								print "  $ScreenLabel3\t\t$ShareName\n  $ScreenLabel4\t\t$SharePath\n  $ScreenLabel5\t\t$ShareSize\n\n";
								print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ShareName\t$SharePath\t$ShareSize\n");
								}
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