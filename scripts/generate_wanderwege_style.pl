#!/usr/bin/perl

# Script to create the style file for the "Wanderwege" Layer

use strict;
use warnings;

# All icons have a white background, most common used
my %icons = ('blue_x' => '0x3200',
	     'yellow_x' => '0x3201',
	     'green_x' => '0x3202',
	     'red_x' => '0x3203',
	     'black_x' => '0x3204',
	     'blue_lower' => '0x3205',
	     'yellow_lower' => '0x3206',
	     'green_lower' => '0x3207',
	     'red_lower' => '0x3208',
	     'blue_backslash' => '0x3209',
	     'yellow_backslash' => '0x320a',
	     'green_backslash' => '0x320b',
	     'red_backslash' => '0x320c',
	     'black_backslash' => '0x320d',
	     'blue_triangle' => '0x320e',
             'yellow_triangle' => '0x320f',
             'green_triangle' => '0x3210',
             'red_triangle' => '0x3211',
             'black_triangle' => '0x3212',
             'blue_rectangle' => '0x3213',
             'yellow_rectangle' => '0x3214',
             'green_rectangle' => '0x3215',
             'red_rectangle' => '0x3216',
             'black_rectangle' => '0x3217',
             'blue_pointer' => '0x3218',
             'yellow_pointer' => '0x3219',
             'green_pointer' => '0x321a',
             'red_pointer' => '0x321b',
	     'black_pointer' => '0x321c',
	     'blue_bar' => '0x3300',
	     'yellow_bar' => '0x3301',
	     'green_bar' => '0x3302',
	     'red_bar' => '0x3303',
	     'black_bar' => '0x3304',
	     'blue_cross' => '0x3305',
	     'yellow_cross' => '0x3306',
	     'green_cross' => '0x3307',
	     'red_cross' => '0x3308',
	     'black_cross' => '0x3309',
	     'blue_dot' => '0x330a',
	     'yellow_dot' => '0x330b',
	     'orange_dot' => '0x330b', # identisch zu yellow
	     'green_dot' => '0x330c',
	     'red_dot' => '0x330d',
	     'black_dot' => '0x330e',
	     'blue_diamond' => '0x3310',
	     'yellow_diamond' => '0x3311',
	     'green_diamond' => '0x3312',
	     'red_diamond' => '0x3313',
	     'black_diamond' => '0x3314',
	     'blue_circle' => '0x3315',
	     'yellow_circle' => '0x3316',
	     'green_circle' => '0x3317',
	     'red_circle' => '0x3318',
	     'black_circle' => '0x3319',
	     'blue_stripe' => '0x331a',
	     'yellow_stripe' => '0x331b',
	     'green_stripe' => '0x331c',
	     'red_stripe' => '0x331d',
	     'black_stripe' => '0x331e');
# icons with letters or a different background
my %letters = ('black::A1:white' => '0x3400',
	       'black:A1:white' => '0x3400',
	       'black::A2:white' => '0x3401',
	       'black:A2:white' => '0x3401',
	       'black::A3:white' => '0x3402',
	       'black:A3:white' => '0x3402',
	       'black::A4:white' => '0x3403',
	       'black:A4:white' => '0x3403',
	       'black::A5:white' => '0x3404',
	       'black:A5:white' => '0x3404',
	       'black::A6:white' => '0x3405',
	       'black:A6:white' => '0x3405',
	       'black::A7:white' => '0x3406',
	       'black:A7:white' => '0x3406',
	       'black::A8:white' => '0x3407',
	       'black:A8:white' => '0x3407',
	       'black::A9:white' => '0x3408',
	       'black:A9:white' => '0x3408',
	       'white::E8:red'   => '0x3409',
	       'white:E8:red'   => '0x3409',
	       'red::GS:white'   => '0x340a',
	       'black_circle:white_dot' => '0x340b',
	       'black_circle:blue_dot' => '0x340c',
	       'black_circle:red_dot' => '0x340d',
	       'black_circle:yellow_dot' => '0x340e',
	       'yellow:red_rectangle' => '0x340f',
	       'red:black_bar' => '0x3410',
 	       'black:hiker' => '0x3411',
	       'black:white_hiker' => '0x3411',
	       'black:yellow_hiker' => '0x3411',
	       'brown:hiker' => '0x3412',
	       'brown:white_hiker' => '0x3412',
 	       'blue:hiker' => '0x3413',
	       'blue:white_hiker' => '0x3413',
	       'brown:yellow_pointer' => '0x3414',
	       'brown:red_pointer' => '0x3415',
	       'yellow::BLP:red' => '0x3416',
	       'black:white_x' => '0x3417',
	       'black::X:white' => '0x3417',
	       'black::x:white' => '0x3417',
	       'red_circle:white_dot' => '0x3418',
	       'blue:green_lower' => '0x3419',
	       'red:white_bar' => '0x341a',
	       'green::1:white' => '0x3500',
               'green:1:white' => '0x3500',
               'green::2:white' => '0x3501',
               'green:2:white' => '0x3501',
               'green::3:white' => '0x3502',
               'green:3:white' => '0x3502',
               'green::4:white' => '0x3503',
               'green:4:white' => '0x3503',
               'green::5:white' => '0x3504',
               'green:5:white' => '0x3504',
               'green::6:white' => '0x3505',
               'green:6:white' => '0x3505',
               'green::7:white' => '0x3506',
               'green:7:white' => '0x3506',
               'green::8:white' => '0x3507',
               'green:8:white' => '0x3507',
               'green::9:white' => '0x3508',
               'green:9:white' => '0x3508',
               'green::10:white' => '0x3509',
               'green:10:white' => '0x3509',
               'green::11:white' => '0x350a',
               'green:11:white' => '0x350a',
               'green::12:white' => '0x350b',
               'green:12:white' => '0x350b',
	       'black:white_circle' => '0x321d',
	       'black:white_bar' => '0x321e',
	       'black:white_triangle_line' => '0x321f',
	       'shell_modern' => '0x330f',
	       'shell' => '0x331f');
my %lines = ('blue' => '00',
	     'yellow' => '01',
	     'green' => '02',
	     'red' => '03',
	     'black' => '04',
	     'white' => '10',
	     'orange' => '11',
	     'blue-yellow' => '05',
	     'blue-green' => '06',
	     'blue-red' => '07',
	     'blue-black' => '08',
	     'yellow-green' => '09',
	     'yellow-red' => '0a',
	     'yellow-black' => '0b',
	     'green-red' => '0c',
	     'green-black' => '0d',
	     'red-black' => '0e',
	     'blue-' => '00',
	     'yellow-' => '01',
	     'green-' => '02',
	     '-yellow-' => '03',
	     '-green-' => '04',
	     '-red-' => '05',
	     '-green' => '06',
	     '-red' => '07',
	     '-black' => '08');

my @sign_colors = ('blue', 'yellow', 'green', 'red', 'black', 'orange', 'white');
my @route_colors = ('blue', 'yellow', 'green', 'red', 'black', 'orange', 'white');
my @signs = ('bar', 'cross', 'dot', 'diamond', 'circle', 'stripe', 'x',
	    'lower', 'backslash', 'triangle', 'rectangle', 'pointer');
my @networks = ('iwn', 'nwn', 'rwn', 'lwn');

my $outputdir = $ARGV[0];

$outputdir = "./" unless defined $outputdir;

generate_options();
generate_relations();
generate_lines();
generate_points();

exit 0;

sub generate_options {
  open (FILE, ">$outputdir/options");

  print FILE "# Relation-File for the Wanderwege layer.\n\n";
  print FILE "# The levels specification for this style\n";
  print FILE "levels = 0:24, 1:22, 2:21, 3:20, 4:18, 5:17, 6:16\n";

  close FILE;
}

sub generate_relations {
  my $first;

  open (FILE, ">$outputdir/relations");

  print FILE "# Relation-File for the Wanderwege layer.\n\n";

  foreach my $route_color (@route_colors) {
    print FILE "(route=foot | route=hiking) & \n";
    if ($route_color eq 'white') {
      # Use white as default if no color is given
      print FILE "\t(osmc:symbol=$route_color | osmc:symbol ~ '$route_color:.*' | osmc:symbol ~ ':.*') &\n";
    } else {
      print FILE "\t(osmc:symbol=$route_color | osmc:symbol ~ '$route_color:.*') &\n";
    }
    print FILE "\t(name=* | osmc:name=*) &\n";
    print FILE "\t(";
    $first=1;
    for my $network (@networks) {
      if ($first) {
	$first=0;
      } else {
	print FILE " | ";
      }
      print FILE "network=$network";
    }
    print FILE ") {\n";
    print FILE "\tapply { set route_$route_color='\$(route_$route_color):\${osmc:symbol}'|\n";
    print FILE "\t                         '\${osmc:symbol}';\n";
    print FILE "\t        set route_${route_color}_type='\${network}';\n";
    print FILE "\t        set route_${route_color}_name=\n";
    print FILE "\t            '\$(route_${route_color}_name), \${osmc:name} (\${distance})' |\n";
    print FILE "\t            '\$(route_${route_color}_name), \${osmc:name}' |\n";
    print FILE "\t            '\${osmc:name} (\${distance})' | '\${osmc:name}' |\n";
    print FILE "\t            '\$(route_${route_color}_name), \${name} (\${distance})' |\n";
    print FILE "\t            '\$(route_${route_color}_name), \${name}' |\n";
    print FILE "\t            '\${name} (\${distance})' | '\${name}'\n";
    print FILE "\t      }\n";
    print FILE "}\n\n";
  }

  # Rules for hiking ways without osmc symbol
  # normal hiking ways
  $first=1;
  for my $network (@networks) {
    if ($first) {
      $first=0;
      print FILE "(";
    } else {
      print FILE " | ";
    }
    print FILE "network=$network";
  }
  print FILE ") & osmc:symbol!=* {\n";
  print FILE "\tapply { set route_rest=\n";
  print FILE "\t            '\$(route_rest), \${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\$(route_rest), \${name} (\${ref})' |\n";
  print FILE "\t            '\$(route_rest), \${name} (\${distance})' |\n";
  print FILE "\t            '\$(route_rest), \${name}' |\n";
  print FILE "\t            '\$(route_rest), \${ref} (\${distance})'|\n";
  print FILE "\t            '\$(route_rest), \${ref}' |\n";
  print FILE "\t            '\$(route_rest), \${distance}' |\n";
  print FILE "\t            '\${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\${name} (\${ref})' |\n";
  print FILE "\t            '\${name} (\${distance})' |\n";
  print FILE "\t            '\${name}' |\n";
  print FILE "\t            '\${ref} (\${distance})'|\n";
  print FILE "\t            '\${ref}' |\n";
  print FILE "\t            '\${distance}'\n";
  print FILE "\t      }\n";
  print FILE "}\n\n";

# fitness_trail/running
  print FILE "route=running | route=fitness_trail {\n";
  print FILE "\tapply { set route_running=\n";
  print FILE "\t            '\$(route_running), \${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\$(route_running), \${name} (\${ref})' |\n";
  print FILE "\t            '\$(route_running), \${name} (\${distance})' |\n";
  print FILE "\t            '\$(route_running), \${name}' |\n";
  print FILE "\t            '\$(route_running), \${ref} (\${distance})'|\n";
  print FILE "\t            '\$(route_running), \${ref}' |\n";
  print FILE "\t            '\$(route_running), \${distance}' |\n";
  print FILE "\t            '\${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\${name} (\${ref})' |\n";
  print FILE "\t            '\${name} (\${distance})' |\n";
  print FILE "\t            '\${name}' |\n";
  print FILE "\t            '\${ref} (\${distance})'|\n";
  print FILE "\t            '\${ref}' |\n";
  print FILE "\t            '\${distance}'\n";
  print FILE "\t      }\n";
  print FILE "}\n\n";

# greenway
  print FILE "network=greenway {\n";
  print FILE "\tapply { set route_greenway=\n";
  print FILE "\t            '\$(route_greenway), \${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\$(route_greenway), \${name} (\${ref})' |\n";
  print FILE "\t            '\$(route_greenway), \${name} (\${distance})' |\n";
  print FILE "\t            '\$(route_greenway), \${name}' |\n";
  print FILE "\t            '\$(route_greenway), \${ref} (\${distance})'|\n";
  print FILE "\t            '\$(route_greenway), \${ref}' |\n";
  print FILE "\t            '\$(route_greenway), \${distance}' |\n";
  print FILE "\t            '\${name} (\${ref}/\${distance})'|\n";
  print FILE "\t            '\${name} (\${ref})' |\n";
  print FILE "\t            '\${name} (\${distance})' |\n";
  print FILE "\t            '\${name}' |\n";
  print FILE "\t            '\${ref} (\${distance})'|\n";
  print FILE "\t            '\${ref}' |\n";
  print FILE "\t            '\${distance}'\n";
  print FILE "\t      }\n";
  print FILE "}\n\n";

  close FILE;
}

sub generate_lines {
  open (FILE, ">$outputdir/lines");

  print FILE "# Lines-File for the Wanderwege layer.\n\n";

  # Draw three color lines
  foreach my $color (@route_colors) {
    my $idx1 = $color.'-';
    my $number1 = $lines{$idx1};
    next unless defined $number1;

    foreach my $color2 (@route_colors) {
      next unless $color ne $color2;
      my $idx2 = '-'.$color2.'-';
      my $number2 = $lines{$idx2};
      next unless defined $number2;

      foreach my $color3 (@route_colors) {
	next unless $color2 ne $color3;
	my $idx3 = '-'.$color3;
	my $number3 = $lines{$idx3};
	next unless defined $number3;

	print FILE "route_${color}=* & saw_${color}_56!=* & route_${color2}=* & saw_${color2}_56!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}_56!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number1 level 5-6 continue]\n";
	print FILE "route_${color}=* & saw_${color}_56!=* & route_${color2}=* & saw_${color2}_56!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}_56!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number2 level 5-6 continue]\n";
	print FILE "route_${color}=* & saw_${color}_56!=* & route_${color2}=* & saw_${color2}_56!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}_56!=*\n";
	print FILE "\t{set saw_${color}_56=yes; set saw_${color2}_56=yes; set saw_${color3}_56=yes;\n";
	print FILE "\t name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number3 level 5-6 continue]\n";

	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number1 level 4-4 continue]\n";
	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number2 level 4-4 continue]\n";
	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x103$number3 level 4-4 continue]\n";

	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x10a$number1 level 3 continue]\n";
	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x10a$number2 level 3 continue]\n";
	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=* &\n";
	print FILE "\troute_${color3}=* & saw_${color3}!=*\n";
	print FILE "\t{set saw_${color}=yes; set saw_${color2}=yes; set saw_${color3}=yes;\n";
	print FILE "\t name '\${route_${color}_name}, \${route_${color2}_name}, \${route_${color3}_name}'}\n";
	print FILE "\t\t[0x10a$number3 level 3 continue with_actions]\n";
	print FILE "\n";
      }
    }
  }

  # Draw two color lines
  foreach my $color (@route_colors) {
    foreach my $color2 (@route_colors) {
      my $idx = $color.'-'.$color2;

      if ($lines{$idx}) {
	print FILE "route_${color}=* & saw_${color}_56!=* & route_${color2}=* & saw_${color2}_56!=*\n";
	print FILE "\t{set saw_${color}_56=yes; set saw_${color2}_56=yes;\n";
	print FILE "\t name '\${route_${color}_name}, \${route_${color2}_name}'}\n";
	print FILE "\t\t[0x10f$lines{$idx} level 5-6 continue]\n";

	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=*\n";
	print FILE "\t{name '\${route_${color}_name}, \${route_${color2}_name}'}\n";
	print FILE "\t\t[0x10f$lines{$idx} level 4-4 continue]\n";

	print FILE "route_${color}=* & saw_${color}!=* & route_${color2}=* & saw_${color2}!=*\n";
	print FILE "\t{set saw_${color}=yes; set saw_${color2}=yes;\n";
	print FILE "\t name '\${route_${color}_name}, \${route_${color2}_name}'}\n";
	print FILE "\t\t[0x101$lines{$idx} level 3 continue with_actions]\n";
	print FILE "\n";
      }
    }
  }

  print FILE "\n\n";

  # Draw single color line
  foreach my $color (@route_colors) {
    print FILE "route_${color}=* & saw_${color}_56!=* &\n";
    print FILE "\t(route_${color}_type=iwn | route_${color}_type=nwn)\n";
    print FILE "\t{set saw_${color}_56=yes; name '\${route_${color}_name}'}\n";
    print FILE "\t\t[0x10f$lines{$color} level 5-6 continue]\n";

    print FILE "route_${color}=* & saw_${color}!=*\n";
    print FILE "\t{name '\${route_${color}_name}'}\t[0x10f$lines{$color} level 4-4 continue]\n";

    print FILE "route_${color}=* & saw_${color}!=*\n";
    print FILE "\t{set saw_${color}=yes; name '\${route_${color}_name}'}\n";
    print FILE "\t\t[0x101$lines{$color} level 3 continue]\n";
  }


  # Draw hiking without osmc:symbol, greenway and running
  print FILE "route_rest=*     {name '\${route_rest}'}     [0x0f level 3 continue]\n";
  print FILE "route_greenway=* {name '\${route_greenway}'} [0x16 level 3 continue]\n";
  print FILE "route_running=*  {name '\${route_running}'}  [0x0e level 3 continue]\n";


  close FILE;
}

sub generate_points {
  open (FILE, ">$outputdir/points");

  print FILE "# POI-File for the Wanderwege layer.\n\n";

  foreach my $route_color (@route_colors) {

    print FILE "route_${route_color}=*\t{delete name}\n";
  }

  print FILE "\n";

  foreach my $route_color (@route_colors) {
    foreach my $sign_color (@sign_colors) {
      foreach my $sign (@signs) {
	my $idx=${sign_color}.'_'.${sign};
	my $iconid=$icons{$idx};

	next unless defined $iconid;

	print FILE "mkgmap:line2poi=true & mkgmap:line2poitype=mid & route_${route_color}=* &\n";
	print FILE "\t(route_${route_color} ~ '.*:white:${sign_color}_${sign}' |\n";
	print FILE "\t route_${route_color} ~ '.*:white:${sign_color}_${sign}:.*' |\n";
	print FILE "\t route_${route_color} ~ '.*::${sign_color}_${sign}' |\n";
	print FILE "\t route_${route_color} ~ '.*::${sign_color}_${sign}:.*')\n";
	#print FILE "\t route_${route_color} ~ '.*${color}:${sign_color}_${sign}' |\n";
	#print FILE "\t route_${route_color} ~ '.*${color}:${sign_color}_${sign}:.*')\n";
	print FILE "\t\t{name '\${route_${route_color}_name}'}\t[$iconid level 1 continue]\n\n";
      }
    }

    # while (my ($k,$v) = each %letters) {
    foreach my $k (sort keys %letters) {
      my $v = $letters{$k};
      print FILE "mkgmap:line2poi=true & mkgmap:line2poitype=mid & route_${route_color}=* &\n";
      print FILE "\t(route_${route_color} ~ '.*:${k}'|route_${route_color} ~ '.*:${k}:.*')\n";
      print FILE "\t\t{name '\${route_${route_color}_name}'}\t[$v level 1 continue]\n\n";
    }
  }

  # Infotafeln von Wanderwegen/Lehrpfade
  print FILE "tourism=information & mkgmap:line2poi!=true &\n\t(";
  my $first=1;
  foreach my $color (@route_colors) {
    if ($first) {
      print FILE "route_${color}=*";
      $first = 0;
    } else {
      print FILE " | route_${color}=*";
    }
  }
  print FILE ")\n";
  print FILE "\t{name '\${name} - \${description} (\${operator})'|\n";
  print FILE "\t      '\${name} - (\${description})' | '\${name}' | '\${description}' |\n";
  print FILE "\t      '\${operator}' | '\${ref}' | '\${information}' }\n";
  print FILE "\t\t\t\t\t\t[0x2905 level 0]\n";

  close FILE;
}
