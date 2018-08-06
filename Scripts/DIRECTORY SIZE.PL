 use strict;
 use warnings;
 use Win32::DirSize;
 
 my $Result = dir_size(
   "D:\\Tools",
   my $DirInfo, # this stores the directory information
 );
 
 if ($Result == DS_RESULT_OK)
 	{
 	print "$Result\n";
 	print "$DirInfo\n";
   print "Files Found = $DirInfo->{FileCount} \n";
   print "Dirs Found = $DirInfo->{DirCount} \n";
   print "Dir size = $DirInfo->{DirSize} bytes \n";
   print "Dir size on disk = $DirInfo->{DirSizeOnDisk} bytes \n";
   }

 # display any errors
 if (@{$DirInfo->{Errors}}) {
  foreach my $Error (@{$DirInfo->{Errors}}) {
    printf(
         "Error #%d at %s\n",
         $Error->{ErrCode},
         $Error->{Location},
    );
  }
 }

 