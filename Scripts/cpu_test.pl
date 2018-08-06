use Win32::OLE qw (in);

$server = "10.1.224.20";
$Processors =
Win32::OLE->GetObject("winmgmts://".$server)->InstancesOf("Win32_Processor");

foreach $CPU (in $Processors)
	{
	print "CPU Name: " . $CPU->{Name}."\n";
	print "CPU Socket: " . $CPU->{SocketDesignation}."\n";
	$sockets{$CPU->{SocketDesignation}}=1;
	}

print "True processor count: ".scalar(keys %sockets)."\n";
