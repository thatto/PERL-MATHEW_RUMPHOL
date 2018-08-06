#  ============================================================================================================
#  TITLE:			PINGIT.PL
#  VERSION			8.5
#  CREATED:			12/03/2008
#  LAST UPDATE:	06/12/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with a list of target computers
#  PURPOSE:			Determine if a system on the network is pingable
#  ============================================================================================================
use strict;
# use warnings;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("EQUIPMENT.TXT");
my $ReportName1 = ("PINGABLE.TXT");
my $ReportName2 = ("PING REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("PING RESULT"));
my $Column4 = uc(("IP ADDRESS"));
my $Column5 = uc(("RESOLVED NAME"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\INPUT\\$ReportName1";
my $output2 = "..\\REPORTS\\$ReportName2";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName1";
open OUT2, ">", $output2 or die "ERROR - CANNOT OPEN $ReportName2";

print OUT2 ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\n");

print "\n\n\n ------------------------------------------------------------------------------\n";
print "  STATUS\tRESULT\t\t\tIP ADDRESS\t\tSYSTEM TESTED\n";
print " ------------------------------------------------------------------------------\n\n";

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $ScreenLabel1 = "ICMP PING REPLIED";
my $ScreenLabel2 = "**** ICMP PING TIMED OUT ****";
my $ScreenLabel3 = "**** INVALID COMPUTER NAME ****";
my $ScreenLabel4 = "**** CANNOT LOCATE COMPUTER ****";

# [ERROR HANDLING VARIABLES]
my $SuccessMessage = "ONLINE";
my $OfflineMessage = "OFFLINE";
my $HostNotFoundMessage = "NOT FOUND";
my $ErrorMessage = "-FAIL-";
my $IpDetectionError = "IP Not Detected";

# [STATUS HANDLING VARIABLES]
my $ReplyStatus = "ICMP CONNECTION CONFIRMED";
my $OfflineStatus = "ICMP CONNECTION TIMED OUT";
my $InvalidNameStatus = "INVALID COMPUTER NAME";
my $UnknownStatus = "CANNOT LOCATE COMPUTER";

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));

# [CUSTOM VARIABLES]
my $PingStatus;
my $Result;
my $Reply;
my $PingReply;
my @ping = `ping -a -n 1 $ComputerName`;

chomp ($ComputerName);

foreach (@ping)
	{
	chomp;

	if (/Pinging/)
		{
		s/Pinging //;
		s/ \[.*//;
		s/ with.*//;
		$PingReply = uc(("$_"));
		}
elsif (/Unknown/)
		{
		$PingStatus = " $HostNotFoundMessage\t$ScreenLabel4\t\t$ComputerName\n\n";
		print OUT2 "$HostNotFoundMessage\t$ComputerName\t$UnknownStatus\n";
		}
elsif (/could not find/)
		{
		$PingStatus = " $HostNotFoundMessage\t$ScreenLabel4\t\t$ComputerName\n\n";
		print OUT2 "$HostNotFoundMessage\t$ComputerName\t$UnknownStatus\n";
		}
elsif (/General failure/)
		{
		$PingStatus = " $HostNotFoundMessage\t$ScreenLabel4\t\t$ComputerName\n\n";
		print OUT2 "$HostNotFoundMessage\t$ComputerName\t$UnknownStatus\n";
		}		
elsif (/parameter/)
		{
		$PingStatus = " $ErrorMessage\t$ScreenLabel3\t\t$ComputerName\n\n";
		print OUT2 "$ErrorMessage\t$ComputerName\t$InvalidNameStatus\t$PingReply\n";
		}
elsif (/timed out/)
		{
		$PingStatus = " $OfflineMessage\t$ScreenLabel2\t\t\t$ComputerName\n\n";
		print OUT2 "$OfflineMessage\t$ComputerName\t$OfflineStatus\t\t$PingReply\n";
		}
elsif (/unreachable/)
		{
		$PingStatus = " $OfflineMessage\t$ScreenLabel2\t\t\t$ComputerName\n\n";
		print OUT2 "$OfflineMessage\t$ComputerName\t$OfflineStatus\t\t$PingReply\n";
		}
elsif (/Reply/)
		{
		s/Reply from //;
		s/:.*//;
		$Reply = $_;
		if ($Reply !~ m/\./)
			{
			$Reply = "$IpDetectionError";
			}
		$PingStatus = " $SuccessMessage\t\t$ScreenLabel1  ->  $Reply\t\t$ComputerName\n\n";
		print OUT "$ComputerName\n";
		print OUT2 "$SuccessMessage\t$ComputerName\t$ReplyStatus\t$Reply\t$PingReply\n";
		}
	else
		{
		next;
		}
	}
print $PingStatus;
}
close(IN);
close(OUT);
close(OUT2);