####################################################################################################
##
##      ProceduresSectionsOpenSees.tcl -- procedures for defining OpenSees sections
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##		(z)
##		 ^
##		 |
##		 |
##		 |__ __ __ > (y)
##		(x)
##
####################################################################################################

# b				Plate (or Knife-plate) width
# t				Plate (or Knife-plate) thickness

# d				W-Section depth
# tw			W-Section web thickness
# bf			W-Section flange width
# tf			W-Section flange thickness

# h				HSS-Section depth
# b				HSS-Section width
# t				HSS-Section thickness

# ts			Side-plate thickness
# Hs			Side-plate height
# e 			Eccentricity

# div_b			number of divisions in width direction (long side)
# div_t			number of divisions in thickness direction (short side)
# div_c			number of divisions in circumferential direction (number of wedges)
# div_r			number of divisions in radial direction (number of rings)

proc definePlateSection {sectionTag materialTag axis b t div_b div_t} {
    section fiberSec $sectionTag {
		if {$axis == "y"} {
			patch rect $materialTag $div_t $div_b [expr -$t/2] [expr -$b/2] [expr $t/2] [expr $b/2]; # (vertical)
		} elseif {$axis == "z"} {
			patch rect $materialTag $div_b $div_t [expr -$b/2] [expr -$t/2] [expr $b/2] [expr $t/2]; # (horizontal)
		} else {
			error "Error: Plate section $sectionTag axis must be about 'y' or 'z' axis"
		}
	}
}

proc defineWSection {sectionTag materialTag axis d tw bf tf div_d div_tw {div_bf ""} {div_tf ""}} {
	if {$div_bf eq ""} {
        set div_bf $div_d
    }
	if {$div_tf eq ""} {
        set div_tf $div_tw
    }
    section fiberSec $sectionTag {
		if {$axis == "y"} {
			patch rect $materialTag $div_bf $div_tf [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2]; # Top Flange (horizontal)
			patch rect $materialTag $div_bf $div_tf [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf]; # Bottom Flange (horizontal)
			patch rect $materialTag $div_tw $div_d [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf]; # Web (vertical)
		} elseif {$axis == "z"} {
			patch rect $materialTag $div_tf $div_bf [expr $d/2-$tf] [expr -$bf/2] [expr $d/2] [expr $bf/2]; # Right Flange (vertical)
			patch rect $materialTag $div_tf $div_bf [expr -$d/2] [expr -$bf/2] [expr -$d/2+$tf] [expr $bf/2]; # Left Flange (vertical)
			patch rect $materialTag $div_d $div_tw [expr -$d/2+$tf] [expr -$tw/2] [expr $d/2-$tf] [expr $tw/2]; # Web (horizontal)
		} else {
			error "Error: W-section $sectionTag axis must be about 'y' or 'z' axis"
		}
	}
}

proc defineBIEWSection {sectionTag materialBraceTag materialAssemTag d tw bf tf bg tg Hs ts e div_d div_tw {div_bf ""} {div_tf ""} {div_bg ""} {div_tg ""} {div_Hs ""} {div_ts ""}} {
	if {$div_bf eq ""} {
        set div_bf $div_d
    }
	if {$div_tf eq ""} {
        set div_tf $div_tw
    }
	if {$div_bg eq ""} {
        set div_bg $div_d
    }
	if {$div_tg eq ""} {
        set div_tg $div_tw
    }
	if {$div_Hs eq ""} {
        set div_Hs $div_bg
    }
	if {$div_ts eq ""} {
        set div_ts $div_tg
    }
	section fiberSec $sectionTag {
		patch rect $materialBraceTag $div_bf $div_tf [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2]; # Top Flange definition
		patch rect $materialBraceTag $div_bf $div_tf [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf]; # Bottom Flange definition
		patch rect $materialBraceTag $div_tw $div_d [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf]; # Web definition

		patch rect $materialAssemTag $div_tg $div_bg [expr -$e-$tg/2] [expr -$bg/2] [expr -$e+$tg/2] [expr $bg/2]; # Knife Plate definition
		patch rect $materialAssemTag $div_Hs $div_ts [expr -$e+$tg/2] [expr $d/2] [expr -$e+$tg/2+$Hs] [expr $d/2+$ts]; # Top Side Plate definition
		patch rect $materialAssemTag $div_Hs $div_ts [expr -$e+$tg/2] [expr -$d/2-$ts] [expr -$e+$tg/2+$Hs] [expr -$d/2]; # Bottom Side Plate definition
	}
}

proc defineHSSSection {sectionTag materialTag axis h b t div_h div_th {div_b ""} {div_tb ""} {div_c ""} {div_r ""}} {
	if {$div_b eq ""} {
        set div_b $div_h
    }
	if {$div_tb eq ""} {
        set div_tb $div_th
    }
	if {$div_c eq ""} {
        set div_c [expr $div_h/2]
    }
	if {$div_r eq ""} {
        set div_r $div_th
    }
    section fiberSec $sectionTag {
		if {$axis == "y"} {
			set y [expr $b*0.5-$t*2]; # y coordinate of center of round coordinates
			set z [expr $h*0.5-$t*2]; # z coordinate of center of round coordinates
			patch circ $materialTag $div_c $div_r $y $z $t [expr 2*$t] 0.0 90.0; # Up-right corner
			patch circ $materialTag $div_c $div_r -$y $z $t [expr 2*$t] 90.0 180.0; # Up-left corner
			patch circ $materialTag $div_c $div_r -$y -$z $t [expr 2*$t] 180.0 270.0; # Down-left corner
			patch circ $materialTag $div_c $div_r $y -$z $t [expr 2*$t] 270.0 360.0; # Down-right corner
			patch rect $materialTag $div_th $div_h [expr $b/2-$t] [expr -$h/2+2*$t] [expr $b/2] [expr $h/2-2*$t]; # Right flange (vertical)
			patch rect $materialTag $div_th $div_h [expr -$b/2] [expr -$h/2+2*$t] [expr -$b/2+$t] [expr $h/2-2*$t]; # Left flange (vertical)
			patch rect $materialTag $div_b $div_tb [expr -$b/2+2*$t] [expr $h/2-$t] [expr $b/2-2*$t] [expr $h/2]; # Top flange (horizontal)
			patch rect $materialTag $div_b $div_tb [expr -$b/2+2*$t] [expr -$h/2] [expr $b/2-2*$t] [expr -$h/2+$t]; # Bottom flange (horizontal)
		} elseif {$axis == "z"} {
			set y [expr $h*0.5-$t*2]; # y coordinate of center of round coordinates
			set z [expr $b*0.5-$t*2]; # z coordinate of center of round coordinates
			patch circ $materialTag $div_c $div_r $y $z $t [expr 2*$t] 0.0 90.0; # Up-right corner
			patch circ $materialTag $div_c $div_r -$y $z $t [expr 2*$t] 90.0 180.0; # Up-left corner
			patch circ $materialTag $div_c $div_r -$y -$z $t [expr 2*$t] 180.0 270.0; # Down-left corner
			patch circ $materialTag $div_c $div_r $y -$z $t [expr 2*$t] 270.0 360.0; # Down-right corner
			patch rect $materialTag $div_h $div_th [expr -$h/2+2*$t] [expr $b/2-$t] [expr $h/2-2*$t] [expr $b/2]; # Top flange (horizontal)
			patch rect $materialTag $div_h $div_th [expr -$h/2+2*$t] [expr -$b/2] [expr $h/2-2*$t] [expr -$b/2+$t]; # Bottom flange (horizontal)
			patch rect $materialTag $div_tb $div_b [expr $h/2-$t] [expr -$b/2+2*$t] [expr $h/2] [expr $b/2-2*$t]; # Right flange (vertical)
			patch rect $materialTag $div_tb $div_b [expr -$h/2] [expr -$b/2+2*$t] [expr -$h/2+$t] [expr $b/2-2*$t]; # Left flange (vertical)
		} else {
			error "Error: HSS-section $sectionTag axis must be about 'y' or 'z' axis"
		}
	}
}

proc defineBIEHSSSection {sectionTag materialBraceTag materialAssemTag h b t bg tg Hs ts e div_h div_th {div_b ""} {div_tb ""} {div_bg ""} {div_tg ""} {div_Hs ""} {div_ts ""} {div_c ""} {div_r ""}} {
	if {$div_b eq ""} {
        set div_b $div_h
    }
	if {$div_tb eq ""} {
        set div_tb $div_th
    }
	if {$div_bg eq ""} {
        set div_bg $div_h
    }
	if {$div_tg eq ""} {
        set div_tg $div_th
    }
	if {$div_Hs eq ""} {
        set div_Hs $div_bg
    }
	if {$div_ts eq ""} {
        set div_ts $div_tg
    }
	if {$div_c eq ""} {
        set div_c [expr $div_h/2]
    }
	if {$div_r eq ""} {
        set div_r $div_th
    }
	section fiberSec $sectionTag {
		set y [expr $b*0.5-$t*2]; # y coordinate of center of round coordinates
		set z [expr $h*0.5-$t*2]; # z coordinate of center of round coordinates
		patch circ $materialBraceTag $div_c $div_r $y $z $t [expr 2*$t] 0.0 90.0; # Up-right corner
		patch circ $materialBraceTag $div_c $div_r -$y $z $t [expr 2*$t] 90.0 180.0; # Up-left corner
		patch circ $materialBraceTag $div_c $div_r -$y -$z $t [expr 2*$t] 180.0 270.0; # Down-left corner
		patch circ $materialBraceTag $div_c $div_r $y -$z $t [expr 2*$t] 270.0 360.0; # Down-right corner
		patch rect $materialBraceTag $div_th $div_h [expr $b/2-$t] [expr -$h/2+2*$t] [expr $b/2] [expr $h/2-2*$t]; # Right flange
		patch rect $materialBraceTag $div_th $div_h [expr -$b/2] [expr -$h/2+2*$t] [expr -$b/2+$t] [expr $h/2-2*$t]; #  Left flange
		patch rect $materialBraceTag $div_b $div_tb [expr -$b/2+2*$t] [expr $h/2-$t] [expr $b/2-2*$t] [expr $h/2]; # Top flange
		patch rect $materialBraceTag $div_b $div_tb [expr -$b/2+2*$t] [expr -$h/2] [expr $b/2-2*$t] [expr -$h/2+$t]; # Bottom flange

		patch rect $materialAssemTag $div_tg $div_bg [expr -$e-$tg/2] [expr -$bg/2] [expr -$e+$tg/2] [expr $bg/2]; # Knife Plate definition
		patch rect $materialAssemTag $div_Hs $div_ts [expr -$e+$tg/2] [expr $h/2] [expr -$e+$tg/2+$Hs] [expr $h/2+$ts]; # Top Side Plate definition
		patch rect $materialAssemTag $div_Hs $div_ts [expr -$e+$tg/2] [expr -$h/2-$ts] [expr -$e+$tg/2+$Hs] [expr -$h/2]; # Bottom Side Plate definition
	}
}