#  ============================================================================================================
#  TITLE:			DELL DRAC.PL
#  VERSION:			2.2
#  CREATED:			03/12/2010
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture Dell DRAC information for a list of DELL computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("DELL DRAC REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DRAC IP"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Dell DRAC Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "DRAC IP Address:";

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


# [CUSTOM VARIABLES]
my $ComputerModel;
my $VmModel = "V";
my $VmwareDracIp = "N/A";
my $DracIp;

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
		$DracIp = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
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
				$DracIp = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
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
					# [DETECT VIRTUAL MACHINE]
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$ComputerModel = uc(("$objItem->{Model}"));

						if ((!defined $ComputerModel) or ($ComputerModel !~ "."))
							{
							$RealComputerName = "$DetectionError";
							$NameMismatchStatus = "$UnknownStatus";
							$DracIp = "$DetectionError";
							print  "  $WMIErrorMessage\n";
							print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
							}
					elsif ($ComputerModel =~ $VmModel)
							{
							$DracIp = "$VmwareDracIp";
							print "  $VmwareDracIp: $ComputerModel\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
							}
						else
							{
						# [CAPTURE DELL DRAC INFORMATION]
						my @computers = ("$RealComputerName");

						foreach my $Computer (@computers)
							{
							Win32::OLE->LastError(0);
							Win32::OLE->Option(Warn => 0);

							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2\\Dell");
							
							if (Win32::OLE->LastError != "0")
								{
								$DracIp = "$DetectionError";
								print  "  $WMIErrorMessage - Aborting Query\n\n";
								print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
								}
							else
								{
								my $colItems = $objWMIService->ExecQuery("SELECT * FROM Dell_RemoteAccessServicePort", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);
								
								if (Win32::OLE->LastError != "0")
									{
									$DracIp = "$DetectionError";
									print  "  $WMIErrorMessage - Aborting Query\n\n";
									print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
									}
								else
									{
									foreach my $objItem (in $colItems)
										{
										$DracIp = "$objItem->{AccessInfo}";

										if ((!defined $DracIp) or ($DracIp !~ m/\d/) or ($DracIp !~ "."))
											{
											$DracIp = "$DetectionError";
											print  "  $WMIErrorMessage - Aborting Query\n\n";
											print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
											}
										print "  $ScreenLabel3 $DracIp\n\n";
										print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DracIp\n");
										}
									}
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