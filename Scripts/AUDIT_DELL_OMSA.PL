#  ============================================================================================================
#  TITLE:			AUDIT_DELL_OMSA.PL
#  VERSION:			5.0
#  CREATED:			12/03/2008
#  LAST UPDATE:	08/10/2011
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture DELL OPEN MANAGE SERVER ADMINISTRATOR VERSION information for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;
use Win32::Service;
use Win32::Registry;


# [INPUT AND OUTPUT VARIABLES]
my $SourceList = uc(("PINGABLE.TXT"));
my $ReportName = uc(("AUDIT_DELL_OMSA_REPORT.TXT"));

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("OMSA NAME"));
my $Column6 = uc(("OMSA VERSION"));
my $Column7 = uc(("OMSA VERSION STATUS"));
my $Column8 = uc(("OMSA COMMENT"));
my $Column9 = uc(("DSM SA CONNECTION SERVICE"));
my $Column10 = uc(("DSM SA DATA MANAGER"));
my $Column11 = uc(("DSM SA EVENT MANAGER"));
my $Column12 = uc(("DSM SA SHARED SERVICES"));
my $Column13 = uc(("SERVICE STATUS"));
my $Column14 = uc(("SERVICE COMMENT"));
my $Column15 = uc(("OMSA STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "FAIL - CANNOT OPEN FILE: $input";
open OUT, ">", $output or die "FAIL - CANNOT OPEN FILE: $output";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\t$Column11\t$Column12\t$Column13\t$Column14\t$Column15\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Dell OMSA Version:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Software Name:";
my $ScreenLabel4 = "Version Detected:";
my $ScreenLabel5 = "Version Status:";
my $ScreenLabel6 = "VMware Detected:";
my $ScreenLabel7 = "Service Status:";
my $ScreenLabel8 = "Dell OMSA Status:";

# [ERROR HANDLING VARIABLES]
my $WMISuccessMessage = "WMI Connected";
my $WMIConnectErrorMessage = "WMI Connection Failed";
my $WMIErrorMessage = "WMI Query Failed";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";


# [NAME HANDLING VARIABLES]
my $NameMismatchDetection = "*** NAME MISMATCH DETECTED ***";
my $NameMismatchStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;


# [AUDIT CRITERIA VARIABLES]
my $PassStatus = "Pass";
my $FailStatus = "Fail";
my $CurrentOmsaVersion = "6.4";

# [CUSTOM VARIABLES]
my $OmsaSoftwareName;
my $OmsaSoftwareVersion;
my $OmsaSoftwareStatus;
my $VmwareOmsaStatus = "N/A";
my $VmwareOmsaStatusMsg = "(Dell OMSA not applicable to virtual systems)";
my $OmsaStatusMsg;
my $VmwareOmsaName = "N/A";
my $VmwareOmsaVersion = "N/A";
my $ServerModel;
my $VmModel = "V";
my $hNode;
my $hKey;
my $Values;
my %Values;
my $Status;
my %Status;
my $Service1State;
my $Service2State;
my $Service3State;
my $Service4State;
my $Service1StateStatus;
my $Service2StateStatus;
my $Service3StateStatus;
my $Service4StateStatus;
my $OmsaStatus;
my $Service1 = "Server Administrator";
my $Service1Name = "DSM SA CONNECTION SERVICE";
my $Service2 = "dcstor32";
my $Service2Name = "DSM SA DATA MANAGER";
my $Service3 = "dcevt32";
my $Service3Name = "DSM SA EVENT MANAGER";
my $Service4 = "omsad";
my $Service4Name = "DSM SA SHARED SERVICES";
my $FunctionalStatus;
my $FunctionalStatusMsg;

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
		$OmsaSoftwareName = "$DetectionError";
		$OmsaSoftwareVersion = "$DetectionError";
		$OmsaSoftwareStatus = "$UnknownStatus";
		$Service1State = "$DetectionError";
		$Service2State = "$DetectionError";
		$Service3State = "$DetectionError";
		$Service4State = "$DetectionError";
		$FunctionalStatus = "$UnknownStatus";
		$FunctionalStatusMsg = "";
		$OmsaStatus = "$UnknownStatus";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
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
				$OmsaSoftwareName = "$DetectionError";
				$OmsaSoftwareVersion = "$DetectionError";
				$OmsaSoftwareStatus = "$UnknownStatus";
				$Service1State = "$DetectionError";
				$Service2State = "$DetectionError";
				$Service3State = "$DetectionError";
				$Service4State = "$DetectionError";
				$FunctionalStatus = "$UnknownStatus";
				$FunctionalStatusMsg = "";
				$OmsaStatus = "$UnknownStatus";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\n");
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
				# [DETECT VIRTUAL PLATFORM]
				my @computers = ("$RealComputerName");

				my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_ComputerSystem", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

				foreach my $objItem (in $colItems)
					{
					$ServerModel = uc(("$objItem->{Model}"));

					if ((!defined $ServerModel) or ($ServerModel !~ "."))
						{
						$ServerModel = "Not Detected";
						$OmsaSoftwareName = "$DetectionError";
						$OmsaSoftwareVersion = "$DetectionError";
						$OmsaSoftwareStatus = "$UnknownStatus";
						$Service1State = "$DetectionError";
						$Service2State = "$DetectionError";
						$Service3State = "$DetectionError";
						$Service4State = "$DetectionError";
						$FunctionalStatus = "$UnknownStatus";
						$FunctionalStatusMsg = "";
						$OmsaStatus = "$UnknownStatus";
						print  "  $ScreenLabel3\t$WMIErrorMessage\n  $ScreenLabel4\n  $ScreenLabel5\n";
						print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DetectionError\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
						}
				elsif ($ServerModel =~ $VmModel)	# Filter out VMware - OMSA not required on VMware clients
						{
						$OmsaSoftwareName = "$VmwareOmsaName";
						$OmsaSoftwareVersion = "$VmwareOmsaVersion";
						$OmsaSoftwareStatus = "$VmwareOmsaStatus";
						$Service1State = "N/A";
						$Service2State = "N/A";
						$Service3State = "N/A";
						$Service4State = "N/A";
						$FunctionalStatus = "N/A";
						$FunctionalStatusMsg = "";
						$OmsaStatus = "N/A";
						print "  $ScreenLabel5\t$VmwareOmsaStatusMsg\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$VmwareOmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
						}
					if ($ServerModel !~ $VmModel)
						{
						# [CAPTURE THE OPENMANAGE SERVER ADMINISTRATOR VERSION]
						foreach my $Computer (@computers)
							{
							Win32::OLE->LastError(0);
							Win32::OLE->Option(Warn => 0);

							my $objWMIService = Win32::OLE->GetObject("winmgmts:\\\\$Computer\\root\\CIMV2\\Dell");

							if (Win32::OLE->LastError != "0")
								{
								$OmsaSoftwareName = "$DetectionError";
								$OmsaSoftwareVersion = "$DetectionError";
								$OmsaSoftwareStatus = "$UnknownStatus";
								$Service1State = "$DetectionError";
								$Service2State = "$DetectionError";
								$Service3State = "$DetectionError";
								$Service4State = "$DetectionError";
								$FunctionalStatus = "$UnknownStatus";
								$FunctionalStatusMsg = "";
								$OmsaStatus = "$UnknownStatus";
								print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
								print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
								}
							else
								{
								my $colItems = $objWMIService->ExecQuery("SELECT * FROM Dell_SoftwareFeature", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);
								
								if (Win32::OLE->LastError != "0")
									{
									$OmsaSoftwareName = "$DetectionError";
									$OmsaSoftwareVersion = "$DetectionError";
									$OmsaSoftwareStatus = "$UnknownStatus";
									$Service1State = "$DetectionError";
									$Service2State = "$DetectionError";
									$Service3State = "$DetectionError";
									$Service4State = "$DetectionError";
									$FunctionalStatus = "$UnknownStatus";
									$FunctionalStatusMsg = "";
									$OmsaStatus = "$UnknownStatus";
									print  "  $WMIConnectErrorMessage - Aborting Query\n\n";;
									print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
									}
								else
									{
									foreach my $objItem (in $colItems)
										{
										$OmsaSoftwareName = uc(("$objItem->{Name}"));
										$OmsaSoftwareVersion = uc(("$objItem->{Version}"));

										if ((!defined $OmsaSoftwareName) or ($OmsaSoftwareName !~ "."))
											{
											$OmsaSoftwareName = "$DetectionError";
											$OmsaSoftwareStatus = "$UnknownStatus";
											$OmsaStatusMsg = "";
											}
										if ((!defined $OmsaSoftwareVersion) or ($OmsaSoftwareVersion !~ "."))
											{
											$OmsaSoftwareVersion = "$DetectionError";
											$OmsaSoftwareStatus = "$UnknownStatus";
											$OmsaStatusMsg = "";
											}
									elsif (($OmsaSoftwareVersion >= "$CurrentOmsaVersion") and ($OmsaSoftwareName ne "$DetectionError"))
											{
											$OmsaSoftwareStatus = "$PassStatus";
											$OmsaStatusMsg = "";
											}
									elsif (($OmsaSoftwareVersion < "$CurrentOmsaVersion") and ($OmsaSoftwareName ne "$DetectionError"))
											{
											$OmsaSoftwareStatus = "$FailStatus";
											$OmsaStatusMsg = "(Min Ver. $CurrentOmsaVersion Required)";
											}
										# [CAPTURE CURRENT RUNNING STATUS OF SERVICES]
										Win32::Service::GetStatus( "$RealComputerName","$Service1", \%Status);
										if (!defined($Status{CurrentState}))
											{
											$Service1State = "$DetectionError";
											$Service1StateStatus = "$UnknownStatus";
											$FunctionalStatusMsg = "$UnknownStatus";
											}
									elsif ($Status{CurrentState} == '1')
											{
											$Service1State = "Stopped";
											$Service1StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '2')
											{
											$Service1State = "Starting";
											$Service1StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '3')
											{
											$Service1State = "Stopping";
											$Service1StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '4')
											{
											$Service1State = "Running";
											$Service1StateStatus = "$PassStatus";
											}
									elsif ($Status{CurrentState} == '5')
											{
											$Service1State = "Resume Pending";
											$Service1StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '6')
											{
											$Service1State = "Pause Pending";
											$Service1StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '7')
											{
											$Service1State = "Paused";
											$Service1StateStatus = "$FailStatus";
											}
											
										Win32::Service::GetStatus( "$RealComputerName","$Service2", \%Status);
										if (!defined($Status{CurrentState}))
											{
											$Service2State = "$DetectionError";
											$Service2StateStatus = "$UnknownStatus";
											$FunctionalStatusMsg = "$UnknownStatus";
											}
									elsif ($Status{CurrentState} == '1')
											{
											$Service2State = "Stopped";
											$Service2StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '2')
											{
											$Service2State = "Starting";
											$Service2StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '3')
											{
											$Service2State = "Stopping";
											$Service2StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '4')
											{
											$Service2State = "Running";
											$Service2StateStatus = "$PassStatus";
											}
									elsif ($Status{CurrentState} == '5')
											{
											$Service2State = "Resume Pending";
											$Service2StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '6')
											{
											$Service2State = "Pause Pending";
											$Service2StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '7')
											{
											$Service2State = "Paused";
											$Service2StateStatus = "$FailStatus";
											}
											
										Win32::Service::GetStatus( "$RealComputerName","$Service3", \%Status);
										if (!defined($Status{CurrentState}))
											{
											$Service3State = "$DetectionError";
											$Service3StateStatus = "$UnknownStatus";
											$FunctionalStatusMsg = "$UnknownStatus";
											}
									elsif ($Status{CurrentState} == '1')
											{
											$Service3State = "Stopped";
											$Service3StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '2')
											{
											$Service3State = "Starting";
											$Service3StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '3')
											{
											$Service3State = "Stopping";
											$Service3StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '4')
											{
											$Service3State = "Running";
											$Service3StateStatus = "$PassStatus";
											}
									elsif ($Status{CurrentState} == '5')
											{
											$Service3State = "Resume Pending";
											$Service3StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '6')
											{
											$Service3State = "Pause Pending";
											$Service3StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '7')
											{
											$Service3State = "Paused";
											$Service3StateStatus = "$FailStatus";
											}
											
										Win32::Service::GetStatus( "$RealComputerName","$Service3", \%Status);
										if (!defined($Status{CurrentState}))
											{
											$Service4State = "$DetectionError";
											$Service4StateStatus = "$UnknownStatus";
											$FunctionalStatusMsg = "$UnknownStatus";
											}
									elsif ($Status{CurrentState} == '1')
											{
											$Service4State = "Stopped";
											$Service4StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '2')
											{
											$Service4State = "Starting";
											$Service4StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '3')
											{
											$Service4State = "Stopping";
											$Service4StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '4')
											{
											$Service4State = "Running";
											$Service4StateStatus = "$PassStatus";
											}
									elsif ($Status{CurrentState} == '5')
											{
											$Service4State = "Resume Pending";
											$Service4StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '6')
											{
											$Service4State = "Pause Pending";
											$Service4StateStatus = "$FailStatus";
											}
									elsif ($Status{CurrentState} == '7')
											{
											$Service4State = "Paused";
											$Service4StateStatus = "$FailStatus";
											}
									if (($Service1StateStatus eq "$FailStatus") or ($Service2StateStatus eq "$FailStatus") or ($Service3StateStatus eq "$FailStatus") or ($Service4StateStatus eq "$FailStatus"))
											{
											$FunctionalStatus = "$FailStatus";
											$FunctionalStatusMsg = "(One Or More Dell OMSA Services Are Not Running)";
											}
									elsif (($Service1StateStatus eq "$PassStatus") & ($Service2StateStatus eq "$PassStatus") & ($Service3StateStatus eq "$PassStatus") & ($Service4StateStatus eq "$PassStatus"))
											{
											$FunctionalStatus = "$PassStatus";
											$FunctionalStatusMsg = "";
											}										

									if (($OmsaSoftwareStatus eq "$FailStatus") or ($FunctionalStatus eq "$FailStatus"))
											{
											$OmsaStatus = "$FailStatus";
											}
									elsif (($OmsaSoftwareStatus eq "$PassStatus") & ($FunctionalStatus eq "$PassStatus"))
											{
											$OmsaStatus = "$PassStatus";
											}
										print "  $ScreenLabel3\t$OmsaSoftwareName\n  $ScreenLabel4\t$OmsaSoftwareVersion\n  $ScreenLabel5\t$OmsaSoftwareStatus\t$OmsaStatusMsg\n\n  $ScreenLabel7\t$FunctionalStatus\t$FunctionalStatusMsg\n\n  $ScreenLabel8\t$OmsaStatus\n\n";
										print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$OmsaSoftwareName\t$OmsaSoftwareVersion\t$OmsaSoftwareStatus\t$OmsaStatusMsg\t$Service1State\t$Service2State\t$Service3State\t$Service4State\t$FunctionalStatus\t$FunctionalStatusMsg\t$OmsaStatus\n");
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