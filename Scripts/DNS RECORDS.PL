#  ============================================================================================================
#  TITLE:			DNS RECORDS.PL
#  Version:			6.6
#  CREATED:			04/01/2009
#  LAST UPDATE:	02/07/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Validate MS Windows DNS entries for a list of computers
#  ============================================================================================================
use strict;
# use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("DNS RECORDS REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("DNS SUFFIX"));
my $Column6 = uc(("FQDN"));
my $Column7 = uc(("IP ADDRESS"));
my $Column8 = uc(("RESOLVED FORWARD NAME"));
my $Column9 = uc(("RESOLVED FORWARD IP"));
my $Column10 = uc(("RESOLVED REVERSE NAME"));
my $Column11 = uc(("RESOLVED REVERSE IP"));
my $Column12 = uc(("FORWARD DNS STATUS"));
my $Column13 = uc(("REVERSE DNS STATUS"));
my $Column14 = uc(("DNS STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\t$Column11\t$Column12\t$Column13\t$Column14\n");

while (<IN>)
{
open(STDERR, "/dev/null");
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "DNS Record:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "Fully Qualified Name:";
my $ScreenLabel4 = "Pingable IP Address:";
my $ScreenLabel5 = "Forward DNS Lookup Result:";
my $ScreenLabel6 = "Reverse DNS Lookup Result:";

my $ScreenLabel7 = "Forward Lookup Test:";
my $ScreenLabel8 = "Reverse Lookup Test:";
my $ScreenLabel9 = "DNS Resolution Status:";

# [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";

# [NAME HANDLING VARIABLES]
my $NameMismatchDetection = "*** NAME MISMATCH DETECTED ***";
my $NameMismatchStatus;

# [STATUS HANDLING VARIABLES]
my $PassStatus = "PASS";
my $FailStatus = "FAIL";
my $GoodStatus = "OK";
my $BadStatus = "INCORRECT";
my $ForwardDnsStatus;
my $ReverseDnsStatus;
my $DnsRecordStatus;
my $DnsErrorMessage = "DNS RECORD NOT FOUND";

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%Values);

# [CUSTOM VARIABLES]
my $DnsSuffix;
my $FQDN;
my $ForwardLookup;
my $ForwardName;
my $ForwardIp;
my $PingIpAddress;
my $ReverseLookup;
my $ReverseName;
my $ReverseIp;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n\n";

# [TEST REGISTRY CONNECTION]
my $RegTestPath = "SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName";
my $RegTestKey = "ComputerName";

$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
$hNode->Open ("$RegTestPath", $hKey);

if (!defined $hKey)
	{
	$RealComputerName = "$DetectionError";
	$NameMismatchStatus = "$UnknownStatus";
	$DnsSuffix = "$DetectionError";
	$FQDN = "$DetectionError";
	$PingIpAddress = "$DetectionError";
	$ForwardName = "$DetectionError";
	$ForwardIp = "$DetectionError";
	$ReverseName = "$DetectionError";
	$ReverseIp = "$DetectionError";
	$ForwardDnsStatus = "$UnknownStatus";
	$ReverseDnsStatus = "$UnknownStatus";
	$DnsRecordStatus = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DnsSuffix\t$FQDN\t$PingIpAddress\t$ForwardName\t$ForwardIp\t$ReverseName\t$ReverseIp\t$ForwardDnsStatus\t$ReverseDnsStatus\t$DnsRecordStatus\n");
	}
else
	{
	# [CAPTURE THE REAL COMPUTER NAME]
	$hKey->GetValues(\%Values);
	$hKey->Close ();
	$hNode->Close ();
	$RealComputerName = uc($Values{$RegTestKey}[2]);
	chomp($RealComputerName);

	if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
		{
		$RealComputerName = "$DetectionError";
		$NameMismatchStatus = "$UnknownStatus";
		$DnsSuffix = "$DetectionError";
		$FQDN = "$DetectionError";
		$PingIpAddress = "$DetectionError";
		$ForwardName = "$DetectionError";
		$ForwardIp = "$DetectionError";
		$ReverseName = "$DetectionError";
		$ReverseIp = "$DetectionError";
		$ForwardDnsStatus = "$DetectionError";
		$ReverseDnsStatus = "$UnknownStatus";
		$DnsRecordStatus = "$UnknownStatus";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DnsSuffix\t$FQDN\t$PingIpAddress\t$ForwardName\t$ForwardIp\t$ReverseName\t$ReverseIp\t$ForwardDnsStatus\t$ReverseDnsStatus\t$DnsRecordStatus\n");
		}
	else
		{
		# [DETECT NAME MISMATCH IN SOURCE LIST]
		my @computers = ("$RealComputerName");

		foreach my $Computer (@computers)
			{
			if ($RealComputerName eq "$ComputerName")
				{
				$NameMismatchStatus = "No";
				}
			else
				{
				$NameMismatchStatus = "Yes";
				print "  $NameMismatchDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
				}
				# [CAPTURE ASSIGNED DNS SUFFIX]
				my $RegKeyPath1 = "SOFTWARE\\Policies\\Microsoft\\System\\DNSClient"; # check policy based suffix first
				my $RegKey1 = "PrimaryDnsSuffix";

				$HKEY_LOCAL_MACHINE->Connect ($RealComputerName, $hNode);
				$hNode->Open ("$RegKeyPath1", $hKey);
					{
					if (defined $hKey)
						{
						$hKey->GetValues(\%Values);
						$hKey->Close ();
						$DnsSuffix = uc($Values{$RegKey1}[2]);
						chomp($DnsSuffix);
						}
					if ((!defined $DnsSuffix) or ($DnsSuffix !~ "."))
						{
						my $RegKeyPath2 = "SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters"; # check machine based suffix if policy based suffix is not found
						my $RegKey2 = "Domain";

						$HKEY_LOCAL_MACHINE->Connect ($RealComputerName, $hNode);
						$hNode->Open ("$RegKeyPath2", $hKey);
						{
						if (!defined $hKey)
							{
							$NameMismatchStatus = "";
							$DnsSuffix = "$DetectionError";
							$FQDN = "$DetectionError";
							$PingIpAddress = "$DetectionError";
							$ForwardName = "$DetectionError";
							$ForwardIp = "$DetectionError";
							$ReverseName = "$DetectionError";
							$ReverseIp = "$DetectionError";
							$ForwardDnsStatus = "$DetectionError";
							$ReverseDnsStatus = "$UnknownStatus";
							$DnsRecordStatus = "$UnknownStatus";
							print  "  $RegErrorMessage - Unable to Capture the DNS Suffix\n\n";
							print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DnsSuffix\t$FQDN\t$PingIpAddress\t$ForwardName\t$ForwardIp\t$ReverseName\t$ReverseIp\t$ForwardDnsStatus\t$ReverseDnsStatus\t$DnsRecordStatus\n");
							}
						else
							{
							$hKey->GetValues(\%Values);
							$hKey->Close ();
							$DnsSuffix = uc($Values{$RegKey2}[2]);
							chomp($DnsSuffix);
							}
						} 
					}
				if ((!defined $DnsSuffix) or ($DnsSuffix eq ""))
					{
					$NameMismatchStatus = "";
					$DnsSuffix = "$DetectionError";
					$ForwardDnsStatus = "$DetectionError";
					$ReverseDnsStatus = "$UnknownStatus";
					print  "  $RegErrorMessage - Unable to Capture the DNS Suffix\n\n";
					}
				else
					{
					# [CHECK FORWARD DNS FOR VALID RECORD FOR FQDN]
					my $FQDN = "$RealComputerName.$DnsSuffix";
					
					# [TEST THE RESOLUTION OF THE FQDN]
					$ForwardLookup = `nslookup $FQDN.`;
					chomp($ForwardLookup);
					
					$ForwardName = $ForwardLookup;
					# [CAPTURE FWD NAME AND CLEANUP DNS RESPONSE]
					$ForwardName =~ s/Server.*\n//ig;
					$ForwardName =~ s/Address.*\n//ig;
					$ForwardName =~ s/\nName.* //ig;
					$ForwardName =~ s/\n\t.*//;
					$ForwardName = uc($ForwardName);
					chomp($ForwardName);
					
					if($ForwardName eq "")
						{
						$ForwardName = "FWD Name not found in DNS";
						}

					# [CAPTURE FWD IP AND CLEANUP DNS RESPONSE]
					$ForwardIp = $ForwardLookup;
					$ForwardIp =~ s/Server.*\nAddress.*\n//ig;
					$ForwardIp =~ s/Address.* //ig;
					$ForwardIp =~ s/\nName.*\n//ig;
					$ForwardIp =~ s/\n\t  /, /;
					chomp($ForwardIp);
					
					if($ForwardIp eq "")
						{
						$ForwardIp = "FWD IP not found in DNS";
						}

					# [CHECK REVERSE DNS FOR VALID RECORD FOR IP ADDRESS]
					my @ping = `ping -n 1 $RealComputerName`;

					foreach (@ping)
						{
						chomp;
						if(/Reply/)
							{
							s/Reply from //;
							s/:.*//;
							$PingIpAddress = $_;

							$ReverseLookup = `nslookup $PingIpAddress`;
							chomp($ReverseLookup);
							
							# [CAPTURE REVERSE NAME AND CLEANUP DNS RESPONSE]
							$ReverseName = $ReverseLookup;
							$ReverseName =~ s/Server.*\n//ig;
							$ReverseName =~ s/Address.*\n//ig;
							$ReverseName =~ s/\nName.* //ig;
							$ReverseName =~ s/\nDNS.* //ig;
							$ReverseName =~ s/\nTIMEOUT.* //ig;
							#chomp($ReverseName);
							$ReverseName = uc($ReverseName);
							chomp($ReverseName);

							if($ReverseName eq "")
								{
								$ReverseName = "Reverse Name not found in DNS";
								}

							# [CAPTURE REVERSE IP AND CLEANUP DNS RESPONSE]
							$ReverseIp = $ReverseLookup;
							$ReverseIp =~ s/Server.*\nAddress.*\n//ig;
							$ReverseIp =~ s/Address.* //ig;
							$ReverseIp =~ s/\nName.*\n//ig;
							$ReverseIp =~ s/\nDNS.* //ig;
							$ReverseIp =~ s/\nTIMEOUT.* //ig;
							chomp($ReverseIp);
							
							if($ReverseIp eq "")
								{
								$ReverseIp = "Reverse IP not found in DNS";
								}
							}
						}
					# [TEST DNS LOOKUP RESULTS]
					if (($ForwardName eq $FQDN) & ($ForwardIp =~ $PingIpAddress))
						{
						$ForwardDnsStatus = "$GoodStatus";
						}
					else
						{
						$ForwardDnsStatus = "$BadStatus";
						}
						
					if (($ReverseName eq $FQDN) & ($ReverseIp eq $PingIpAddress))
						{
						$ReverseDnsStatus = "$GoodStatus";
						}
					else
						{
						$ReverseDnsStatus = "$BadStatus";
						}
						
					if (($ForwardDnsStatus eq $GoodStatus) & ($ReverseDnsStatus eq $GoodStatus))
						{
						$DnsRecordStatus = "$PassStatus";
						}
				elsif (($ForwardDnsStatus eq $BadStatus) or ($ReverseDnsStatus eq $BadStatus))
						{
						$DnsRecordStatus = "$FailStatus";
						}
					else
						{
						$DnsRecordStatus = "$UnknownStatus";
						}
					print "\n  $ScreenLabel3\t\t$FQDN\n  $ScreenLabel4\t\t$PingIpAddress\n\n\n  $ScreenLabel5\t$ForwardName\n\t\t\t\t$ForwardIp\n  $ScreenLabel7\t\t$ForwardDnsStatus\n\n\n  $ScreenLabel6\t$ReverseName\n\t\t\t\t$ReverseIp\n  $ScreenLabel8\t\t$ReverseDnsStatus\n\n\n\n  $ScreenLabel9\t$DnsRecordStatus\n\n";
					print OUT ("$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$NameMismatchStatus\t$DnsSuffix\t$FQDN\t$PingIpAddress\t$ForwardName\t$ForwardIp\t$ReverseName\t$ReverseIp\t$ForwardDnsStatus\t$ReverseDnsStatus\t$DnsRecordStatus\n");
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);