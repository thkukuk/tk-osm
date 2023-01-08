#!/usr/bin/perl
#
# usage: createindex <cache directory> <output file>

use strict;
use warnings;
use locale;
use File::stat;

my @imgfiles;

my $cachedir = $ARGV[0];
my $outputfile = $ARGV[1];

if ($cachedir eq "" || $outputfile eq "") {
  die("usage: createindex <cache directory> <output file>\n")
}

open(OUTPUT,">$outputfile") || die("Can't open output file $outputfile: $!.");

dodir($cachedir);
close(OUTPUT);

#------------------------------------------------------------------------------

sub dodir {
  my ($dir) = @_;
  if (! -d $dir) {
    print STDERR "ERROR: $dir isn\'t a directory\n";
    return;
  }

  makedirs($dir);

  print OUTPUT <<"TableStart";
{{< list-table header=true class="pure-table pure-table-striped" >}}
Land
Style
Image
Erstellt
Größe
TableStart

  my $da;
  my $db;
  @imgfiles = sort { ($da = lc $a) =~ s/[\W_]+//g;
		     ($db = lc $b) =~ s/[\W_]+//g;
		      $da cmp $db;
                   } @imgfiles;
  foreach (@imgfiles) {
    my ($file, $size, $mtime, $has_sha256) = split(/""/, $_); # split the data
    $file =~ s|$dir||i unless $dir eq '.';
    write_images ($file, $size, $mtime, $has_sha256);
  }
  print OUTPUT "{{< /list-table >}}\n";
}

#------------------------------------------------------------------------------

sub makedirs {
  my ($dir) = @_;

  # Get the list of files in the current directory.
  opendir(DIR, $dir) || warn "Can't open $dir: $!\n";
  my (@filenames) = readdir(DIR);
  closedir(DIR);

  for (@filenames) {
    next if $_ eq '.';
    next if $_ eq '..';
    next if (! -f "$dir/$_"); # Is the filename really a file?
    next if (! /.img/i && ! /.7z/i); # list only images

    my $file = $_;
    my $st = stat("$dir/$file");
    my $mtime = $st->mtime;
    my $size = $st->size;
    my $has_sha256 = 0;
    $has_sha256 = 1 if (-e "$dir/$file.sha256");

    # my $random = int(rand(899)) + 100;
    my $data = join("\"\"","$file",$size,$mtime,$has_sha256);
    push @imgfiles, $data if (/.img$/i || /.7z$/i);
  }
}

#------------------------------------------------------------------------------

sub calc_size_str {
  my $size = $_[0];

  my $tsize=int(($size/1024/1024) + 0.5); # MB
  if ($tsize < 1) {
    $size=int(($size/1024) + 0.5);
    $size .= " KB";
  } else {
    $size = $tsize . " MB";
  }

  return $size;
}

my $last_country = "";

sub write_images {
  my ($file, $size, $mtime, $has_sha256) = @_;

  my ($sec,$min,$hour,$day,$month,$year) = localtime($mtime);
  my $filedate = sprintf "%4d-%0.2d-%0.2d",
    1900+$year, $month+1, $day, ;

  $size = calc_size_str($size);

  my @suffix = split (/\./,$file);
  my @info = split (/-/,$suffix[0]);
  if (!$info[2]) {
    return;
  }

  print OUTPUT "\n";
  if ($last_country && $info[1] eq $last_country) {
    print OUTPUT "\n";
  } else {
    if ($info[1] eq "DACH") {
      print OUTPUT "D/A/CH/FL\n";
    } else {
      my $str = $info[1];
      $str =~ s/_/ /g;
      print OUTPUT "$str\n";
    }
    $last_country = $info[1];
  }

  if ($info[2] eq "Basemap") {
    print OUTPUT "Basiskarte\n";
  } elsif ($info[2] eq "Streets") {
    print OUTPUT "Straßenkarte\n";
    } elsif ($info[2] eq "Oepnv") {
    print OUTPUT "&Ouml;PNV-Layer\n";
  } else {
    print OUTPUT "$info[2]-Layer\n";
  }
  if ($has_sha256) {
      print OUTPUT "[$file](maps/$file) ([SHA256](maps/$file.sha256))\n"
  } else {
    print OUTPUT "[$file](maps/$file)\n"
  }
  print OUTPUT "$filedate\n";
  print OUTPUT "$size\n";
}
