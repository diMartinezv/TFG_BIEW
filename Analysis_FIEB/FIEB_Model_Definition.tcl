####################################################################################################
##
##      FIEB_Model_Definition.tcl -- 2D Multi-Story FIEB Model Definitions
##
##      Design following modified DDBD procedure. 10 % increase in accelerograms due to accidental eccentricity
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##      Story configuration
##          ...|/|\|...
##
##		Options:
##		"display_Analysis" - show display window with model [1/0] (barely works and only with OpenSees 3.3). Defaults to false
##		"stop_at_Modes" - stops process after displaying periods of vibrational modes [1/0]. Defaults to false
##		"totalModes" - total modes of vibrations to calculate (>= 2). Defaults to 2
##		"displayModes" - modes of vibrations displayed in console (<= totalModes). Comment to not display
##
####################################################################################################

# -------------------------
# List checker 
# -------------------------
puts "\n---------- Values check ----------"
if {$numberStories<1} {
	error "Error: Number of Stories must be at least 1"
}
if {$L<=0} {
	error "Error: 'L' (bay width) must be positive"
}
set modelLists [list "H"]; # Height list
lappend modelLists {*}[list "weight" "columnloadsend" "columnloadscenter" "beamloads" "leaningframeloads"]; # Loads lists
lappend modelLists {*}[list "e" "Lp" "ts" "Hs" "bg" "tg" "Lg" "Lb" "Ai" "Ii"]; # Eccentering assembly dimensions lists
lappend modelLists {*}[list "d_ec" "bf_ec" "tf_ec" "tw_ec"]; # External columns dimensions lists
lappend modelLists {*}[list "d_ic" "bf_ic" "tf_ic" "tw_ic"]; # Internal columns dimensions lists
lappend modelLists {*}[list "d_be" "bf_be" "tf_be" "tw_be"]; # Beams dimensions lists
switch -- $braceSection {
    "W" {
        lappend modelLists {*}[list "d_br" "bf_br" "tf_br" "tw_br"]; # W-Section Brace dimensions
    }
    "HSS" {
        lappend modelLists {*}[list "h_br" "b_br" "t_br"]; # HSS-Section Brace dimensions
    }
    default {
        error "Error: Invalid Brace section\n"
    }
}
set allLengthCorrect [checkListsLengths $numberStories $modelLists]
if {$allLengthCorrect} {
    puts "\n$numberStories-Story Frames with Intentional Eccentric $braceSection-Section Braces correctly defined"
	puts "Running: $record..."
} else {
	error "Error: Missing values for $numberStories-Story $braceSection-Section Braces analysis\n"
}
set AccH [accumulateList $H true]; # Create list with accumulated heights
set initial_time [clock clicks -milliseconds]; # Start timer to check model contruction duration

# -------------------------
# Geometric Transformations 
# -------------------------
set coorTransf1 1
set coorTransf2 2
geomTransf Corotational $coorTransf1; # For braces and columns
geomTransf PDelta $coorTransf2; # For beams, given that the corotational transformation is not compatible with element loads

# -------------------------
# Section Definition 
# -------------------------
set axisBrace "y"; # bending about y axis (weak)
set axisKnife "y"; # bending about y axis (weak)
set axisColumn "y"; # bending about y axis (weak)
set axisBeam "z"; # bending about z axis (strong)
set ndw 1; # fibers across W web depth in weak axis
set ntww 20; # fibers across W web thickness in weak axis
set nbfw 20; # fibers across W flange width in weak axis
set ntfw 1; # fibers across W flange thickness in weak axis
set nds 20; # fibers across W web depth in strong axis
set ntws 1; # fibers across W web thickness in strong axis
set nbfs 1; # fibers across W flange width in strong axis
set ntfs 20; # fibers across W flange thickness in strong axis
set nhw 1; # fibers across HSS height in weak axis
set nthw 12; # fibers along HSS height in weak axis
set nbw 12; # fibers across HSS width in weak axis
set ntbw 1; # fibers along HSS width in weak axis
set nbg 1; # fibers across plate width direction
set ntg 20; # fibers across plate thickness direction
set braceTag [list]
set knifeTag [list]
set assemBIETag [list]
set colExtTag [list]
set colIntTag [list]
set beamTag [list]
for {set i 0} {$i<$numberStories} {incr i} {
	# --- Dimensions ---
	set ei [lindex $e $i]
	set tsi [lindex $ts $i]
	set Hsi [lindex $Hs $i]
	set bgi [lindex $bg $i]
	set tgi [lindex $tg $i]
	set d_eci [lindex $d_ec $i]
	set bf_eci [lindex $bf_ec $i]
	set tf_eci [lindex $tf_ec $i]
	set tw_eci [lindex $tw_ec $i]
	set d_ici [lindex $d_ic $i]
	set bf_ici [lindex $bf_ic $i]
	set tf_ici [lindex $tf_ic $i]
	set tw_ici [lindex $tw_ic $i]
	set d_bei [lindex $d_be $i]
	set bf_bei [lindex $bf_be $i]
	set tf_bei [lindex $tf_be $i]
	set tw_bei [lindex $tw_be $i]
	# --- Section tags ---
	lappend braceTag [expr 6*$i+1]
	lappend knifeTag [expr 6*$i+2]
	lappend assemBIETag [expr 6*$i+3]
	lappend colExtTag [expr 6*$i+4]
	lappend colIntTag [expr 6*$i+5]
	lappend beamTag [expr 6*$i+6]
	# --- Section definition ---
	switch -- $braceSection {
		"W" {
			# --- Dimensions ---
			set d_bri [lindex $d_br $i]
			set bf_bri [lindex $bf_br $i]
			set tf_bri [lindex $tf_br $i]
			set tw_bri [lindex $tw_br $i]
			# ----- Free braces -----
			defineWSection [lindex $braceTag $i] $matBraceTag $axisBrace $d_bri $tw_bri $bf_bri $tf_bri $ndw $ntww $nbfw $ntfw
			# ----- Assembly for BIE -----
			defineBIEWSection [lindex $assemBIETag $i] $matBraceTag $matAssemTag $d_bri $tw_bri $bf_bri $tf_bri $bgi $tgi $Hsi $tsi $ei $ndw $ntww $nbfw $ntfw $nbg $ntg
		}
		"HSS" {
			# --- Dimensions ---
			set h_bri [lindex $h_br $i]
			set b_bri [lindex $b_br $i]
			set t_bri [lindex $t_br $i]
			# ----- Free braces -----
			defineHSSSection [lindex $braceTag $i] $matBraceTag $axisBrace $h_bri $b_bri $t_bri $nhw $nthw $nbw $ntbw
			# ----- Assembly for BIE -----
			defineBIEHSSSection [lindex $assemBIETag $i] $matBraceTag $matAssemTag $h_bri $b_bri $t_bri $bgi $tgi $Hsi $tsi $ei $nhw $nthw $nbw $ntbw $nbg $ntg
		}
	}
	# ----- Knife plate -----
    definePlateSection [lindex $knifeTag $i] $matBraceTag $axisKnife $bgi $tgi $nbg $ntg
	# ----- External Columns - (bending about weak axis)
    defineWSection [lindex $colExtTag $i] $matAssemTag $axisColumn $d_eci $tw_eci $bf_eci $tf_eci $ndw $ntww $nbfw $ntfw
	# ----- Internal Columns - (bending about weak axis)
    defineWSection [lindex $colIntTag $i] $matAssemTag $axisColumn $d_ici $tw_ici $bf_ici $tf_ici $ndw $ntww $nbfw $ntfw
	# ----- Beams - (bending about strong axis)
    defineWSection [lindex $beamTag $i] $matAssemTag $axisBeam $d_bei $tw_bei $bf_bei $tf_bei $nds $ntws $nbfs $ntfs
}

# -------------------------
# Node Definition
# -------------------------
# Note that nodes at the ends of columns/beams/braces are duplicated, continuity must be enforced by use of constraints
set elemColBeam [expr {[info exists elemColBeam] ? max($elemColBeam, 1) : 8}]; # Ensure a minimum of 1 element per column/beam
set elemBrace [expr {[info exists elemBrace] ? max($elemBrace, 1) : 8}]; # Ensure a minimum of 1 element per brace
set elemKnife [expr {[info exists elemKnife] ? max($elemKnife, 1) : 2}]; # Ensure a minimum of 1 element per hinging knife plate
set imperfection [expr {[info exists imperfection] ? $imperfection : 0.001}]; # out-of-plane imperfection of members (braces, beams, and columns), fraction of length (max. deflection at mid-point)
# ----- Numbering -----
set numNodes [expr 5*($elemColBeam+1)+4*($elemKnife+1)+2*($elemBrace+1)+5]; # number of nodes per floor
set nodeLeaningFrame [list]
set nodeAssemDownLeft [list]
set nodeAssemUpLeft [list]
set nodeAssemUpRight [list]
set nodeAssemDownRight [list]
set nodeColLeft [list]
set nodeColCenter [list]
set nodeColRight [list]
set nodeBeamLeft [list]
set nodeBeamRight [list]
set nodeKnifeDownLeft [list]
set nodeKnifeUpLeft [list]
set nodeKnifeUpRight [list]
set nodeKnifeDownRight [list]
set nodeBraceLeft [list]
set nodeBraceRight [list]
for {set i 0} {$i<$numberStories} {incr i} {
	lappend nodeLeaningFrame [expr $i*$numNodes+1]
	lappend nodeAssemDownLeft [expr $i*$numNodes+2]
	lappend nodeAssemUpLeft [expr $i*$numNodes+3]
	lappend nodeAssemUpRight [expr $i*$numNodes+4]
	lappend nodeAssemDownRight [expr $i*$numNodes+5]
	for {set j 0} {$j<=$elemColBeam} {incr j} {
		lappend nodeColLeft [expr $i*$numNodes+0*($elemColBeam+1)+6+$j]
		lappend nodeColCenter [expr $i*$numNodes+1*($elemColBeam+1)+6+$j]
		lappend nodeColRight [expr $i*$numNodes+2*($elemColBeam+1)+6+$j]
		lappend nodeBeamLeft [expr $i*$numNodes+3*($elemColBeam+1)+6+$j]
		lappend nodeBeamRight [expr $i*$numNodes+4*($elemColBeam+1)+6+$j]
	}
	for {set j 0} {$j<=$elemKnife} {incr j} {
		lappend nodeKnifeDownLeft [expr $i*$numNodes+5*($elemColBeam+1)+0*($elemKnife+1)+6+$j]
		lappend nodeKnifeUpLeft [expr $i*$numNodes+5*($elemColBeam+1)+1*($elemKnife+1)+6+$j]
		lappend nodeKnifeUpRight [expr $i*$numNodes+5*($elemColBeam+1)+2*($elemKnife+1)+6+$j]
		lappend nodeKnifeDownRight [expr $i*$numNodes+5*($elemColBeam+1)+3*($elemKnife+1)+6+$j]
	}
	for {set j 0} {$j<=$elemBrace} {incr j} {
		lappend nodeBraceLeft [expr $i*$numNodes+5*($elemColBeam+1)+4*($elemKnife+1)+0*($elemBrace+1)+6+$j]
		lappend nodeBraceRight [expr $i*$numNodes+5*($elemColBeam+1)+4*($elemKnife+1)+1*($elemBrace+1)+6+$j]
	}
}
lappend nodeLeaningFrame [expr $numberStories*$numNodes+1]
# ----- Definition -----
for {set i 0} {$i<$numberStories} {incr i} {
	# --- Dimensions ---
	set AccHi [lindex $AccH $i]
	set AccHii [lindex $AccH [expr $i+1]]
	set Hi [lindex $H $i]
	set ei [lindex $e $i]
	set Lpi [lindex $Lp $i]
	set Lgi [lindex $Lg $i]
	set Lbi [lindex $Lb $i]
	set ang [expr atan2($Hi,$L)]; # angle (rad) of the brace
	set offset [expr (sqrt(pow($Hi,2)+pow($L,2))-($Lbi+2*$Lpi+2*$Lgi))/2]; # "offset" accounts for actual distance between column/beam node to brace hinge (gusset), it is idealised as perfectly rigid
	# ----- Leaning Frame ---
	node [lindex $nodeLeaningFrame $i] [expr 3*$L] [expr $AccHi]
	for {set j 0} {$j<=[expr $elemColBeam]} {incr j} {
		# -----Columns and Beam---
		node [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$j]] [expr 0*$L+$imperfection*sin($i*$PI-$PI*$j/$elemColBeam)*$Hi] [expr $j*$Hi/$elemColBeam+$AccHi]
		node [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$j]] [expr 1*$L+$imperfection*sin($i*$PI-$PI*$j/$elemColBeam)*$Hi] [expr $j*$Hi/$elemColBeam+$AccHi]
		node [lindex $nodeColRight [expr $i*($elemColBeam+1)+$j]] [expr 2*$L+$imperfection*sin($i*$PI-$PI*$j/$elemColBeam)*$Hi] [expr $j*$Hi/$elemColBeam+$AccHi]
		node [lindex $nodeBeamLeft [expr $i*($elemColBeam+1)+$j]] [expr 0*$L+$j*$L/$elemColBeam] [expr $AccHii-sin($PI*$j/$elemColBeam)*$L*$imperfection]
		node [lindex $nodeBeamRight [expr $i*($elemColBeam+1)+$j]] [expr 1*$L+$j*$L/$elemColBeam] [expr $AccHii-sin($PI*$j/$elemColBeam)*$L*$imperfection]
	}
	# ----- Braces ---
	# --- Left Bay ---
	for {set j 0} {$j<=$elemKnife} {incr j} {
		node [lindex $nodeKnifeDownLeft [expr $i*($elemKnife+1)+$j]] [expr ($offset+$j*$Lgi/$elemKnife)*cos($ang)] [expr ($offset+$j*$Lgi/$elemKnife)*sin($ang)+$AccHi]
	}
	node [lindex $nodeAssemDownLeft $i] [expr ($offset+$Lgi+$Lpi)*cos($ang)] [expr ($offset+$Lgi+$Lpi)*sin($ang)+$AccHi]
	for {set j 0} {$j<=$elemBrace} {incr j} {
		node [lindex $nodeBraceLeft [expr $i*($elemBrace+1)+$j]] [expr ($offset+$Lgi+$Lpi+$j*$Lbi/$elemBrace)*cos($ang)-($ei+$imperfection*sin($PI*$j/$elemBrace)*$Lbi)*sin($ang)] [expr ($offset+$Lgi+$Lpi+$j*$Lbi/$elemBrace)*sin($ang)+($ei+$imperfection*sin($PI*$j/$elemBrace)*$Lbi)*cos($ang)+$AccHi]
	}
	node [lindex $nodeAssemUpLeft $i] [expr ($offset+$Lgi+$Lpi+$Lbi)*cos($ang)] [expr ($offset+$Lgi+$Lpi+$Lbi)*sin($ang)+$AccHi]
	for {set j 0} {$j<=$elemKnife} {incr j} {
		node [lindex $nodeKnifeUpLeft [expr $i*($elemKnife+1)+$j]] [expr ($offset+$Lgi+$j*$Lgi/($elemKnife)+2*$Lpi+$Lbi)*cos($ang)] [expr ($offset+$Lgi+$j*$Lgi/($elemKnife)+2*$Lpi+$Lbi)*sin($ang)+$AccHi]
	}
	# --- Right Bay ---
	for {set j 0} {$j<=$elemKnife} {incr j} {
		node [lindex $nodeKnifeUpRight [expr $i*($elemKnife+1)+$j]] [expr $L+($offset+$j*$Lgi/$elemKnife)*cos($ang)] [expr -($offset+$j*$Lgi/$elemKnife)*sin($ang)+$AccHii]
	}
	node [lindex $nodeAssemUpRight $i] [expr $L+($offset+$Lgi+$Lpi)*cos($ang)] [expr -($offset+$Lgi+$Lpi)*sin($ang)+$AccHii]
	for {set j 0} {$j<=$elemBrace} {incr j} {
		node [lindex $nodeBraceRight [expr $i*($elemBrace+1)+$j]] [expr $L+($offset+$Lgi+$Lpi+$j*$Lbi/$elemBrace)*cos($ang)+($ei+$imperfection*sin($PI*$j/$elemBrace)*$Lbi)*sin($ang)] [expr -($offset+$Lgi+$Lpi+$j*$Lbi/$elemBrace)*sin($ang)+($ei+$imperfection*sin($PI*$j/$elemBrace)*$Lbi)*cos($ang)+$AccHii]
	}
	node [lindex $nodeAssemDownRight $i] [expr $L+($offset+$Lgi+$Lpi+$Lbi)*cos($ang)] [expr -($offset+$Lgi+$Lpi+$Lbi)*sin($ang)+$AccHii]
	for {set j 0} {$j<=$elemKnife} {incr j} {
		node [lindex $nodeKnifeDownRight [expr $i*($elemKnife+1)+$j]] [expr $L+($offset+$Lgi+$j*$Lgi/$elemKnife+2*$Lpi+$Lbi)*cos($ang)] [expr -($offset+$Lgi+$j*$Lgi/$elemKnife+2*$Lpi+$Lbi)*sin($ang)+$AccHii]
	}
}
node [lindex $nodeLeaningFrame $numberStories] [expr 3*$L] [expr [lindex $AccH $numberStories]]; # Last leaning frame node

# -------------------------
# Element Definition
# -------------------------
set integrationPoints [expr {[info exists integrationPoints] ? max($integrationPoints, 1) : 7}]; # Ensure a minimum of 1 integration point in each forceBeamColumn element
# ----- Numbering -----
set numElements [expr 5*$elemColBeam+4*$elemKnife+2*$elemBrace+13]; # number of elements per floor
set elemLeaningFrame [list]
set elemGussetDownLeft [list]
set elemGussetUpLeft [list]
set elemGussetUpRight [list]
set elemGussetDownRight [list]
set elemAssemDownLeft [list]
set elemAssemUpLeft [list]
set elemAssemUpRight [list]
set elemAssemDownRight [list]
set elemPlatesDownLeft [list]
set elemPlatesUpLeft [list]
set elemPlatesUpRight [list]
set elemPlatesDownRight [list]
set elemColLeft [list]
set elemColCenter [list]
set elemColRight [list]
set elemBeamLeft [list]
set elemBeamRight [list]
set elemKnifeDownLeft [list]
set elemKnifeUpLeft [list]
set elemKnifeUpRight [list]
set elemKnifeDownRight [list]
set elemBraceLeft [list]
set elemBraceRight [list]
for {set i 0} {$i<$numberStories} {incr i} {
	lappend elemLeaningFrame [expr $i*$numElements+1]
	lappend elemGussetDownLeft [expr $i*$numElements+2]
	lappend elemGussetUpLeft [expr $i*$numElements+3]
	lappend elemGussetUpRight [expr $i*$numElements+4]
	lappend elemGussetDownRight [expr $i*$numElements+5]
	lappend elemAssemDownLeft [expr $i*$numElements+6]
	lappend elemAssemUpLeft [expr $i*$numElements+7]
	lappend elemAssemUpRight [expr $i*$numElements+8]
	lappend elemAssemDownRight [expr $i*$numElements+9]
	lappend elemPlatesDownLeft [expr $i*$numElements+10]
	lappend elemPlatesUpLeft [expr $i*$numElements+11]
	lappend elemPlatesUpRight [expr $i*$numElements+12]
	lappend elemPlatesDownRight [expr $i*$numElements+13]
	for {set j 0} {$j<$elemColBeam} {incr j} {
		lappend elemColLeft [expr $i*$numElements+0*$elemColBeam+14+$j]
		lappend elemColCenter [expr $i*$numElements+1*$elemColBeam+14+$j]
		lappend elemColRight [expr $i*$numElements+2*$elemColBeam+14+$j]
		lappend elemBeamLeft [expr $i*$numElements+3*$elemColBeam+14+$j]
		lappend elemBeamRight [expr $i*$numElements+4*$elemColBeam+14+$j]
	}
	for {set j 0} {$j<$elemKnife} {incr j} {
		lappend elemKnifeDownLeft [expr $i*$numElements+5*$elemColBeam+0*$elemKnife+14+$j]
		lappend elemKnifeUpLeft [expr $i*$numElements+5*$elemColBeam+1*$elemKnife+14+$j]
		lappend elemKnifeUpRight [expr $i*$numElements+5*$elemColBeam+2*$elemKnife+14+$j]
		lappend elemKnifeDownRight [expr $i*$numElements+5*$elemColBeam+3*$elemKnife+14+$j]
	}
	for {set j 0} {$j<$elemBrace} {incr j} {
		lappend elemBraceLeft [expr $i*$numElements+5*$elemColBeam+4*$elemKnife+0*$elemBrace+14+$j]
		lappend elemBraceRight [expr $i*$numElements+5*$elemColBeam+4*$elemKnife+1*$elemBrace+14+$j]
	}
}
# ----- Definition -----
for {set i 0} {$i<$numberStories} {incr i} {
	# --- Dimensions ---
	set Aii [lindex $Ai $i]
	set Iii [lindex $Ii $i]
	set Lpi [lindex $Lp $i]
	set tsi [lindex $ts $i]
	set APlates [expr 2*$Lpi*$tsi]
	set IPLates [expr 2*(pow($Lpi,3)*$tsi/12)]
	# --- Section tags ---
	set braceTagi [lindex $braceTag $i]
	set knifeTagi [lindex $knifeTag $i]
	set assemBIETagi [lindex $assemBIETag $i]
	set colExtTagi [lindex $colExtTag $i]
	set colIntTagi [lindex $colIntTag $i]
	set beamTagi [lindex $beamTag $i]
	# ----- Leaning Frames -----
	element elasticBeamColumn [lindex $elemLeaningFrame $i] [lindex $nodeLeaningFrame $i] [lindex $nodeLeaningFrame [expr $i+1]] [expr $NumberSmall] $SteelE [expr $NumberSmall] $coorTransf1; # area and I are set to very small numbers
	for {set j 0} {$j<$elemColBeam} {incr j} {
		# --- Node Tags ---
		set nodeColLeftj [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$j]]
		set nodeColCenterj [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$j]]
		set nodeColRightj [lindex $nodeColRight [expr $i*($elemColBeam+1)+$j]]
		set nodeBeamLeftj [lindex $nodeBeamLeft [expr $i*($elemColBeam+1)+$j]]
		set nodeBeamRightj [lindex $nodeBeamRight [expr $i*($elemColBeam+1)+$j]]
		# --- Column and Beam Elements ---
		element forceBeamColumn [lindex $elemColLeft [expr $i*$elemColBeam+$j]] $nodeColLeftj [expr $nodeColLeftj+1] $coorTransf1 Lobatto $colExtTagi $integrationPoints
		element forceBeamColumn [lindex $elemColCenter [expr $i*$elemColBeam+$j]] $nodeColCenterj [expr $nodeColCenterj+1] $coorTransf1 Lobatto $colIntTagi $integrationPoints
		element forceBeamColumn [lindex $elemColRight [expr $i*$elemColBeam+$j]] $nodeColRightj [expr $nodeColRightj+1] $coorTransf1 Lobatto $colExtTagi $integrationPoints
		element forceBeamColumn [lindex $elemBeamLeft [expr $i*$elemColBeam+$j]] $nodeBeamLeftj [expr $nodeBeamLeftj+1] $coorTransf2 Lobatto $beamTagi $integrationPoints
		element forceBeamColumn [lindex $elemBeamRight [expr $i*$elemColBeam+$j]] $nodeBeamRightj [expr $nodeBeamRightj+1] $coorTransf2 Lobatto $beamTagi $integrationPoints
	}
	# ------- Brace Elements -------
	# --- "Ascending" brace - left connection (left to right)
	element elasticBeamColumn [lindex $elemGussetDownLeft $i] [lindex $nodeColLeft [expr $i*($elemColBeam+1)]] [lindex $nodeKnifeDownLeft [expr $i*($elemKnife+1)]] $Aii $SteelE $Iii $coorTransf1; # Bottom Column to brace conection
	for {set j 0} {$j<$elemKnife} {incr j} {
		set nodeKnifeDownLeftj [lindex $nodeKnifeDownLeft [expr $i*($elemKnife+1)+$j]]
		element forceBeamColumn [lindex $elemKnifeDownLeft [expr $i*$elemKnife+$j]] $nodeKnifeDownLeftj [expr $nodeKnifeDownLeftj+1] $coorTransf1 Lobatto $knifeTagi $integrationPoints; # Bottom Hinging knife plate
	}
	element forceBeamColumn [lindex $elemAssemDownLeft $i] [lindex $nodeKnifeDownLeft [expr $i*($elemKnife+1)+$elemKnife]] [lindex $nodeAssemDownLeft $i] $coorTransf1 Lobatto $assemBIETagi $integrationPoints; # Bottom Eccentering assembly
	element elasticBeamColumn [lindex $elemPlatesDownLeft $i] [lindex $nodeAssemDownLeft $i] [lindex $nodeBraceLeft [expr $i*($elemBrace+1)]] $APlates $SteelE $IPLates $coorTransf1; # Bottom Side plates
	for {set j 0} {$j<$elemBrace} {incr j} {
		set nodeBraceLeftj [lindex $nodeBraceLeft [expr $i*($elemBrace+1)+$j]]
		element forceBeamColumn [lindex $elemBraceLeft [expr $i*$elemBrace+$j]] $nodeBraceLeftj [expr $nodeBraceLeftj+1] $coorTransf1 Lobatto $braceTagi $integrationPoints; # Free brace
	}
	element elasticBeamColumn [lindex $elemPlatesUpLeft $i] [lindex $nodeBraceLeft [expr $i*($elemBrace+1)+$elemBrace]] [lindex $nodeAssemUpLeft $i] $APlates $SteelE $IPLates $coorTransf1; # Top Side plates
	element forceBeamColumn [lindex $elemAssemUpLeft $i] [lindex $nodeAssemUpLeft $i] [lindex $nodeKnifeUpLeft [expr $i*($elemKnife+1)]] $coorTransf1 Lobatto $assemBIETagi $integrationPoints; # Top Eccentering assembly
	for {set j 0} {$j<$elemKnife} {incr j} {
		set nodeKnifeUpLeftj [lindex $nodeKnifeUpLeft [expr $i*($elemKnife+1)+$j]]
		element forceBeamColumn [lindex $elemKnifeUpLeft [expr $i*$elemKnife+$j]] $nodeKnifeUpLeftj [expr $nodeKnifeUpLeftj+1] $coorTransf1 Lobatto $knifeTagi $integrationPoints; # Top Hinging knife plate
	}
	element elasticBeamColumn [lindex $elemGussetUpLeft $i] [lindex $nodeKnifeUpLeft [expr $i*($elemKnife+1)+$elemKnife]] [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] $Aii $SteelE $Iii $coorTransf1; # Top Column to brace conection
	# --- "Descending" brace - left connection (left to right)
	element elasticBeamColumn [lindex $elemGussetUpRight $i] [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeKnifeUpRight [expr $i*($elemKnife+1)]] $Aii $SteelE $Iii $coorTransf1; # Top Column to brace conection
	for {set j 0} {$j<$elemKnife} {incr j} {
		set nodeKnifeUpRightj [lindex $nodeKnifeUpRight [expr $i*($elemKnife+1)+$j]]
		element forceBeamColumn [lindex $elemKnifeUpRight [expr $i*$elemKnife+$j]] $nodeKnifeUpRightj [expr $nodeKnifeUpRightj+1] $coorTransf1 Lobatto $knifeTagi $integrationPoints; # Top Hinging knife plate
	}
	element forceBeamColumn [lindex $elemAssemUpRight $i] [lindex $nodeKnifeUpRight [expr $i*($elemKnife+1)+$elemKnife]] [lindex $nodeAssemUpRight $i] $coorTransf1 Lobatto $assemBIETagi $integrationPoints; # Top Eccentering assembly
	element elasticBeamColumn [lindex $elemPlatesUpRight $i] [lindex $nodeAssemUpRight $i] [lindex $nodeBraceRight [expr $i*($elemBrace+1)]] $APlates $SteelE $IPLates $coorTransf1; # Top Side plates
	for {set j 0} {$j<$elemBrace} {incr j} {
		set nodeBraceRightj [lindex $nodeBraceRight [expr $i*($elemBrace+1)+$j]]
		element forceBeamColumn [lindex $elemBraceRight [expr $i*$elemBrace+$j]] $nodeBraceRightj [expr $nodeBraceRightj+1] $coorTransf1 Lobatto $braceTagi $integrationPoints; # Free brace
	}
	element elasticBeamColumn [lindex $elemPlatesDownRight $i] [lindex $nodeBraceRight [expr $i*($elemBrace+1)+$elemBrace]] [lindex $nodeAssemDownRight $i] $APlates $SteelE $IPLates $coorTransf1; # Bottom Side plates
	element forceBeamColumn [lindex $elemAssemDownRight $i] [lindex $nodeAssemDownRight $i] [lindex $nodeKnifeDownRight [expr $i*($elemKnife+1)]] $coorTransf1 Lobatto $assemBIETagi $integrationPoints; # Bottom Eccentering assembly
	for {set j 0} {$j<$elemKnife} {incr j} {
		set nodeKnifeDownRightj [lindex $nodeKnifeDownRight [expr $i*($elemKnife+1)+$j]]
		element forceBeamColumn [lindex $elemKnifeDownRight [expr $i*$elemKnife+$j]] $nodeKnifeDownRightj [expr $nodeKnifeDownRightj+1] $coorTransf1 Lobatto $knifeTagi $integrationPoints; # Bottom Hinging knife plate
	}
	element elasticBeamColumn [lindex $elemGussetDownRight $i] [lindex $nodeKnifeDownRight [expr $i*($elemKnife+1)+$elemKnife]] [lindex $nodeColRight [expr $i*($elemColBeam+1)]] $Aii $SteelE $Iii $coorTransf1; # Bottom Column to brace conection
}

# -------------------------
# Constraints and supports
# -------------------------
# ----- Ground supports
fix [lindex $nodeLeaningFrame 0] 1 1 0
fix [lindex $nodeColLeft 0] 1 1 0
fix [lindex $nodeColCenter 0] 1 1 0
fix [lindex $nodeColRight 0] 1 1 0
# ----- Inter-Story Column Continuity (full restraint)
for {set i 0} {$i<($numberStories-1)} {incr i} {
	equalDOF [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeColLeft [expr ($i+1)*($elemColBeam+1)]] 1 2 3
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeColCenter [expr ($i+1)*($elemColBeam+1)]] 1 2 3
	equalDOF [lindex $nodeColRight [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeColRight [expr ($i+1)*($elemColBeam+1)]] 1 2 3
}
# ----- Beam-Column Continuity (shear connection - but presence of brace gusset plate enforces rotational constraint)
for {set i 0} {$i<$numberStories} {incr i} {
	equalDOF [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeBeamLeft [expr $i*($elemColBeam+1)]] 1 2 3
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeBeamLeft [expr $i*($elemColBeam+1)+$elemColBeam]] 1 2 3
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeBeamRight [expr $i*($elemColBeam+1)]] 1 2 3
	equalDOF [lindex $nodeColRight [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeBeamRight [expr $i*($elemColBeam+1)+$elemColBeam]] 1 2 3
}
# ----- Floor Diaphragms
for {set i 0} {$i<$numberStories} {incr i} {
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$elemColBeam]] 1; # Left bay
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeColRight [expr $i*($elemColBeam+1)+$elemColBeam]] 1; # Right bay
	equalDOF [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [lindex $nodeLeaningFrame [expr $i+1]] 1; # Conection to leaning frame
}

# -------------------------
# Display
# -------------------------
if {[info exists display_Analysis] && $display_Analysis} {
	recorder display "SismicAnlysis" 1280 0 1280 1440 -wipe
	prp 6000 10000 1 
	vup 0 1 0 
	vpn 0 0 1 
	display 1 1 5
}

# -------------------------
# Apply masses
# -------------------------
for {set i 0} {$i<$numberStories} {incr i} {
	mass [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] [expr [lindex $weight $i]/$Gravity] $NumberSmall $NumberSmall; # Use of small numbers to avoid errors
}

# -------------------------
# Calculate Periods
# -------------------------
constraints Plain
system UmfPack
set omegaList [calculateModeFrequencies [expr {[info exists totalModes] ? $totalModes : ""}]]
if {[info exists displayModes]} {
	displayModePeriods $omegaList $displayModes
}
if {[info exists stop_at_Modes] && $stop_at_Modes} {
	modalProperties -print -file "${dirMultiStoryModel}/ModalReport.txt" -unorm
    error ""
}

# -------------------------
# Rayleigh Damping
# -------------------------
set damping [expr {[info exists damping] ? $damping : 0.03}]; # equivalent damping ratio
set omega1 [lindex $omegaList 0]
set omega2 [lindex $omegaList 1]
rayleigh [expr $damping*2*$omega1*$omega2/($omega1+$omega2)] 0.0 [expr $damping*2/($omega1+$omega2)] 0.0; # In models with distributed plasticity, response is not affected due to spurious damping forces related to Rayleigh Damping (Chopra & McKenna, 2015)

# -------------------------
# Apply gravitational loads
# -------------------------
pattern Plain 1 Linear {
	for {set i 0} {$i<$numberStories} {incr i} {
		# -----Point loads on SFRS
		load [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$elemColBeam]] 0.0 [expr [lindex $columnloadsend $i]*-1.0] 0.0;
		load [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]] 0.0 [expr [lindex $columnloadscenter $i]*-1.0] 0.0;
		load [lindex $nodeColRight [expr $i*($elemColBeam+1)+$elemColBeam]] 0.0 [expr [lindex $columnloadsend $i]*-1.0] 0.0;
		# -----Point loads on leaning columns
		load [lindex $nodeLeaningFrame [expr $i+1]] 0.0 [expr [lindex $leaningframeloads $i]*-1.0] 0.0;
		# -----Element loads on beams
		for {set j 0} {$j<$elemColBeam} {incr j} {
			eleLoad -ele [lindex $elemBeamLeft [expr $i*$elemColBeam+$j]] [lindex $elemBeamRight [expr $i*$elemColBeam+$j]] -type -beamUniform [expr [lindex $beamloads $i]*-1.0];
		}
	}
}