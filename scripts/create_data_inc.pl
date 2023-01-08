#!/usr/bin/perl
#
# usage: createindex <cache directory> <output file>

use strict;
use warnings;
use locale;
use File::stat;

my @zipfiles;

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
Archive
Erstellt
Größe
TableStart

  my $da;
  my $db;
  @zipfiles = sort { ($da = lc $a) =~ s/[\W_]+//g;
		     ($db = lc $b) =~ s/[\W_]+//g;
		      $da cmp $db;
                   } @zipfiles;
  foreach (@zipfiles) {
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
    next if (! /.zip/i); # list only zip files
    next if (/-latest./i); # no latest links

    my $file = $_;
    my $st = stat("$dir/$file");
    my $mtime = $st->mtime;
    my $size = $st->size;

    my $data = join("\"\"","$file",$size,$mtime);
    push @zipfiles, $data if (/.zip$/i);
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
  my ($file, $size, $mtime) = @_;

  my ($sec,$min,$hour,$day,$month,$year) = localtime($mtime);
  my $filedate = sprintf "%4d-%0.2d-%0.2d",
    1900+$year, $month+1, $day, ;

  $size = calc_size_str($size);

  print OUTPUT "\n";
  print OUTPUT "[$file]($file)\n";
  print OUTPUT "$filedate\n";
  print OUTPUT "$size\n";
}
