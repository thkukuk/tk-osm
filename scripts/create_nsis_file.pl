#!/usr/bin/perl
#
# usage: create_nsis_file <Style> <Countr> <Country_Abbr>
#
# This file must be ISO-8859-2
# for example: iconv -f utf8 -t ISO_8859-2 create_nsis_file.pl

use strict;
use warnings;
use locale;
use File::stat;
use Fcntl ':mode';

my $style = $ARGV[0];
my $country = $ARGV[1];
my $country_abbr = $ARGV[2];
my $product_id;
my $family_id;
my $family_id_hex;
my @imgfiles;
my $typfile;
my $index;
my $addsize = 0;
my $name;
my $mapname;
my $srtmname;
my $dirname;
my $outputfile;
my $use_gmt = 1;

if ($style eq "" || $country eq "" || $country_abbr eq "") {
  die("usage: create_nsis_file <style> <country> <country_abbr>\n")
}

$use_gmt=0 if (defined $ARGV[3] && $ARGV[3] eq "--no-gmt");

my $regkey = "TK-OSM-".$country."-".$style;
$name = "TK-".$country."-".$style;
$mapname = $regkey;
$dirname = $name;
$srtmname = "TK-".$country."-SRTM";

if ($style eq "SRTM") {
  $regkey = "TK-OSM-".$country."-Basemap";
  $mapname = "TK-SRTM-".$country;
  $dirname = "TK-".$country."-Basemap";
}

$outputfile = $name . ".nsi";

open (FILE, "mkgmap.cfg");
while (<FILE>) {
  chomp;
  my ($key, $dat);

  ($key, $dat) = split ("=") if (/=/);
  ($key, $dat) = split (":") if (/:/);

  if (defined $key && defined $dat) {
    $dat =~ s/^\s+|\s+$//g ;
    $family_id = $dat if ($key eq "family-id");
    $family_id_hex = dec2hex ($dat) if ($key eq "family-id");
    $product_id = $dat if ($key eq "product-id");
  }
}
close (FILE);

if (!defined $family_id) {
  print "No family-id found!\n";
  exit 1;
}

if (!defined $product_id) {
  print "No product-id found!\n";
  exit 1;
}

dodir(".");

create_file ();
exit 0;

#------------------------------------------------------------------------------

sub dec2hex { my $str = unpack("H8", pack("v", $_[0]));
              lc $str; }

#------------------------------------------------------------------------------

sub dodir {
  my ($dir) = @_;
  if (! -d $dir) {
    print STDERR "ERROR: $dir isn\'t a directory\n";
    return;
  }

  # Get the list of files in the current directory.
  opendir(DIR, $dir) || warn "Can't open $dir: $!\n";
  my (@filenames) = readdir(DIR);
  closedir(DIR);

  for (@filenames) {
    next if $_ eq '.';
    next if $_ eq '..';
    next if (! -f "$dir/$_"); # Is the filename really a file?
    next if (/.osm.gz/i); # osm data
    next if (/.osm.pbf/i); # osm data

    if (/.TYP/i) {
      $typfile=$_;
    } elsif (/.typ/i) {
      $typfile=$_;
    } elsif (/_mdr.img/i || /.mdx/i) {
      $index=1;
    } elsif (/^7\d*.img/i) {
      my $file = $_;
      my $st = stat("$dir/$file");

      # Symlinks are SRTM data, ignore it
      if (!-l "$dir/$file") {
	$addsize += int($st->size/1000+1);
	push @imgfiles, $file;

      }
    }
  }

  # sort list of image files.
  my $da;
  my $db;
  @imgfiles = sort { ($da = lc $a) =~ s/[\W_]+//g;
		     ($db = lc $b) =~ s/[\W_]+//g;
		     $da cmp $db;
                   } @imgfiles;
}

#------------------------------------------------------------------------------

sub create_file {

  open(OUTPUT,">$outputfile") ||
    die("Can't open output file $outputfile: $!.");

  print OUTPUT "!define DEFAULT_DIR \"C:\\Garmin\\Maps\\$dirname\"\n";
  print OUTPUT "!define INSTALLER_DESCRIPTION \"$name\"\n";
  print OUTPUT "!define INSTALLER_NAME \"$name\"\n";
  print OUTPUT "!define NAME \"$name\"\n";
  print OUTPUT "!define MAPNAME \"$mapname\"\n";
  print OUTPUT "!define SRTMNAME \"$srtmname\"\n";
  print OUTPUT "!define PRODUCT_ID \"$product_id\"\n";
  print OUTPUT "!define FAMILY_ID \"$family_id\"\n";
  print OUTPUT "!define REG_KEY \"$regkey\"\n";
  print OUTPUT "Var /GLOBAL REGNAME\n";
  print OUTPUT <<"EOT";
!define APP_NAME execDos
!define DOS_APP consApp.exe

SetCompressor /SOLID lzma

; Includes
!include "MUI2.nsh"

; Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE \${NAME}_license.txt
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!define MUI_UNPAGE_INSTFILES

; Language files
!define MUI_LANGDLL_ALLLANGUAGES
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"

LangString AlreadyInstalled \${LANG_ENGLISH} "\${INSTALLER_NAME} is already installed. \$\\n\$\\nClick `OK` to remove the previous version or `Cancel` to cancel this upgrade."
LangString AlreadyInstalled \${LANG_GERMAN} "\${INSTALLER_NAME} ist bereits installiert. \$\\n\$\\n`OK` entfernt die vorherige Installation und  `Cancel` beended das Update."

LangString IMGNotFound \${LANG_ENGLISH} "\$EXEDIR\\\${NAME}.img not found!"
LangString IMGNotFound \${LANG_GERMAN} "\$EXEDIR\\\${NAME}.img nicht gefunden!"

Name "\${INSTALLER_DESCRIPTION}"
OutFile "\${INSTALLER_NAME}.exe"
InstallDir "\${DEFAULT_DIR}"

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY

  FindProcDLL::FindProc "MapSource.exe"
  IntCmp \$R0 1 0 notRunningMapSource
  MessageBox MB_OK|MB_ICONEXCLAMATION "Mapsource is running. Please close it first" /SD IDOK
  Abort
  notRunningMapSource:

  FindProcDLL::FindProc "BaseCamp.exe"
  IntCmp \$R0 1 0 notRunningBaseCamp
  MessageBox MB_OK|MB_ICONEXCLAMATION "BaseCamp is running. Please close it first" /SD IDOK
  Abort
  notRunningBaseCamp:

FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
FunctionEnd

Section "MainSection" SectionMain
  SetOutPath "\$INSTDIR"

  ; Uninstall before installing (code from http://nsis.sourceforge.net/Auto-uninstall_old_before_installing_new )
  ReadRegStr \$R0 HKLM \\
  "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${NAME}" "UninstallString"
  StrCmp \$R0 "" uninstdone

  IfSilent silent
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION "\$(AlreadyInstalled)" IDOK uninst
  Abort

  ;Run the uninstaller
  uninst:
  ClearErrors
  ExecWait '"\$R0" /S _?=\$INSTDIR' ;Do not copy the uninstaller to a temp file

  IfErrors no_remove_uninstaller uninstdone
    ;You can either use Delete /REBOOTOK in the uninstaller or add some code
    ;here to remove the uninstaller. Use a registry key to check
    ;whether the user has chosen to uninstall. If you are using an uninstaller
    ;components page, make sure all sections are uninstalled.
  no_remove_uninstaller:

  Goto uninstdone

  silent:
  ExecWait '"\$R0" /S _\?=\$INSTDIR' ;Do not copy the uninstaller to a temp file

  uninstdone:

; Files to be installed
  File "\${NAME}_license.txt"
  File "\${MAPNAME}.img"
  File "\${MAPNAME}.tdb"
EOT
  if ($use_gmt) {
    print OUTPUT "  File \"gmt.exe\"\n";
  }

  if ($index) {
    print OUTPUT <<"EOT";
  File "\${MAPNAME}_mdr.img"
  File "\${MAPNAME}.mdx"
EOT
  }

  if ($typfile) {
    print OUTPUT "  File \"$typfile\"\n";
  }

  if ($use_gmt) {
    print OUTPUT <<"EOT";
  ; Check that everything is there
  IfFileExists \$EXEDIR\\\${NAME}.img +3
  MessageBox MB_OK|MB_ICONSTOP "\$(IMGNotFound)"
  Abort

EOT
  }

  print OUTPUT "StrCpy \$REGNAME \${MAPNAME}\n";

  print OUTPUT "; Create MapSource registry keys\n";
  print OUTPUT "  WriteRegBin HKLM \"SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\" \"ID\" $family_id_hex\n";

  if ($index) {
    print OUTPUT <<"EOT";
  WriteRegStr HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "IDX" "\$INSTDIR\\\$REGNAME.mdx"
  WriteRegStr HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "MDR" "\$INSTDIR\\\$REGNAME_mdr.img"
EOT
  }
  if ($typfile) {
    print OUTPUT "  WriteRegStr HKLM \"SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\" \"TYP\" \"\$INSTDIR\\$typfile\"\n";
  }

  print OUTPUT <<"EOT";
  WriteRegStr HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "BMAP" "\$INSTDIR\\\$REGNAME.img"
  WriteRegStr HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "LOC" "\$INSTDIR"
  WriteRegStr HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "TDB" "\$INSTDIR\\\$REGNAME.tdb"

EOT

  print OUTPUT "  AddSize $addsize\n";
  if ($use_gmt) {
    print OUTPUT "; Extract *.img files\n";
    print OUTPUT "  DetailPrint \"Extract img files\"\n";
    print OUTPUT "  ClearErrors\n";
    print OUTPUT "  ExecDos::exec '\"\$INSTDIR\\gmt.exe\" -s -o \"\$INSTDIR\" \"\$EXEDIR\\$name.img\"'\n";
    print OUTPUT "  Pop \$0 # return value\n";
    print OUTPUT "  StrCmp \$0 0 +2 0\n";
    print OUTPUT "  Abort \"gmt.exe failed, exit code: \$0\"\n";
} else {
    print OUTPUT "; Copy *.img files to installation directory\n";
    foreach (@imgfiles) {
	print OUTPUT "  CopyFiles \"\$EXEDIR\\$_\" \"\$INSTDIR\" \n";
    }
}

  print OUTPUT <<"EOT";

; Write uninstaller
  WriteUninstaller "\$INSTDIR\\Uninstall-$name.exe"

; Create uninstaller registry keys
  WriteRegStr HKLM "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${NAME}" "DisplayName" "\$(^Name)"
  WriteRegStr HKLM "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${NAME}" "UninstallString" "\$INSTDIR\\Uninstall-$name.exe"
  WriteRegDWORD HKLM "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${NAME}" "NoModify" 1

; cleanup
  Delete "\$INSTDIR\\gmt.exe"
  Delete "\$INSTDIR\\BICYCLIN.typ"
  Delete "\$INSTDIR\\0BASEMAP.typ"
  Delete "\$INSTDIR\\00HIKING.typ"
  Delete "\$INSTDIR\\000FIXME.typ"
  Delete "\$INSTDIR\\00000OSB.typ"
  Delete "\$INSTDIR\\0TK_DACH.TYP"
  Delete "\$INSTDIR\\00TK_BNL.TYP"
  Delete "\$INSTDIR\\00TK_DNS.TYP"
  Delete "\$INSTDIR\\00TK_ESP.TYP"
  Delete "\$INSTDIR\\00TK_FRA.TYP"
  Delete "\$INSTDIR\\00TK_GBR.TYP"
  Delete "\$INSTDIR\\00TK_HRV.TYP"
  Delete "\$INSTDIR\\00TK_IND.TYP"
  Delete "\$INSTDIR\\00TK_IRL.TYP"
  Delete "\$INSTDIR\\00TK_ISL.TYP"
  Delete "\$INSTDIR\\00TK_ITA.TYP"
  Delete "\$INSTDIR\\00TK_NZL.TYP"
  Delete "\$INSTDIR\\00TK_SGP.TYP"
  Delete "\$INSTDIR\\00TK_USA.TYP"
  Delete "\$INSTDIR\\000TK_CA.TYP"
  Delete "\$INSTDIR\\000TK_CZ.TYP"
  Delete "\$INSTDIR\\000TK_DE.TYP"
  Delete "\$INSTDIR\\000TK_EU.TYP"
  Delete "\$INSTDIR\\000TK_IE.TYP"
  Delete "\$INSTDIR\\000TK_US.TYP"
  Delete "\$INSTDIR\\MAKEGMAP.mps"
  Delete "\$INSTDIR\\MAKEGMAP_mdr.img"
  Delete "\$INSTDIR\\MAKEGMAP_srt.img"
  Delete "\$INSTDIR\\MAPSOURC.MPS"
  Delete "\$INSTDIR\\\${FAMILY_ID}_mdr.img"
  Delete "\$INSTDIR\\\${FAMILY_ID}_srt.img"
SectionEnd

Section "Uninstall"
; Files to be uninstalled
  Delete "\$INSTDIR\\\${NAME}_license.txt"
  Delete "\$INSTDIR\\\${MAPNAME}.img"
  Delete "\$INSTDIR\\\${MAPNAME}.tdb"
  Delete "\$INSTDIR\\\${MAPNAME}_mdr.img"
  Delete "\$INSTDIR\\\${MAPNAME}.mdx"
  Delete "\$INSTDIR\\\${MAPNAME}+SRTM.img"
  Delete "\$INSTDIR\\\${MAPNAME}+SRTM.tdb"
  Delete "\$INSTDIR\\\${MAPNAME}+SRTM_mdr.img"
  Delete "\$INSTDIR\\\${MAPNAME}+SRTM.mdx"
EOT

  if ($typfile) {
    print OUTPUT "  Delete \"\$INSTDIR\\$typfile\"\n";
  }
  foreach (@imgfiles) {
    print OUTPUT "  Delete \"\$INSTDIR\\$_\"\n";
  }

  print OUTPUT <<"EOT";
  Delete "\$INSTDIR\\Uninstall-$name.exe"

  RmDir "\$INSTDIR"

; Registry cleanup
EOT

  if ($style ne "SRTM") {
    print OUTPUT <<"EOT";
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "ID"
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "TYP"
EOT
  }
  if ($index) {
    print OUTPUT <<"EOT";
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "IDX"
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}" "MDR"
EOT
  }
print OUTPUT <<"EOT";
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "BMAP"
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "LOC"
  DeleteRegValue HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}" "TDB"
  DeleteRegKey /IfEmpty HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}\\\${PRODUCT_ID}"
  DeleteRegKey /IfEmpty HKLM "SOFTWARE\\Garmin\\MapSource\\Families\\\${REG_KEY}"

  DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\\${NAME}"

SectionEnd
EOT

  close(OUTPUT);
}
