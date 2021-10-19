#!/usr/bin/perl
#
# usage: createindex <cache directory> <output file>

use strict;
use warnings;
use locale;
use File::stat;

my @imgfiles;
my @pngfiles;

my $cachedir = $ARGV[0];
my $outputfile = $ARGV[1];

if ($cachedir eq "" || $outputfile eq "") {
  die("usage: createindex <cache directory> <output file>\n")
}

open(OUTPUT,">$outputfile") || die("Can't open output file $outputfile: $!.");

printheader();
dodir($cachedir);
printfooter();
close(OUTPUT);

#------------------------------------------------------------------------------

sub dodir {
  my ($dir) = @_;
  if (! -d $dir) {
    print STDERR "ERROR: $dir isn\'t a directory\n";
    return;
  }

  makedirs($dir);

  print OUTPUT "<h2 id=\"screenshots\">Screenshots</h2>\n";
  @pngfiles = sort @pngfiles;
  foreach (@pngfiles) {
    my $file = $_;
    $file =~ s|$dir||i unless $dir eq '.';
    print OUTPUT "<img src=\"pngs/$file\"/>\n" unless $file =~ "Legende";
  }

  print OUTPUT "<hr>\n";
  print OUTPUT "<center><h2 id=\"maps\">Karten</h2></center>\n";

  print OUTPUT <<"TableStart";
<center>
<table bgcolor=#f9f9f9 border="1">
  <tr bgcolor=#f2f2f2>
    <th align="center"> Land </th>
    <th align="center"> Karte </th>
    <th align="center"> Image </th>
    <th align="center"> Erstellt </th>
    <th align="center"> Gr&ouml;&szlig;e </th>
    <th align="center"> Beschreibung </th>
  </tr>
TableStart

  my $da;
  my $db;
  @imgfiles = sort { ($da = lc $a) =~ s/[\W_]+//g;
		     ($db = lc $b) =~ s/[\W_]+//g;
		      $da cmp $db;
                   } @imgfiles;
  foreach (@imgfiles) {
    my ($file, $size, $mtime, $has_md5) = split(/""/, $_); # split the data
    $file =~ s|$dir||i unless $dir eq '.';
    write_images ($file, $size, $mtime, $has_md5);
  }

  print OUTPUT <<"MITTE";
</table>
<table bgcolor=#f9f9f9 border="1">
  <tr bgcolor=#f2f2f2>
    <th align="center"> Style </th>
    <th align="center"> Archive </th>
    <th align="center"> Erstellt </th>
    <th align="center"> Gr&ouml;&szlig;e </th>
    <th align="center"> Beschreibung </th>
  </tr>
MITTE

  write_style ();

  print OUTPUT "</table>\n";
  print OUTPUT "</center>\n";
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
    next if (! /.img/i && ! /.tar.bz2/i && ! /.7z/i && ! /.zip/i ); # list only images, style and png files

    my $file = $_;
    my $st = stat("$dir/$file");
    my $mtime = $st->mtime;
    my $size = $st->size;
    my $has_md5 = 0;
    $has_md5 = 1 if (-e "$dir/$file.md5");

    # my $random = int(rand(899)) + 100;
    my $data = join("\"\"","$file",$size,$mtime,$has_md5);
    push @imgfiles, $data if (/.img$/i || /.7z$/i);
  }

  # Get the list of files in the current directory.
  opendir(DIR, $dir."/pngs") || warn "Can't open $dir/pngs: $!\n";
  (@filenames) = readdir(DIR);
  closedir(DIR);

  for (@filenames) {
    next if $_ eq '.';
    next if $_ eq '..';
    next if (! -f "$dir/pngs/$_"); # Is the filename really a file?
    next if (! /.png/i ); # list only png files
    push @pngfiles, $_;
    next;
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
  my ($file, $size, $mtime, $has_md5) = @_;

  my ($sec,$min,$hour,$day,$month,$year) = localtime($mtime);
  my $filedate = sprintf "%4d-%0.2d-%0.2d, $hour:%0.2d",
    1900+$year, $month+1, $day, $min,;

  $size = calc_size_str($size);

  my @suffix = split (/\./,$file);
  my @info = split (/-/,$suffix[0]);
  if (!$info[2]) {
    return;
  }

  print OUTPUT "<tr>\n";
  if ($last_country && $info[1] eq $last_country) {
    print OUTPUT "  <td>&nbsp;</td>\n";
  } else {
    if ($info[1] eq "DACH") {
      print OUTPUT " <td>D/A/CH/FL</td>\n";
    } else {
      my $str = $info[1];
      $str =~ s/_/ /g;
      print OUTPUT "  <td>$str</td>\n";
    }
    $last_country = $info[1];
  }

  if ($info[2] eq "Basemap") {
    print OUTPUT "  <td>Basiskarte</td>\n";
  } elsif ($info[2] eq "Streets") {
    print OUTPUT "  <td>Straßenkarte</td>\n";
    } elsif ($info[2] eq "Oepnv") {
    print OUTPUT "  <td>&Ouml;PNV-Layer</td>\n";
  } else {
    print OUTPUT "  <td>$info[2]-Layer</td>\n";
  }
  if ($has_md5) {
    print OUTPUT "  <td><A HREF=\"$file\" download>$file</A> (<A HREF=\"$file.md5\">MD5</A>)</td>\n";
  } else {
    print OUTPUT "  <td><A HREF=\"$file\" download>$file</A></td>\n";
  }
  print OUTPUT "  <td>$filedate</td>\n";
  print OUTPUT "  <td align=\"right\">$size</td>\n";
  if ($info[2] eq "Basemap" && $info[3] && $info[3] eq "noPOI") {
    print OUTPUT "  <td>Basis (Keine POIs, aber Stra&szlig;en, Fl&auml;chen, Routing, Adressuche)</td>\n";
  } elsif ($info[2] eq "Basemap") {
    print OUTPUT "  <td>Basis (Stra&szlig;en, Fl&auml;chen, Routing, Adressuche, POIs...)</td>\n";
  } elsif ($info[2] eq "Address") {
    print OUTPUT "  <td>Layer mit Hausnummern bzw. Namen der H&auml;user</td>\n";
  } elsif ($info[2] eq "Bicycling") {
    print OUTPUT "  <td>Layer mit Fahrradrouten</td>\n";
  } elsif ($info[2] eq "Hiking") {
    print OUTPUT "  <td>Layer mit Wanderwegen, Fitness Trails, Laufstrecken</td>\n";
  } elsif ($info[2] eq "Wanderwege") {
    print OUTPUT "  <td>Layer mit ausgeschilderten Wanderwegen (<a href=Wanderwege/>Info</a>)</td>\n";
  } elsif ($info[2] eq "SRTM" || $info[2] eq "Srtm") {
    print OUTPUT "  <td>Layer mit H&ouml;henlinien im 10m Abstand</td>\n";
  } elsif ($info[2] eq "Oepnv") {
    print OUTPUT "  <td>Linien des &ouml;ffentlichen Personenverkehrs</td>\n";
  } elsif ($info[2] eq "Fixme") {
    print OUTPUT "  <td>Layer mit allen Fixme-Kommentaren</td>\n";
  } elsif ($info[2] eq "OSB") {
    print OUTPUT "  <td>Layer mit allen offenen OSM-Bugs</td>\n";
  } elsif ($info[2] eq "KeepRight") {
    print OUTPUT "  <td>Layer mit Fehlern aus Syntax Checks von keepright.ipax.at </td>\n";
  } elsif ($info[2] eq "Marine") {
    print OUTPUT "  <td>Layer mit Seekarten Informationen</td>\n";
  } elsif ($info[2] eq "Streets") {
    print OUTPUT "  <td>Basiskarte, die nur Stra&szlig;en und St&auml;dte enth&auml;lt</td>\n";
  } else {
    print OUTPUT "  <td>&nbsp;</td>\n";
  }

  print OUTPUT "</tr>\n";
}

#------------------------------------------------------------------------------

sub write_style {
  print OUTPUT "<tr>\n";
  print OUTPUT "  <td>tk-osm</td>\n";

  print OUTPUT "  <td align=\"center\"><A HREF=\"https://github.com/thkukuk/tk-osm\">git</A></td>\n";
  print OUTPUT "  <td></td>\n";
  print OUTPUT "  <td align=\"right\"></td>\n";
  print OUTPUT " <td>Style und TYP Dateien sowie Skripte zum Generieren der Karten</td>\n";

  print OUTPUT "</tr>\n";
}

#------------------------------------------------------------------------------

sub printheader {
print OUTPUT <<"HeaderText";
<!doctype html public \"-\/\/IETF\/\/DTD HTML\/\/EN\">
<html>
<head>
<title>OSM Karten f&uuml;r Garmin Ger&auml;te von ThKukuk</title>
</head>
<body>
<h1><center>OpenStreetMap Karten f&uuml;r Garmin Ger&auml;te</center></h1>
<hr>
<ul>
<li><a href=\"#screenshots\">Screenshots</a></li>
<li><a href=\"#maps\">Karten</a></li>
<li><a href=\"legende.html\">Karten-Legende</a></li>
<li><a href=\"#installation\">Installation</a></li>
<li><a href=\"#adress\">Adresssuche</a></li>
<li><a href=\"MapSource-Wine.html\">MapSource unter Linux mit Wine</a></li>
<li><a href=\"srtm.html\">SRTM-H&ouml;henlinien erzeugen</a></li>
<li><a href=\"Wanderwege/\">Infos zum Wanderwege-Layer</a></li>
<li><a href=\"data/\">\"bounds\" und \"sea\" Daten f&uuml;r mkgmap</a>
<li><a href=\"#disclaimer\">Disclaimer und Copyright</a></li>
</ul>
<hr>
<font color=\"red\">Europa-Karte:</font> Da die aus der Basemap-Karte von Europa resultierende gmapsupp.img &uuml;ber 9GB gro&szlig; w&auml;re, wird keine mitgelierfert. Es m&uuml;ssen alle *.img Dateien mit dem Installer installiert werden und es k&ouml;nnen nur Teile dieser Karte mit MapSource oder BaseCamp auf einem GARMIN Ger&auml;t installiert werden. Es kann sich also jeder die L&auml;nder zusammen stellen, die er braucht. Routing und Address-Suche sind kein Problem.
<hr>
<font color=\"red\">MapSource:</font> f&uuml;r einwandfreies Routing wird von MapSource die Version <font color=\"red\">6.16.3</font> ben&ouml;tigt. &Auml;ltere Versionen haben Probleme an Kachelgrenzen.
<hr>
HeaderText
}

#------------------------------------------------------------------------------

sub printfooter {
print OUTPUT "<hr>\n";
print OUTPUT <<"EOT";
<h2 id="installation">Installation</h2>
<h3>Karte in MapSource oder Basecamp einbinden</h3>
<p>
Die 7z-Datei muss unter Windows in ein Verzeichnis ausgepackt werden.
F&uuml;r die <i>TK-DACH-Basemap.7z</i>-Datei sollten dort dann zwei
Dateien liegen: <i>TK-DACH-Basemap.img</i> sowie
<i>TK-DACH-Basemap.exe</i>. F&uuml;r andere L&auml;nder oder Karten
hei&szlig;en die Dateien dann entsprechend. Die <i>TK-DACH-Basemap.exe</i>
ausf&uuml;hren und anschlie&szlig;end sind die Karten in MapSource
verf&uuml;gbar. Deinstallation geht genauso wie f&uuml;r jede andere
Windows-Software auch.
</p>
<h3>IMG-Datei direkt auf das Ger&auml;t</h3>
<p>
Im Grunde mu&szlig; nichts weiter getan werden als das Archive zu entpacken
und die Datei <i>TK-&lt;Land&gt;-&lt;Karte&gt;.img</i> in das Verzeichnis
"Garmin" auf dem Ger&auml;t zu kopieren.
</p>
<p>
Wenn auf dem Ger&auml;t nicht mehrere Karten aufgespielt werden k&ouml;nnen, dann ist aus den Layern, die gew&uuml;nscht sind, eine gmapsupp.img Datei zu erstellen.
Verwendet wird daf&uuml;r <a href="https://www.gmaptool.eu/en/content/gmaptool">gmaptool</a>, ein propriet&auml;res Programm, vom dem Binaries f&uuml;r Windows, Linux und Mac existieren:
</p>
<pre>gmt -jo gmapsupp.img TK-DACH-Basemap.img TK-DACH-SRTM.img TK-DACH-Wanderwege.img TK-DACH-Bicycling.img TK-DACH-Oepnv.img</pre>
<p>
Auf Ger&auml;ten wie dem GARMIN GPSmap 60CSx kann nun im Menu jeder Layer einzeln ein-/ausgeschaltet werden. Auf Ger&auml;ten wie den Oregons oder dem GARMIN GPSmap 62s sollten die Layer einzeln kopiert werden, da es dort nicht m&ouml;glich ist, einzelne Layer der gmapsupp.img zu disablen.
</p>
<hr>
<h2 id=\"adress\">Adresssuche</h2>
<p>
Die Adresssuche der Karten funktionieren in MapSource sowie auf Garmin-Ger&auml;ten. Die Karte kann direkt auf das Ger&auml;t kopiert werden, es ist nicht notwendig die Karte mit MapSource zu transferieren.
</p>
<hr>
<h2 id=\"disclaimer\">Disclaimer und Copyright</h2>
<p>
Selbstverst&auml;ndlich &uuml;bernehme ich keinerlei Garantie, dass die Karten zu irgendetwas zu gebrauchen sind. Ebenfalls &uuml;bernehme ich keine Haftung f&uuml;r Fehlfunktionen an Ger&auml;ten oder sonstiges. Die Verwendung erfolgt auf eigenes Risiko. Die Benutzung erfolgt immer auf eigene Gefahr. Die durch das Autorouting erstellte Strecke stellt lediglich einen Streckenvorschlag dar und muss an die jeweilige Situation vor Ort angepasst werden.
</p>
<p>
Die Kartendaten mit Ausnahme der H&ouml;henlinien sind &copy; OpenStreetMap contributors unter der <a href="https://www.openstreetmap.org/copyright" target="_blank">ODbL</a> Lizenz.
</p>
<p>
Die H&ouml;henlinien basieren auf den SRTM-Daten der NASA sowie Jonathan de Ferranti und unterliegen deren Copyright.
Die Daten von Jonathan de Ferranti k&ouml;nnen auf <a href="http://www.viewfinderpanoramas.org/dem3.html" target="_blank">viewfinderpanoramas.org</a> gefunden werden.
</p>
<hr>
<p>
Mehr Informationen und Feedback auf meiner <a href="https://wiki.openstreetmap.org/wiki/User:Kukuk">OSM Wiki Seite</a>.
</p>
EOT
my $now = localtime;
print OUTPUT "<hr>\n";
print OUTPUT "<font size=\"-1\">Last generated: $now</font>\n";
print OUTPUT "</body>\n";
print OUTPUT "</html>\n";
}
