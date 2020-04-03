#!/usr/bin/perl
#

use strict;
use warnings;
use Fcntl;

my $file = $ARGV[0];
my $country = $ARGV[1];

if (!$file || $file eq "" || !$country || $country eq "") {
  die("Usage: extract_country_from_cities <citiesXXXX> <country_abbr>\n");
}

open (FILE, $file);
while (<FILE>) {
  chomp;
  my $line = $_;
  my(@d) = split (/\t/);
  next unless ($d[8] eq $country);

  print "$line\n";
}
close (FILE);

exit 0;
