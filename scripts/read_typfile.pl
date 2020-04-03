#!/usr/bin/perl
#

use strict;
use warnings;
use Fcntl;

my $file = $ARGV[0];
my $product_id;
my $family_id;

if (!$file || $file eq "") {
  die("Usage: read_typfile <file>\n");
}

sysopen(FILE, "$file", O_RDONLY) || die("Can't open TYP file $file: $!.");
binmode(FILE);
sysseek(FILE, 0x2f, 0);
sysread(FILE, $family_id, 2) == 2 || die("Can't read family id: $!.");
sysseek(FILE, 0x31, 0);
sysread(FILE, $product_id, 1) == 1 || die("Can't read product id: $!.");
#syswrite(FILE, 0x03, 1);

$product_id = unpack ("C", $product_id);
$family_id = unpack ("v", $family_id);

printf "Family-Id of $file: %i\n", $family_id;
printf "Product-ID of $file: %i\n", $product_id;

close (FILE);

exit 0;
