#  ============================================================================================================
#  TITLE:			DELL DIMMS.PL
#  VERSION:			1.2
#  CREATED:			05/13/2011
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows DIMM information values for a list of DELL computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("DELL_DIMMS_REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DIMM"));
my $Column6 = uc(("SIZE"));
my $Column7 = uc(("STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Installed Memory Modules (DIMMS):";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Module:";
my $ScreenLabel4 = "Size:";
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

# [CUSTOM VARIABLES]
my $ComputerModel;
my $VmModel = "V";
my $VmwareDimm = "N/A";
my $VmwareDimmSize = "0";
my $VmwareDimmStatus = "N/A";
my $DimmSizeGb;
my $DimmNumber;
my $DimmSize;
my $DimmStatus;


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
		$DimmNumber = "$DetectionError";
		$DimmSize = "$DetectionError";
		$DimmStatus = "$DetectionError";		
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
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
				$DimmNumber = "$DetectionError";
				$DimmSize = "$DetectionError";
				$DimmStatus = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
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
							my $DimmNumber = "$DetectionError";
							my $DimmSize = "$DetectionError";
							my $DimmStatus = "$DetectionError";
							print  "  $WMIErrorMessage\n";
							print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
							}
					elsif ($ComputerModel =~ $VmModel)
							{
							my $DimmNumber = "$VmwareDimm";
							my $DimmSize = "$VmwareDimmSize";
							my $DimmStatus = "$VmwareDimmStatus";
							print "  $VmwareDimm: $ComputerModel\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
							}
						else
							{
						# [CAPTURE DIMM INFORMATION]
						my @computers = ("$RealComputerName");

						foreach my $Computer (@computers)
							{
							Win32::OLE->LastError(0);
							Win32::OLE->Option(Warn => 0);

							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2\\Dell");
							
							if (Win32::OLE->LastError != "0")
								{
								$DimmNumber = "$DetectionError";
								$DimmSize = "$DetectionError";
								$DimmStatus = "$DetectionError";		
								print  "  $WMIErrorMessage - Aborting Query\n\n";
								print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
								}
							else
								{							
								my $colItems = $objWMIService->ExecQuery("SELECT * FROM CIM_PhysicalMemory", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

								if (Win32::OLE->LastError != "0")
									{
									$DimmNumber = "$DetectionError";
									$DimmSize = "$DetectionError";
									$DimmStatus = "$DetectionError";		
									print  "  $WMIErrorMessage - Aborting Query\n\n";
									print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
									}
								else
									{
									foreach my $objItem (in $colItems)
										{
										$DimmNumber = "$objItem->{Name}";
										$DimmSize = "$objItem->{Capacity}";
										$DimmStatus = "$objItem->{Status}";

										if ((!defined $DimmNumber) or ($DimmNumber !~ "."))
											{
											$DimmNumber = "$DetectionError";
											}
										if ((!defined $DimmSize) or ($DimmSize !~ "."))
											{
											$DimmSize = "$DetectionError";
											}
										else
											{
											$DimmSizeGb = ($DimmSize/1000000000); # Convert bytes to gigabytes
											$DimmSize = substr($DimmSizeGb, 0, 1); # Limit number of digits reported
											}
										if ((!defined $DimmStatus) or ($DimmStatus !~ "."))
											{
											$DimmNumber = "$DimmStatus";
											}									
										print "  $ScreenLabel3 $DimmNumber\n  $ScreenLabel4   $DimmSize GB\n  $ScreenLabel5 $DimmStatus\n\n";
										print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DimmNumber\t$DimmSize\t$DimmStatus\n");
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