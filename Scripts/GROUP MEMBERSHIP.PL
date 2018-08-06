#  ============================================================================================================
#  TITLE:			GROUP MEMBERSHIPS.PL
#  VERSION:			4.2
#  CREATED:			10/22/2008
#  LAST UPDATE:	02/12/2013
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Run PINGIT.PL first
#  PURPOSE:			Queries LOCAL GROUP MEMBERSHIPS and ACCOUNTS for a list of Windows computers  
#  ============================================================================================================
use strict;
# use warnings;
use Win32::NetAdmin;
use Win32API::Net;
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("GROUP MEMBERSHIP REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("TYPE"));
my $Column6 = uc(("ACCOUNT"));
my $Column7 = uc(("GROUP"));
my $Column8 = uc(("MEMBER"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Local Accounts and Group Memberships:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";

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
my (@GroupArray);
my $GroupName;
my (@GroupMemberArray);
my $GroupMemberName;
my (@LocalUserArray);
my $LocalUserName;

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
		print  "  $WMIConnectErrorMessage - Aborting Query\n\n";
		print OUT ("$WMIConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\n");
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
				print  "  $WMIErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
				print OUT ("$WMIErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\n");
				}
			else
				{
				#[DETECT VIRTUAL NAME IN SOURCE LIST]
				if ($RealComputerName eq "$ComputerName")
					{
					$VirtualNameStatus = "No";
					}
				else
					{
					$VirtualNameStatus = "Yes";
					print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
					}
					# [CAPTURE THE LOCAL ACCOUNTS AND GROUP MEMBERSHIPS]
					print "  LOCAL ACCOUNTS\n";
					print "  --------------\n";

					Win32::NetAdmin::GetUsers($RealComputerName, FILTER_NORMAL_ACCOUNT, \@LocalUserArray);
					foreach $LocalUserName (@LocalUserArray)
						{
						print "  $LocalUserName\n";
						print OUT "$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\tLocal User\t$LocalUserName\n";
						}
					print "\n\n  LOCAL GROUP MEMBERSHIP\n";
					print "  ----------------------\n";

					Win32API::Net::LocalGroupEnum($ComputerName, \@GroupArray);

					foreach $GroupName (@GroupArray)
						{
						Win32::NetAdmin::LocalGroupGetMembersWithDomain($RealComputerName, $GroupName, \@GroupMemberArray);
						print OUT "$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\tLocal Group\t\t$GroupName\n";

					foreach $GroupMemberName (@GroupMemberArray)
						{
						print "  [$GroupName]\t$GroupMemberName\n";
						print OUT "$WMISuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\tGroup Member\t\t$GroupName\t$GroupMemberName\n";
						}
					}
				}
			}
		}
	}
}
close(IN);
close(OUT);