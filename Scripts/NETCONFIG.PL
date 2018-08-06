#  ============================================================================================================
#  TITLE:			NETCONFIG.PL
#  VERSION:			3.5
#  AUTHOR:			MATHEW RUMPHOL
#  CREATED:			01/13/2009
#  LAST UPDATE:	02/07/2013
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Query and capture BROADCOM, INTEL, HP or VMWARE NETWORK ADAPTER settings using WMI
#  ============================================================================================================
use strict;
# use warnings;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("NETCONFIG REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("HOST NAME"));
my $Column6 = uc(("NIC DNS SUFFIX"));
my $Column7 = uc(("DESCRIPTION"));
my $Column8 = uc(("MAC ADDRESS"));
my $Column9 = uc(("DHCP ON"));
my $Column10 = uc(("IP ADDRESS"));
my $Column11 = uc(("SUBNET MASK"));
my $Column12 = uc(("GATEWAY"));
my $Column13 = uc(("LMHOSTS LOOKUP"));
my $Column14 = uc(("PRIMARY WINS"));
my $Column15 = uc(("SECONDARY WINS"));
my $Column16 = uc(("ENABLE NETBIOS"));
my $Column17 = uc(("SUFFIX SEARCH"));
my $Column18 = uc(("DNS PRIMARY SERVER"));
my $Column19 = uc(("DNS SECONDARY SERVER"));
my $Column20 = uc(("REGISTER DNS"));
my $Column21 = uc(("REGISTER NIC DNS SUFFIX"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\t$Column11\t$Column12\t$Column13\t$Column14\t$Column15\t$Column16\t$Column17\t$Column18\t$Column19\t$Column20\t$Column21\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Network Configuration:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenDnsServers;
my $ScreenSuffixSearch;

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
my $HostName;
my $Description;
my $MacAddress;
my $DhcpEnabled;
my $IpAddress;
my $SubnetMask;
my $Gateway;
my $LmHostEnabled;
my $PrimaryWINS;
my $SecondaryWINS;
my $DnsSuffix;
my $DnsServers;
my $SuffixSearch;
my $EnableNetBios;
my $DnsRegistration;
my $NicDnsSuffixRegistration;

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  $HeaderLabel $ComputerName\n";
print " ------------------------------------------------------------------------------\n\n";

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
      $HostName = "$DetectionError";
      $Description = "$DetectionError";
      $MacAddress = "$DetectionError";
      $DhcpEnabled = "$DetectionError";
      $IpAddress = "$DetectionError";
      $SubnetMask = "$DetectionError";
      $Gateway = "$DetectionError";
      $LmHostEnabled = "$DetectionError";
      $PrimaryWINS = "$DetectionError";
      $SecondaryWINS = "$DetectionError";
      $DnsSuffix = "$DetectionError";
      $SuffixSearch = "$DetectionError";
      $DnsServers = "$DetectionError";
      $EnableNetBios = "$DetectionError";
		$DnsRegistration = "$DetectionError";
		$NicDnsSuffixRegistration = "$DetectionError";
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
      print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HostName\t$DnsSuffix\t$Description\t$MacAddress\t$DhcpEnabled\t$IpAddress\t$SubnetMask\t$Gateway\t$LmHostEnabled\t$PrimaryWINS\t$SecondaryWINS\t$EnableNetBios\t$SuffixSearch\t$DnsServers\t$DnsRegistration\t$NicDnsSuffixRegistration\n");
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
				$HostName = "$DetectionError";
				$Description = "$DetectionError";
				$MacAddress = "$DetectionError";
				$DhcpEnabled = "$DetectionError";
				$IpAddress = "$DetectionError";
				$SubnetMask = "$DetectionError";
				$Gateway = "$DetectionError";
				$LmHostEnabled = "$DetectionError";
				$PrimaryWINS = "$DetectionError";
				$SecondaryWINS = "$DetectionError";
				$DnsSuffix = "$DetectionError";
				$SuffixSearch = "$DetectionError";
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HostName\t$DnsSuffix\t$Description\t$MacAddress\t$DhcpEnabled\t$IpAddress\t$SubnetMask\t$Gateway\t$LmHostEnabled\t$PrimaryWINS\t$SecondaryWINS\t$EnableNetBios\t$SuffixSearch\t$DnsServers\t$DnsRegistration\t$NicDnsSuffixRegistration\n");
				}
			else
				{
				# [DETECT NAME MISMATCH IN SOURCE LIST]
				if ($RealComputerName eq "$ComputerName")
					{
					$VirtualNameStatus = "No";
					}
				else
					{
					$VirtualNameStatus = "Yes";
					print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
					}
				# [CAPTURE NETWORK INTERFACE INFORMATION]
				my @computers = ("$RealComputerName");

				foreach my $Computer (@computers)
					{
					my $colItems = $objWMIService->ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE Description LIKE '%Intel%' or Description LIKE '%Broadcom%' or Description LIKE '%HP%' or Description LIKE '%VMware%'", "WQL",wbemFlagReturnImmediately | wbemFlagForwardOnly);

					foreach my $objItem (in $colItems)
						{
						$HostName = "$objItem->{DNSHostName}";
						$Description = "$objItem->{Description}";
						$MacAddress = "$objItem->{MACAddress}";
						$DhcpEnabled = "$objItem->{DHCPEnabled}";
						$IpAddress = "" . join(", ", (in $objItem->{IPAddress})) . "";
						$SubnetMask = "" . join(", ", (in $objItem->{IPSubnet})) . "";
						$Gateway = "" . join(",", (in $objItem->{DefaultIPGateway})) . "";
						$LmHostEnabled = "$objItem->{WINSEnableLMHostsLookup}";
						$PrimaryWINS = "$objItem->{WINSPrimaryServer}";
						$SecondaryWINS = "$objItem->{WINSSecondaryServer}";
						$DnsSuffix =  uc("$objItem->{DNSDomain}");
						$DnsServers = "" . join("\t", (in $objItem->{DNSServerSearchOrder})) . "";
						$SuffixSearch = uc("" . join(", ", (in $objItem->{DNSDomainSuffixSearchOrder})) . "");
						$ScreenDnsServers = "DNS Primary Server:\t" . join(" \n DNS Secondary Server:\t", (in $objItem->{DNSServerSearchOrder})) . "";
						$ScreenSuffixSearch = uc("" . join("\n ", (in $objItem->{DNSDomainSuffixSearchOrder})) . "");
						$EnableNetBios = "$objItem->{TcpipNetbiosOptions}";
						$DnsRegistration = "$objItem->{FullDNSRegistrationEnabled}";
						$NicDnsSuffixRegistration = "$objItem->{DomainDNSRegistrationEnabled}";

					if ((!defined $HostName) or ($HostName !~ "."))
						{
						$HostName = "";
						}
					if ((!defined $Description) or ($Description !~ "."))
						{
						$Description = "";
						}                     
					if ((!defined $MacAddress) or ($MacAddress !~ "."))
						{
						$MacAddress = "";
						}                     
					if ((!defined $DhcpEnabled) or ($DhcpEnabled !~ "."))
						{
						$DhcpEnabled = "";
						}                     
				elsif ($DhcpEnabled eq "0")
						{
						$DhcpEnabled = "No";
						}
				elsif ($DhcpEnabled eq "1")
						{
						$DhcpEnabled = "Yes";
						}
					if ((!defined $LmHostEnabled) or ($LmHostEnabled !~ "."))
						{
						$LmHostEnabled = "";
						}                      
				elsif ($LmHostEnabled eq "0")
						{
						$LmHostEnabled = "No";
						}
				elsif ($LmHostEnabled eq "1")
						{
						$LmHostEnabled = "Yes";
						}
					if ((!defined $PrimaryWINS) or ($PrimaryWINS !~ "."))
						{
						$PrimaryWINS = "";
						}
					if ((!defined $SecondaryWINS) or ($SecondaryWINS !~ "."))
						{
						$SecondaryWINS = "";
						}
					if ((!defined $DnsServers) or ($DnsServers !~ "."))
						{
						$DnsServers = "";
						}						
					if ((!defined $DnsSuffix) or ($DnsSuffix !~ "."))
						{
						$DnsSuffix = "";
						}
					if ((!defined $SuffixSearch) or ($SuffixSearch !~ "."))
						{
						$SuffixSearch = "";
						}
					if ((!defined $ScreenDnsServers) or ($ScreenDnsServers !~ "."))
						{
						$ScreenDnsServers = "";
						}
					if ((!defined $ScreenSuffixSearch) or ($ScreenSuffixSearch !~ "."))
						{
						$ScreenSuffixSearch = "";
						}
					if ((!defined $EnableNetBios) or ($EnableNetBios !~ "."))
						{
						$EnableNetBios = "";
						}                      
				elsif ($EnableNetBios eq "0")
						{
						$EnableNetBios = "Default";
						}
				elsif ($EnableNetBios eq "1")
						{
						$EnableNetBios = "Enabled";
						}
				elsif ($EnableNetBios eq "2")
						{
						$EnableNetBios = "Disabled";
						}						
					if ((!defined $DnsRegistration) or ($DnsRegistration !~ "."))
						{
						$DnsRegistration = "";
						}                      
				elsif ($DnsRegistration eq "0")
						{
						$DnsRegistration = "No";
						}
				elsif ($DnsRegistration eq "1")
						{
						$DnsRegistration = "Yes";
						}
					if ((!defined $NicDnsSuffixRegistration) or ($NicDnsSuffixRegistration !~ "."))
						{
						$NicDnsSuffixRegistration = "";
						}                      
				elsif ($NicDnsSuffixRegistration eq "0")
						{
						$NicDnsSuffixRegistration = "No";
						}
				elsif ($NicDnsSuffixRegistration eq "1")
						{
						$NicDnsSuffixRegistration = "Yes";
						}						
						print " Description:           $Description\n";
						print " Local Host Name:       $HostName\n\n";
						print " MAC Address:           $MacAddress\n\n";
						print " DHCP Enabled?:         $DhcpEnabled\n";
						print " IP Address:            $IpAddress\n";
						print " Subnet Mask:           $SubnetMask\n";
						print " Default Gateway:       $Gateway\n\n";
						print " Register IP Address in DNS: $DnsRegistration\n\n\n";
						print " LMHosts Lookup?:       $LmHostEnabled\n";
						print " WINS Primary Server:   $PrimaryWINS\n";
						print " WINS Secondary Server: $SecondaryWINS\n\n";
						print " NetBIOS Enabled:       $EnableNetBios\n\n\n";
						print " NIC DNS Suffix:        $DnsSuffix\n";
						print " Register NIC Suffix in DNS: $NicDnsSuffixRegistration\n\n";
						print " $ScreenDnsServers\n\n";
						print " DNS Suffix Search Order:\n $ScreenSuffixSearch\n\n";
						print " ------------------------------------------------------------------------------\n\n";
						print OUT ("$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$HostName\t$DnsSuffix\t$Description\t$MacAddress\t$DhcpEnabled\t$IpAddress\t$SubnetMask\t$Gateway\t$LmHostEnabled\t$PrimaryWINS\t$SecondaryWINS\t$EnableNetBios\t$SuffixSearch\t$DnsServers\t$DnsRegistration\t$NicDnsSuffixRegistration\n");
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);