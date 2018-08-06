#  ============================================================================================================
#  TITLE:			DELL CPU.PL
#  VERSION:			4.4
#  CREATED:			12/01/2015
#  LAST UPDATE:	03/26/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows CPU information values for a list of DELL computers using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("DELL CPU REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("CPU"));
my $Column6 = uc(("CORES"));
my $Column7 = uc(("DESCRIPTION"));
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
my $HeaderLabel = "Installed Processors:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Physical Processors:";
my $ScreenLabel4 = "Cores:";
my $ScreenLabel5 = "Speed:";

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
my $VmwareCpu = "N/A";
my $VmwareCpuCoreCount = "0";
my $VmCpuDescription = "N/A";
my $VmwareCpuSpeed = "N/A";
my $CpuNumber;
my $Description;
my $CoreCount;
my $ClockSpeed;
my $Gigahertz;

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
		
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
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
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
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
							$CpuNumber = "$DetectionError";
							$CoreCount = "$DetectionError";
							$Description = "$DetectionError";
							$ClockSpeed = "$DetectionError";
							print  "  $WMIErrorMessage\n";
							print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
							}
					elsif ($ComputerModel =~ $VmModel)
							{
							$CpuNumber = "$VmwareCpu";
							$CoreCount = "$VmwareCpuCoreCount";
							$Description = "$VmCpuDescription";
							$ClockSpeed = "$VmwareCpuSpeed";
							print "  $VmwareCpu: $ComputerModel\n\n";
							print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
							}
						else
							{
						# [CAPTURE CPU INFORMATION]
						my @computers = ("$RealComputerName");

						foreach my $Computer (@computers)
							{
							Win32::OLE->LastError(0);
							Win32::OLE->Option(Warn => 0);

							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2\\Dell");
							
							if (Win32::OLE->LastError != "0")
								{
								$CpuNumber = "$DetectionError";
								$CoreCount = "$DetectionError";
								$Description = "$DetectionError";
								$ClockSpeed = "$DetectionError";								
								print  "  $WMIErrorMessage - Aborting Query\n\n";
								print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
								}
							else
								{							
								my $colItems = $objWMIService->ExecQuery("SELECT * FROM CIM_Processor", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);
								
								if (Win32::OLE->LastError != "0")
									{
									$CpuNumber = "$DetectionError";
									$CoreCount = "$DetectionError";
									$Description = "$DetectionError";
									$ClockSpeed = "$DetectionError";								
									print  "  $WMIErrorMessage - Aborting Query\n\n";
									print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
									}
								else
									{	
									foreach my $objItem (in $colItems)
										{
										$CpuNumber = "$objItem->{Name}";
										$Description = "$objItem->{Brand}";
										$CoreCount = "$objItem->{CoreCount}";
										$ClockSpeed = "$objItem->{CurrentClockSpeed}";

										if ((!defined $CpuNumber) or ($CpuNumber !~ "."))
											{
											$CpuNumber = "$DetectionError";
											}
										if ((!defined $Description) or ($Description !~ "."))
											{
											$Description = "$DetectionError";
											}
									elsif ($Description ne "") # Trim extra spaces out of description string
											{
											$Description =~ s/             / /;
											$Description =~ s/            / /;
											$Description =~ s/           / /;
											$Description =~ s/          / /;
											$Description =~ s/         / /;
											$Description =~ s/        / /;
											$Description =~ s/       / /;
											$Description =~ s/      / /;
											$Description =~ s/     / /;
											$Description =~ s/    / /;
											$Description =~ s/   / /;
											$Description =~ s/  / /;
											}
										if ((!defined $CoreCount) or ($CoreCount !~ "."))
											{
											$CoreCount = "$DetectionError";
											}
										if ((!defined $ClockSpeed) or ($ClockSpeed !~ "."))
											{
											$ClockSpeed = "$DetectionError";
											}
										else
											{
											$Gigahertz = ($ClockSpeed/1000); # Convert megahertz to gigahertz
											$ClockSpeed = substr($Gigahertz, 0, 4); # Limit number of digits reported
											}
										print "  $CpuNumber: $Description\n  $ScreenLabel4 $CoreCount\n  $ScreenLabel5 $ClockSpeed GHz\n\n";
										print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$CpuNumber\t$CoreCount\t$Description\t$ClockSpeed\n");
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