#!/usr/bin/perl

# Script to konvert the keepright database to an OSM file

use utf8;
use strict;
use warnings;
use HTML::Entities;

my %utf2html = ( '\'' => '&apos;',
		 '\"' => '&quot;',
		 '<'  => '&lt;',
		 '>' => '&gt;');
my $regex = qr/${ \(join'|', map quotemeta, keys %utf2html)}/;


print "<?xml version='1.0' encoding='UTF-8'?>\n<osm version='0.6' generator='keepright2osm.pl'>\n";

my $id = 1;
my $line;
my $firstline=1;
while($line = <>) {
  chomp ($line);

  if ($firstline) {
    $firstline=0;
  } else {
    my @entry = split ("\t", $line);

    print STDERR "ERROR: $line\n" unless (defined $entry[9] && defined $entry[2] && defined $entry[11] && defined $entry[12] && defined $entry[15]);

    # Replace $1/$2/$3/$4 with the corresponding text
    $entry[16] = "" unless defined $entry[16];
    $entry[17] = "" unless defined $entry[17];
    $entry[18] = "" unless defined $entry[18];
    $entry[19] = "" unless defined $entry[19];
    $entry[15] =~ s/\$1/$entry[16]/g;
    $entry[15] =~ s/\$2/$entry[17]/g;
    $entry[15] =~ s/\$3/$entry[18]/g;
    $entry[15] =~ s/\$4/$entry[19]/g;
    # $entry[15] =~ s/($regex)/$utf2html{$1}/g;
    $entry[15] = HTML::Entities::encode($entry[15]);
    # osmosis doesn't like that, don't know what this breaks...
    # $entry[15] =~ s/&#x3//g;

    printf "<node id='$id' timestamp='%s' visible='true' version='1' lat='%2.7f' lon='%2.7f'>\n <tag k='error_type' v='%s' />\n <tag k='description' v='%s' />\n</node>", $entry[9], $entry[11]/10000000, $entry[12]/10000000, $entry[2], $entry[15];
    $id++;
  }
}

print "</osm>\n";
