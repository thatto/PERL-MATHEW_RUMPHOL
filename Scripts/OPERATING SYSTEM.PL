#  ============================================================================================================
#  TITLE:			OPERATING SYSTEM.PL
#  VERSION:			5.8
#  CREATED:			12/03/2008
#  LAST UPDATE:	12/02/2015
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows OPERATING SYSTEM and SERVICE PACK version information for a list of
#						MS Windows computers, to determine if currently supported OS and service pack are installed
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("OPERATING SYSTEM REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("OPERATING SYSTEM"));
my $Column6 = uc(("OS STATUS"));
my $Column7 = uc(("OS COMMENT"));
my $Column8 = uc(("SERVICE PACK"));
my $Column9 = uc(("SERVICE PACK STATUS"));
my $Column10 = uc(("SERVICE PACK COMMENT"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Microsoft Windows Operating System & Service Pack:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Installed OS:";
my $ScreenLabel4 = "Service Pack:";
my $ScreenLabel5 = "Status:";

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

# [AUDIT CRITERIA VARIABLES]
my $CurrentWinNTServicePack = "6";
my $CurrentWin2000ServicePack = "4";
my $CurrentWin2003ServicePack = "2";
my $CurrentWin2008R2ServicePack = "1";
my $CurrentWinXPServicePack = "3";
my $CurrentWinVistaServicePack = "2";
my $CurrentWin7ServicePack = "1";
my $CurrentWin8ServicePack = "2";
my $CurrentWin81ServicePack = "";
my $CurrentWin10ServicePack = "";
my $CurrentWin2012ServicePack = "";

my $PassStatus = "Pass";
my $FailStatus = "Fail";
my $CurrentOsStatus = "Supported OS";
my $EolOsStatus = "End of Life OS";
my $CurrentSpStatus = "Current Service Pack";
my $CurrentSpStatusNR = "No Service Pack Required";

# [CUSTOM VARIABLES]
my $OperatingSystem;
my $OperatingSystemStatus;
my $OperatingSystemStatusMsg;
my $ServicePack;
my $ServicePackStatus;
my $ServicePackStatusMsg;


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
		$OperatingSystem = "$DetectionError";
		$OperatingSystemStatus = "$UnknownStatus";
		$ServicePack = "$DetectionError";
		$ServicePackStatus = "$UnknownStatus";
		$ServicePackStatusMsg = "$UnknownStatus";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OperatingSystem\t$OperatingSystemStatus\t$OperatingSystemStatusMsg\t$ServicePack\t$ServicePackStatus\\t$ServicePackStatusMsg\n");
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
			$OperatingSystem = "$DetectionError";
			$OperatingSystemStatus = "$UnknownStatus";
			$ServicePack = "$DetectionError";
			$ServicePackStatus = "$UnknownStatus";
			$ServicePackStatusMsg = "$UnknownStatus";
			print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
			print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OperatingSystem\t$OperatingSystemStatus\t$OperatingSystemStatusMsg\t$ServicePack\t$ServicePackStatus\\t$ServicePackStatusMsg\n");
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
				# [CAPTURE OPERATING SYSTEM & SERVICEPACK INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_OperatingSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$OperatingSystem = uc(("$objItem->{Caption}"));
						$ServicePack = uc(("$objItem->{CSDVersion}"));
						
						if ((!defined $OperatingSystem) or ($OperatingSystem !~ "."))
							{
							$OperatingSystem = "$DetectionError";
							}
						if (!defined $ServicePack)
							{
							$ServicePack = "$DetectionError";
							}
						if (($OperatingSystem =~ /2008/) & ($ServicePack =~ $CurrentWin7ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /2008/) & ($ServicePack !~ $CurrentWin7ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin7ServicePack Required to Pass";
							}							
						if (($OperatingSystem =~ /2008 R2/) & ($ServicePack =~ $CurrentWin2008R2ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /2008 R2/) & ($ServicePack !~ $CurrentWin2008R2ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin2008R2ServicePack Required to Pass";
							}

						if (($OperatingSystem =~ /2003/) & ($ServicePack =~ $CurrentWin7ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /2003/) & ($ServicePack !~ $CurrentWin2003ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin2003ServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /2000/) & ($ServicePack =~ $CurrentWin2000ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /2000/) & ($ServicePack !~ $CurrentWin2000ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin2000ServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /WINDOWS NT/) & ($ServicePack =~ $CurrentWinNTServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /WINDOWS NT/) & ($ServicePack !~ $CurrentWinNTServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWinNTServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /XP/) & ($ServicePack =~ $CurrentWinXPServicePack))
							{
							$OperatingSystemStatus = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /XP/) & ($ServicePack !~ $CurrentWinXPServicePack))
							{
							$OperatingSystemStatus = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWinXPServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /VISTA/) & ($ServicePack =~ $CurrentWinVistaServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /VISTA/) & ($ServicePack !~ $CurrentWinVistaServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWinVistaServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /7/) & ($ServicePack =~ $CurrentWin7ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /7/) & ($ServicePack !~ $CurrentWin7ServicePack))
							{
							$OperatingSystemStatus = "$FailStatus";
							$OperatingSystemStatusMsg = "$EolOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin7ServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /8.0/) & ($ServicePack =~ $CurrentWin8ServicePack))
							{
							$OperatingSystemStatus = "$CurrentOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /8.0/) & ($ServicePack !~ $CurrentWin8ServicePack))
							{
							$OperatingSystemStatus = "$CurrentOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin81ServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /8.1/) & ($ServicePack =~ $CurrentWin81ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}
					elsif (($OperatingSystem =~ /8.1/) & ($ServicePack !~ $CurrentWin81ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin81ServicePack Required to Pass";
							}
						if (($OperatingSystem =~ /10/) & ($ServicePack =~ $CurrentWin10ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatus";
							}							
					elsif (($OperatingSystem =~ /10/) & ($ServicePack !~ $CurrentWin10ServicePack))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$FailStatus";
							$ServicePackStatusMsg = "Service Pack $CurrentWin2012ServicePack Required to Pass";
							}							
						if (($OperatingSystem =~ /2012/) & ($ServicePack !~ "."))
							{
							$OperatingSystemStatus = "$PassStatus";
							$OperatingSystemStatusMsg = "$CurrentOsStatus";
							$ServicePackStatus = "$PassStatus";
							$ServicePackStatusMsg = "$CurrentSpStatusNR";
							}							
						print "  $ScreenLabel3\t$OperatingSystem\n  $ScreenLabel5\t$OperatingSystemStatus ($OperatingSystemStatusMsg)\n\n  $ScreenLabel4\t$ServicePack\n  $ScreenLabel5\t$ServicePackStatus ($ServicePackStatusMsg)\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OperatingSystem\t$OperatingSystemStatus\t$OperatingSystemStatusMsg\t$ServicePack\t$ServicePackStatus\t$ServicePackStatusMsg\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);