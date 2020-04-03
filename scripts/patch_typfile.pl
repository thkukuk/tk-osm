#!/usr/bin/perl
#

use strict;
use warnings;
use Fcntl;

my $file = $ARGV[0];
my $family_id;
my $product_id;

if (!$file || $file eq "") {
  die("Usage: patch_typfile <file>\n");
}

open (FILE, "mkgmap.cfg");
while (<FILE>) {
  chomp;
  my ($key, $dat);

  ($key, $dat) = split ("=") if (/=/);
  ($key, $dat) = split (":") if (/:/);

  next unless $key && $dat;

  $family_id = $dat if ($key eq "family-id");
  $product_id = $dat if ($key eq "product-id");
}
close (FILE);

$family_id =~ s/^\s+|\s+$//g ;
$product_id =~ s/^\s+|\s+$//g ;

if ($file =~ m/.TYP/) {

  $product_id = pack ("C", $product_id);
  $family_id = pack ("v", $family_id);

  sysopen(FILE, "$file", O_RDWR) || die("Can't open TYP file $file: $!.");
  binmode(FILE);
  sysseek(FILE, 0x2f, 0);
  syswrite(FILE, $family_id, 2) == 2 || die("Can't write family id: $!.");
  sysseek(FILE, 0x31, 0);
  syswrite(FILE, $product_id, 1) == 1 || die("Can't write product id: $!.");
  close (FILE);

} else {

  open(FILE, "<", $file) or die $!;
  open(OUTPUT, ">", $file.".tmp") or die $!;
  # Read the input file line by line
  while (<FILE>) {
    $_ =~ s/ProductCode=.*/ProductCode=$product_id/g;
    $_ =~ s/FID=.*/FID=$family_id /g;
    $_ =~ s/;;.*//g;
    print OUTPUT $_;
  }

  close FILE;
  close OUTPUT;

  rename $file.".tmp",$file;
}

exit 0;
