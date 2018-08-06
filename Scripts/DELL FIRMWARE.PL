#  ============================================================================================================
#  TITLE:			DELL FIRMWARE.PL
#  VERSION:			2.3
#  CREATED:			12/01/2015
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture DRAC Firmware information for a list of DELL servers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $ReportName = uc(("DELL FIRMWARE REPORT.TXT"));
my $SourceList = uc(("PINGABLE.TXT"));

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("COMPONENT"));
my $Column6 = uc(("FIRMWARE VERSION"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Dell Firmware:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Ver:";

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
my $VmComponent = "N/A";
my $VmVersion = "N/A";
my $Component;
my $Version;

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
		$Component = "$DetectionError";
		$Version = "$DetectionError";		
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
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
				$Component = "$DetectionError";
				$Version = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
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
							$Component = "$DetectionError";
							$Version = "$DetectionError";
							print  "  $WMIErrorMessage\n";
							print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
							}
					elsif ($ComputerModel =~ $VmModel)
							{
							$Component = "$VmComponent";
							$Version = "$VmVersion";
							print "  $VmComponent: $ComputerModel\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
							}
						else
							{
						# [CAPTURE DELL FIRMWARE INFORMATION]
						my @computers = ("$RealComputerName");

						foreach my $Computer (@computers)
							{
							Win32::OLE->LastError(0);
							Win32::OLE->Option(Warn => 0);

							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2\\Dell");
							
							if (Win32::OLE->LastError != "0")
								{
								$Component = "$DetectionError";
								$Version = "$DetectionError";		
								print  "  $WMIErrorMessage - Aborting Query\n\n";
								print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
								}
							else
								{							
								my $colItems = $objWMIService->ExecQuery("SELECT * FROM Dell_CMApplication  WHERE componentType = 'FRMW'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);
								if (Win32::OLE->LastError != "0")
									{
									$Component = "$DetectionError";
									$Version = "$DetectionError";		
									print  "  $WMIErrorMessage - Aborting Query\n\n";
									print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
									}
								else
									{
									foreach my $objItem (in $colItems)
										{
										$Component = "$objItem->{name}";
										$Version = "$objItem->{version}";

										if ((!defined $Component) or ($Component !~ "."))
											{
											$Component = "$DetectionError";
											}
									elsif ($Component =~ ".") # Trim the word Firmware out of string
											{
											$Component =~ s/ Firmware//;
											}
										if ((!defined $Version) or ($Version !~ "."))
											{
											$Version = "$DetectionError";
											}
										print "  $Component\t$ScreenLabel3 $Version\n\n";
										print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$Component\t$Version\n");
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