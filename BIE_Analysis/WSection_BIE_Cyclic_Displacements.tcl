####################################################################################################
##
##      WSection_BIE_Cyclic_Displacements.tcl -- displacements for sinusoidal cyclic analysis (dU list calculator)
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

# -------------------------
# Set drifts list
# -------------------------
set driftDefaults [list 0.1 0.25 0.5 0.75 1.0 1.5 2.0 3.0 5.0 10.0 15.0 20.0]; # Fixed story driftList percentajes
set maxdrift [expr {(sqrt(pow(($disp + sqrt(pow($StoryHeight,2)+pow($BayWidth,2))),2) - pow($StoryHeight,2)) - $BayWidth)*100/$StoryHeight}]
set driftList [list]
# Set drifts: list of driftList below the max assigned displacement
for {set i 0} {$i < [llength $driftDefaults]} {incr i} {
	set drift_i [lindex $driftDefaults $i]
	if {$drift_i < $maxdrift} {
		lset driftList [expr {$i}] [expr {$drift_i}]
	}
}

# -------------------------
# Calculate displacement path (as many cycles as list of drifts)
# -------------------------
set pi 3.14159265359
set steps 2000; # Multiplier for steps in each load cycle, must be >20, INCREASE IF CONVERGE ERRORS ARE ENCOUNTERED
set start 0
set dUlist [list]
for {set i 0} {$i < [llength $driftList]} {incr i} {
    set drift_i [lindex $driftList $i]
    set cycle [list]
    for {set j 1} {$j <= $steps*$drift_i} {incr j} {
        lappend cycle [expr {$j * 2*$pi/$steps}]
    }
    set finish [expr {$start + [llength $cycle] - 1}]
    for {set j $start} {$j <= $finish} {incr j} {
        set cycle_j [lindex $cycle [expr {$j - $start}]]
		set drift_j [expr {sin($cycle_j / $drift_i)*$drift_i}]
        lset dUlist [expr {$j}] [expr {sqrt(pow($StoryHeight,2)+pow(($BayWidth+$drift_j*$StoryHeight/100),2)) - sqrt(pow($StoryHeight,2)+pow($BayWidth,2))}]
    }
    set start [expr {$finish + 1}]
}

# -------------------------
# Write a resulting drifts in an individual file
# -------------------------
# # Open the file for writing
# set fileId [open "dUlist(OpenSees).dat" w]
# # Write the dUlist list to the file
# foreach y $dUlist {
    # puts $fileId $y
# }
# # Close the file
# close $fileId