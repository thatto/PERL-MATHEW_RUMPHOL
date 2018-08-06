#  ============================================================================================================
#  TITLE:			MODEL AND BIOS.PL
#  VERSION:			4.3
#  CREATED:			12/03/2008
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture COMPUTER MFG, MODEL & BIOS VERSION information for a list of MS Windows computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("MODEL AND BIOS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("MFG"));
my $Column6 = uc(("MODEL"));
my $Column7 = uc(("BIOS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Computer Mfg, Model & BIOS Version:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Mfg:";
my $ScreenLabel4 = "Model:";
my $ScreenLabel5 = "BIOS Ver:";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "WMI Connection Failed";
my $WMIErrorMessage = "WMI Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STATUS HANDLING VARIABLES]
my $PassStatus = "";
my $FailStatus = "";
my $WarningStatus = "";
my $ModelStatus;
my $BiosStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;

# [CUSTOM VARIABLES]
my $ComputerMfg;
my $ComputerModel;
my $BiosVersion;
my $VmBiosVersion = "N/A";

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
		$ComputerMfg = "$DetectionError";
		$ComputerModel = "$DetectionError";
		$BiosVersion = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ComputerMfg\t$ComputerModel\t$BiosVersion\n");
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
				$ComputerMfg = "$DetectionError";
				$ComputerModel = "$DetectionError";
				$BiosVersion = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ComputerMfg\t$ComputerModel\t$BiosVersion\n");
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
					# [CAPTURE MFG & MODEL INFORMATION]
					my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$ComputerMfg = uc(("$objItem->{Manufacturer}"));
						$ComputerModel = uc(("$objItem->{Model}"));
						
						if ((!defined $ComputerModel) or ($ComputerModel !~ "."))
							{
							$ComputerMfg = "$DetectionError";
							$ComputerModel = "$DetectionError";
							$BiosVersion = "$DetectionError";
							}
						if ((!defined $ComputerMfg) or ($ComputerMfg !~ "."))
							{
							$ComputerMfg = "$DetectionError";
							$BiosVersion = "$DetectionError";
							}							
						# [CAPTURE BIOS INFORMATION]
						if (($ComputerModel ne "$DetectionError") and ($ComputerMfg ne "$DetectionError"))
							{
							my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_BIOS", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

							foreach my $objItem (in $colItems)
								{
							 $BiosVersion = uc(("$objItem->{SMBIOSBIOSVersion}"));

								if ((!defined $BiosVersion) or ($BiosVersion !~ "."))
									{
									$BiosVersion = "$DetectionError";
									}
							elsif ($ComputerModel =~ m/vmware/ix)
									{
									$BiosVersion = "$VmBiosVersion";							
									}								  
								print "  $ScreenLabel3\t\t$ComputerMfg\n  $ScreenLabel4\t$ComputerModel\n  $ScreenLabel5\t$BiosVersion\n\n";
								print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ComputerMfg\t$ComputerModel\t$BiosVersion\n");
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