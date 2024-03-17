####################################################################################################
##
##      FIEB_Sismic_Analysis.tcl -- 2D Multi-Story FIEB Sismic Analysis
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##      Story configuration
##          ...|/|\|...
##
##		Options:
##		"safe_Results" - safe results with recorders [1/0]. Defaults to true
##		"stop_at_Analysis" - stops process before running analysis (to test time to start) [1/0]. Defaults to false
##		"detailedProgress" - show progress every n dt steps in duration [#]. Comment to not display 
##
####################################################################################################

# -------------------------
# Analysis 
# -------------------------
# ------- Analysis parameters -------
puts "\n---------- ----------\n"
test EnergyIncr 1.0e-8 30
algorithm Newton
integrator LoadControl 0.01
analysis Static
analyze 100
loadConst -time 0.0
if {![info exists safe_Results] || $safe_Results} {
	file mkdir $dirResults; # creates a folder where the results will be placed
	# ------- Base Reaction Recorders -------
	recorder Node -file [format ${dirResults}/0-basereaction.dat] -time -node [lindex $nodeLeaningFrame 0] [lindex $nodeColLeft 0] [lindex $nodeColCenter 0] [lindex $nodeColRight 0] -dof 1 2 reaction
	# ------- Story Displacement Recorders -------
	# ----- Node recorder -----
	set nodeRecorderColLeft [list [lindex $nodeColLeft 0]]; # Left column base
	set nodeRecorderColCenter [list [lindex $nodeColCenter 0]]; # Center column base
	set nodeRecorderColRight [list [lindex $nodeColRight 0]]; # Right column base
	for {set i 0} {$i<$numberStories} {incr i} {
		lappend nodeRecorderColLeft [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$elemColBeam]]; # Left column tops
		lappend nodeRecorderColCenter [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$elemColBeam]]; # Center column tops
		lappend nodeRecorderColRight [lindex $nodeColRight [expr $i*($elemColBeam+1)+$elemColBeam]]; # Right column tops
	}
	eval recorder Node -file [format ${dirResults}/0-column-left-displacements.dat] -time -node $nodeRecorderColLeft -dof 1 2 disp
	eval recorder Node -file [format ${dirResults}/0-column-center-displacements.dat] -time -node $nodeRecorderColCenter -dof 1 2 disp
	eval recorder Node -file [format ${dirResults}/0-column-right-displacements.dat] -time -node $nodeRecorderColRight -dof 1 2 disp
	set nodeRecorder [lreverse [concat $nodeRecorderColLeft $nodeRecorderColCenter $nodeRecorderColRight]]; # Top to bottom column nodes
	eval recorder Node -file [format ${dirResults}/0-bracedisplacements.dat] -time -node $nodeRecorder -dof 1 2 disp
	# ----- Drift recorder -----
	set idriftRecorder [lreverse [lrange $nodeRecorderColCenter 1 end]]; # all except base node
	set jdriftRecorder [lreverse [lrange $nodeRecorderColCenter 0 end-1]]; # all except very top node
	eval recorder Drift -file [format ${dirResults}/0-allstorysdrift.dat] -time -iNode $idriftRecorder -jNode $jdriftRecorder -dof 1 -perpDirn 2
	# ----- Braces Forces Recorders (global and local axes) -----
	for {set i 0} {$i<$numberStories} {incr i} {
		# Left bay
		recorder Element -file [format ${dirResults}/[expr $i+1]-story-braces-left-global.dat] -time -ele [lindex $elemBraceLeft [expr $i*$elemBrace]] globalForce;
		recorder Element -file [format ${dirResults}/[expr $i+1]-story-braces-left-local.dat] -time -ele [lindex $elemBraceLeft [expr $i*$elemBrace]] localForce;
		# Right bay
		recorder Element -file [format ${dirResults}/[expr $i+1]-story-braces-right-global.dat] -time -ele [lindex $elemBraceRight [expr $i*$elemBrace]] globalForce;
		recorder Element -file [format ${dirResults}/[expr $i+1]-story-braces-right-local.dat] -time -ele [lindex $elemBraceRight [expr $i*$elemBrace]] localForce;
	}
	# ----- Columns Forces Recorders (global and local axes) -----
	for {set i 0} {$i<$numberStories} {incr i} {
		set forceRecorderColLeft [list]
		set forceRecorderColCenter [list]
		set forceRecorderColRight [list]
		for {set j 0} {$j < $elemColBeam} {incr j} {
			lappend forceRecorderColLeft [lindex $elemColLeft [expr $i*$elemColBeam+$j]]; # Append the left column elements to "left column recorder"
			lappend forceRecorderColCenter [lindex $elemColCenter [expr $i*$elemColBeam+$j]]; # Append the center column elements to "center column recorder"
			lappend forceRecorderColRight [lindex $elemColRight [expr $i*$elemColBeam+$j]]; # Append the right column elements to "right column recorder"
		}
		# Left column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-left-global.dat] -time -ele $forceRecorderColLeft globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-left-local.dat] -time -ele $forceRecorderColLeft localForce;
		# Center column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-center-global.dat] -time -ele $forceRecorderColCenter globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-center-local.dat] -time -ele $forceRecorderColCenter localForce;
		# Right column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-right-global.dat] -time -ele $forceRecorderColRight globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-column-right-local.dat] -time -ele $forceRecorderColRight localForce;
	}
	for {set i 0} {$i<$numberStories} {incr i} {
		set forceRecorderColLeft [list]
		set forceRecorderColCenter [list]
		set forceRecorderColRight [list]
		for {set j 0} {$j < $elemColBeam} {incr j} {
			lappend forceRecorderColLeft [lindex $nodeColLeft [expr $i*($elemColBeam+1)+$j]]; # Append the left column nodes to "left column recorder"
			lappend forceRecorderColCenter [lindex $nodeColCenter [expr $i*($elemColBeam+1)+$j]]; # Append the center column nodes to "center column recorder"
			lappend forceRecorderColRight [lindex $nodeColRight [expr $i*($elemColBeam+1)+$j]]; # Append the right column nodes to "right column recorder"
		}
		# Left column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-leftcolumn-global.dat] -time -ele $forceRecorderColLeft globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-leftcolumn-local.dat] -time -ele $forceRecorderColLeft localForce;
		# Center column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-centercolumn-global.dat] -time -ele $forceRecorderColCenter globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-centercolumn-local.dat] -time -ele $forceRecorderColCenter localForce;
		# Right column
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-rightcolumn-global.dat] -time -ele $forceRecorderColRight globalForce;
		eval recorder Element -file [format ${dirResults}/[expr $i+1]-story-rightcolumn-local.dat] -time -ele $forceRecorderColRight localForce;
	}
}
# ----- Time series parameters -----
puts ""
set timeSeriesTag 1
timeSeries Path $timeSeriesTag -dt $timeStep -filePath "${dirRecord}${record}${extAccelerograms}" -factor [expr $Gravity*1.2*$scale]; # 1.2 factor to account for accidental eccentricity 
pattern UniformExcitation 3 1 -accel 1
set tol 0.001
set maxNumIter 50
numberer RCM
system UmfPack
constraints Plain
test EnergyIncr $tol $maxNumIter
algorithm NewtonLineSearch 0.8
integrator Newmark 0.5 0.25
analysis Transient
# ----- Analysis execution -----
set dt0 [expr $timeStep/ 2.0]
set analysisStep 50.0; # Number of steps to divide $NTINCR
set starting_time [clock clicks -milliseconds]; # Start timer to check progress
puts "\n-------------------- Analysis (time taken: [formatTime [expr {$starting_time-$initial_time}]]) --------------------\n"
if {[info exists stop_at_Analysis] && $stop_at_Analysis} {
    error ""
}
set detailedProgress [expr {[info exists detailedProgress] ? max($detailedProgress, 0) : 0}]; # Ensure that detailedProgress has a value of 0
for {set i 1} {$i <= $analysisStep} {incr i} {
	set counterProgress 0
	set ok 0
	set controlTime [getTime]
	while {$controlTime < [expr $i / $analysisStep * $duration] && $ok == 0} {
		set controlTime [getTime]
		set ok [analyze 1 $dt0]
		if {$ok != 0} {
			set dt1 [expr $dt0 / 2.]
			puts "Fail to converge @ $controlTime s, trying 2x smaller time timeStep $dt1 s\n"
			set ok [analyze 1 $dt1]
			if {$ok == 0} {
				puts "It converged! Back to a time timeStep of $dt0 s\n"
			}
		}
		if {$ok != 0} {
			set dt2 [expr $dt0 / 5.]
			puts "Fail to converge @ $controlTime s, trying 5x smaller time timeStep $dt2 s\n"
			set ok [analyze 1 $dt2]
			if {$ok == 0} {
				puts "It converged! Back to a time timeStep of $dt0 s\n"
			}
		}
		if {$ok != 0} {
			set dt3 [expr $dt0 / 10.]
			puts "Fail to converge @ $controlTime s, trying 10x smaller time timeStep $dt3 s\n"
			set ok [analyze 1 $dt3]
			if {$ok == 0} {
				puts "It converged! Back to a time timeStep of $dt0 s\n"
			}
		}
		if {$ok != 0} {
			set dt4 [expr $dt0 / 20.]
			puts "Fail to converge @ $controlTime s, trying 20x smaller time timeStep $dt4 s\n"
			set ok [analyze 1 $dt4]
			if {$ok == 0} {
				puts "It converged! Back to a time timeStep of $dt0 s\n"
			}
		}	
		if {$ok != 0} {
			set dt5 [expr $dt0 / 50.]
			puts "Fail to converge @ $controlTime s, trying 50x smaller time timeStep $dt5 s\n"
			set ok [analyze 1 $dt5]
			if {$ok == 0} {
				puts "It converged! Back to a time timeStep of $dt0 s\n"
			}
		}
		# ----- Detailed progress and time remaining -----
		if {$detailedProgress != 0 && $counterProgress % $detailedProgress == 0} {
			displayAnalysisProgress $controlTime $timeStep $duration $starting_time
		}
		incr counterProgress
	}
	if {$ok != 0} {
		set controlTime [getTime]
		puts "Analysis Stopped @ $controlTime s"
		puts "Record duration is $duration s\n"
		puts "Dynamic analysis FAILED\n"
		return -1
	} else {
		puts "-------------------------- Step: [format "%02d" $i] / [expr {int($analysisStep)}] completed --------------------------\n"
	}
}
# ----- Check completion -----
set controlTime [getTime]
if {$controlTime >= $duration } {
	puts "Dynamic Analysis for $record Completed SUCCESSFULLY\n"
}
# ----- Set time to zero and wipe analysis -----
loadConst -time 0.0
puts " *-* *-* *-* *-* *-* *-* Dynamic Analysis is Done! *-* *-* *-* *-* *-* *-* \n"