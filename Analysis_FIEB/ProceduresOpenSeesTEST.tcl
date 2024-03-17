# --------------------------------------------------------------------------------------------------
# procedresOpenSeesTEST.tcl -- test procedures for OpenSees
# --------------------------------------------------------------------------------------------------
# Length: [mm] milimeter
# Time: [s] second
# Force: [kN] kilonewton

proc definePlateSectionTEST {sectionTag materialTag bg tg} {
    section fiberSec $sectionTag {
		patch rect $materialTag 20 1 [expr -$tg/2] [expr -$bg/2] [expr $tg/2] [expr $bg/2]
	}
}

proc defineWSectionTEST {sectionTag materialTag d bf tf tw {axis strong}} {
    section fiberSec $sectionTag {
		if {$axis == "strong"} {
			patch rect $materialTag 20 1 [expr $d/2-$tf] [expr -$bf/2] [expr $d/2] [expr $bf/2]; # Left Flange definition
			patch rect $materialTag 20 1 [expr -$d/2] [expr -$bf/2] [expr -$d/2+$tf] [expr $bf/2]; # Right Flange definition
			patch rect $materialTag 20 1 [expr -$d/2+$tf] [expr -$tw/2] [expr $d/2-$tf] [expr $tw/2]; # Web definition
		} elseif {$axis == "weak"} {
			patch rect $materialTag 20 1 [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2]; # Top Flange definition
			patch rect $materialTag 20 1 [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf]; # Bottom Flange definition
			patch rect $materialTag 20 1 [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf]; # Web definition
		} else {
			puts "Axis must be 'strong' or 'weak'"
		}
	}
}

proc defineHSSSectionTEST {sectionTag materialTag h b t} {
    section fiberSec $sectionTag {
		set y [expr $b*0.5-$t*2]; # y coordinate of center of round coordinates
		set z [expr $h*0.5-$t*2]; # z coordinate of center of round coordinates
		patch circ $materialTag 6 12 $y $z $t [expr 2*$t] 0.0 90.0; # Up-right corner
		patch circ $materialTag 6 12 -$y $z $t [expr 2*$t] 90.0 180.0; # Up-left corner
		patch circ $materialTag 6 12 -$y -$z $t [expr 2*$t] 180.0 270.0; # Down-left corner
		patch circ $materialTag 6 12 $y -$z $t [expr 2*$t] 270.0 360.0; # Down-right corner
		patch rect $materialTag 12 1 [expr $b/2-$t] [expr -$h/2+2*$t] [expr $b/2] [expr $h/2-2*$t]; # Right flange
		patch rect $materialTag 12 1 [expr -$b/2] [expr -$h/2+2*$t] [expr -$b/2+$t] [expr $h/2-2*$t]; #  Left flange
		patch rect $materialTag 12 1 [expr -$b/2+2*$t] [expr $h/2-$t] [expr $b/2-2*$t] [expr $h/2]; # Top flange
		patch rect $materialTag 12 1 [expr -$b/2+2*$t] [expr -$h/2] [expr $b/2-2*$t] [expr -$h/2+$t]; # Bottom flange
	}
}

proc defineBIEWSectionTEST {sectionTag materialBraceTag materialAssemTag d bf tf tw bg tg Hs ts e} {
	section fiberSec $sectionTag {
		patch rect $materialBraceTag 20 1 [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2]; # Top Flange definition
		patch rect $materialBraceTag 20 1 [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf]; # Bottom Flange definition
		patch rect $materialBraceTag 20 1 [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf]; # Web definition

		patch rect $materialAssemTag 20 1 [expr -$e-$tg/2] [expr -$bg/2] [expr -$e+$tg/2] [expr $bg/2]; # Knife Plate definition
		patch rect $materialAssemTag 1 20 [expr -$e+$tg/2] [expr $d/2] [expr -$e+$tg/2+$Hs] [expr $d/2+$ts]; # Top Side Plate definition
		patch rect $materialAssemTag 1 20 [expr -$e+$tg/2] [expr -$d/2-$ts] [expr -$e+$tg/2+$Hs] [expr -$d/2]; # Bottom Side Plate definition
	}
}

proc defineBIEHSSSectionTEST {sectionTag materialBraceTag materialAssemTag h b t bg tg Hs ts e} {
	section fiberSec $sectionTag {
		set y [expr $b*0.5-$t*2]; # y coordinate of center of round coordinates
		set z [expr $h*0.5-$t*2]; # z coordinate of center of round coordinates
		patch circ $materialBraceTag 6 12 $y $z $t [expr 2*$t] 0.0 90.0; # Up-right corner
		patch circ $materialBraceTag 6 12 -$y $z $t [expr 2*$t] 90.0 180.0; # Up-left corner
		patch circ $materialBraceTag 6 12 -$y -$z $t [expr 2*$t] 180.0 270.0; # Down-left corner
		patch circ $materialBraceTag 6 12 $y -$z $t [expr 2*$t] 270.0 360.0; # Down-right corner
		patch rect $materialBraceTag 12 1 [expr $b/2-$t] [expr -$h/2+2*$t] [expr $b/2] [expr $h/2-2*$t]; # Right flange
		patch rect $materialBraceTag 12 1 [expr -$b/2] [expr -$h/2+2*$t] [expr -$b/2+$t] [expr $h/2-2*$t]; #  Left flange
		patch rect $materialBraceTag 12 1 [expr -$b/2+2*$t] [expr $h/2-$t] [expr $b/2-2*$t] [expr $h/2]; # Top flange
		patch rect $materialBraceTag 12 1 [expr -$b/2+2*$t] [expr -$h/2] [expr $b/2-2*$t] [expr -$h/2+$t]; # Bottom flange

		patch rect $materialAssemTag 20 1 [expr -$e-$tg/2] [expr -$bg/2] [expr -$e+$tg/2] [expr $bg/2]; # Knife Plate definition
		patch rect $materialAssemTag 1 20 [expr -$e+$tg/2] [expr $h/2] [expr -$e+$tg/2+$Hs] [expr $h/2+$ts]; # Top Side Plate definition
		patch rect $materialAssemTag 1 20 [expr -$e+$tg/2] [expr -$h/2-$ts] [expr -$e+$tg/2+$Hs] [expr -$h/2]; # Bottom Side Plate definition
	}
}