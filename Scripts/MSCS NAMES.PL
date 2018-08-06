#  ============================================================================================================
#  TITLE:			MSCS NAMES.PL
#  Version:			3.1
#  CREATED:			10/23/2013
#  LAST UPDATE:	12/01/2015
#  AUTHOR:			MATHEW RUMPHOL
#  PREREQUISITES:	Populate EQUIPMENT.TXT with list of computers and run PINGIT.PL first
#  PURPOSE:			Capture MS Windows MSCS registry values for a list of computers
#  ============================================================================================================
use strict;
#use warnings;
use Win32::Registry;

# [INPUT AND OUTPUT VARIABLES]
my $SourceList = ("PINGABLE.TXT");
my $ReportName = ("MSCS NAMES REPORT.TXT");

my $Column1 = uc(("CONNECTION STATUS"));
my $Column2 = uc(("COMPUTER"));
my $Column3 = uc(("ACTUAL NAME"));
my $Column4 = uc(("NAME MISMATCH"));
my $Column5 = uc(("MSCS NAME"));
my $Column6 = uc(("NODE1"));
my $Column7 = uc(("NODE2"));
my $Column8 = uc(("NODE3"));
my $Column9 = uc(("NODE4"));
my $Column10 = uc(("ACTIVE NODE"));
my $Column11 = uc(("MSCS STATUS"));

my $input = "..\\INPUT\\$SourceList";
my $output = "..\\REPORTS\\$ReportName";

open IN, "<", $input or die "ERROR - CANNOT OPEN $SourceList";
open OUT, ">", $output or die "ERROR - CANNOT OPEN $ReportName";

print OUT ("$Column1\t$Column2\t$Column3\t$Column4\t$Column5\t$Column6\t$Column7\t$Column8\t$Column9\t$Column10\t$Column11\n");

while (<IN>)
{
chomp;

# [OUTPUT FORMATTING VARIABLES]
my $HeaderLabel = "Microsoft Clustering Information:";
my $ScreenLabel1 = "Tested Name:";
my $ScreenLabel2 = "Actual Name:";
my $ScreenLabel3 = "MSCS Status:";
my $ScreenLabel4 = "MSCS Name:";
my $ScreenLabel5 = "Node No. 1:";
my $ScreenLabel6 = "Node No. 2:";
my $ScreenLabel7 = "Node No. 3:";
my $ScreenLabel8 = "Node No. 4:";
my $ScreenLabel9 = "Active Node:";


# [ERROR HANDLING VARIABLES]
my $RegSuccessMessage = "Registry Connection Succeeded";
my $RegConnectErrorMessage = "Registry Connection Failed";
my $RegErrorMessage = "Registry Query Failed";
my $UnknownStatus = "Unknown";
my $DetectionError = "Not Detected";
my $DetectionSuccess = "MSCS Detected";

# [NAME HANDLING VARIABLES]
my $VirtualNameDetection = "*** NAME MISMATCH DETECTED ***";
my $VirtualNameStatus;

# [STATUS HANDLING VARIABLES]
my $PassStatus = "Pass";
my $FailStatus = "Fail";
my $ClusterStatus;

# [STANDARD VARIABLES]
my $ComputerName = uc(("$_"));
my $RealComputerName;
my ($hNode,$hKey,%values);

# [CUSTOM VARIABLES]
my $ClusterName;
my $Node1;
my $Node2;
my $Node3;
my $Node4;
my $ActiveNode;

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
	$VirtualNameStatus = "$UnknownStatus";
	$ClusterName = "$DetectionError";
	$Node1 = "$DetectionError";
	$Node2 = "$DetectionError";
	$Node3 = "$DetectionError";
	$Node4 = "$DetectionError";
	$ActiveNode = "$DetectionError";
	$ClusterStatus = "$UnknownStatus";
	print  "  $RegConnectErrorMessage  - Aborting Query\n\n";
	print OUT ("$RegConnectErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ClusterName\t$Node1\t$Node2\t\t$Node3\t$Node4\t$ActiveNode\t$ClusterStatus\n");
	}
else
	{
	# [CAPTURE THE REAL COMPUTER NAME]
	$hKey->GetValues(\%values);
	$hKey->Close ();
	$hNode->Close ();
	$RealComputerName = uc($values{$RegTestKey}[2]);
	chomp($RealComputerName);

	if ((!defined $RealComputerName) or ($RealComputerName !~ "."))
		{
		$RealComputerName = "$DetectionError";
		$VirtualNameStatus = "$UnknownStatus";
		$ClusterName = "$DetectionError";
		$Node1 = "$DetectionError";
		$Node2 = "$DetectionError";
		$Node3 = "$DetectionError";
		$Node4 = "$DetectionError";
		$ActiveNode = "$DetectionError";
		$ClusterStatus = "$UnknownStatus";
		print  "  $RegErrorMessage to Capture The Real Computer Name - Aborting Query\n\n";
		print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ClusterName\t$Node1\t$Node2\t\t$Node3\t$Node4\t$ActiveNode\t$ClusterStatus\n");
		}
	else
		{
		# [DETECT VIRTUAL NAME IN SOURCE LIST]
		if ($RealComputerName eq "$ComputerName")
			{
			$VirtualNameStatus = "No";
			}
		 else
			{
			$VirtualNameStatus = "Yes";
			print "  $VirtualNameDetection\n\n  $ScreenLabel1\t$ComputerName\n  $ScreenLabel2\t$RealComputerName\n\n";
			}
			# [CAPTURE MSCS SETTINGS]
			my $MSCSNameRegKeyPath = "Cluster";
			my $MSCSNameRegKey = "ClusterName";
			my $Node1RegKey = "Cluster\\Nodes\\1";
			my $Node2RegKey= "Cluster\\Nodes\\2";
			my $Node3RegKey= "Cluster\\Nodes\\3";
			my $Node4RegKey= "Cluster\\Nodes\\4";
			my $NodeNameRegKey = "NodeName";

		$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
		$hNode->Open ("$MSCSNameRegKeyPath", $hKey);
			{
			if (!defined $hKey)
				{
				$ClusterName = "$DetectionError";
				$Node1 = "$DetectionError";
				$Node2 = "$DetectionError";
				$Node3 = "$DetectionError";
				$Node4 = "$DetectionError";
				$ActiveNode = "$DetectionError";
				$ClusterStatus = "MSCS $DetectionError";
				print  "  $ScreenLabel3\t$ClusterStatus\n\n";
				print OUT ("$RegErrorMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ClusterName\t$Node1\t$Node2\t$Node3\t$Node4\t$ActiveNode\t$ClusterStatus\n");
				}
			else
				{
				$ClusterStatus = "$DetectionSuccess";
				$hKey->GetValues(\%values);
				$hKey->Close ();
				$hNode->Close ();
				$ClusterName = uc($values{$MSCSNameRegKey}[2]);
				chomp($ClusterName);

				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$Node1RegKey", $hKey);
					{
					if (!defined $hKey)
						{
						$Node1 = "$DetectionError";
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();
						$Node1 = uc($values{$NodeNameRegKey}[2]);
						chomp($Node1);
						}
					}
				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$Node2RegKey", $hKey);
					{
					if (!defined $hKey)
						{
						$Node2 = "$DetectionError";
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();
						$Node2 = uc($values{$NodeNameRegKey}[2]);
						chomp($Node2);
						}
					}
				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$Node3RegKey", $hKey);
					{
					if (!defined $hKey)
						{
						$Node3 = "$DetectionError";
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();
						$Node3 = uc($values{$NodeNameRegKey}[2]);
						chomp($Node3);
						}
					}
				$HKEY_LOCAL_MACHINE->Connect ($ComputerName, $hNode);
				$hNode->Open ("$Node4RegKey", $hKey);
					{
					if (!defined $hKey)
						{
						$Node4 = "$DetectionError";
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();
						$Node4 = uc($values{$NodeNameRegKey}[2]);
						chomp($Node4);
						}
					}					
				$HKEY_LOCAL_MACHINE->Connect ($ClusterName, $hNode);
				$hNode->Open ("$RegTestPath", $hKey);
					{
					if (!defined $hKey)
						{
						$ActiveNode = "$DetectionError";
						}
					else
						{
						$hKey->GetValues(\%values);
						$hKey->Close ();
						$hNode->Close ();
						$ActiveNode = uc($values{$RegTestKey}[2]);
						chomp($ActiveNode);
						}
					}
				print( "  $ScreenLabel3\t$ClusterStatus\n\n  $ScreenLabel4\t$ClusterName\n\n  $ScreenLabel5\t$Node1\n\n  $ScreenLabel6\t$Node2\n\n  $ScreenLabel7\t$Node3\n\n  $ScreenLabel8\t$Node4\n\n  $ScreenLabel9\t$ActiveNode\n\n" );
				print OUT "$RegSuccessMessage\t$ComputerName\t$RealComputerName\t$VirtualNameStatus\t$ClusterName\t$Node1\t$Node2\t$Node3\t$Node4\t$ActiveNode\t$ClusterStatus\n";
				}
			}
		}
	}
}
close(IN);
close(OUT);