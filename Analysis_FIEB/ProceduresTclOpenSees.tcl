####################################################################################################
##
##      ProceduresTclOpenSees.tcl -- misc procedures for Tcl OpenSees
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

# accumulateList				return list of accumulated values of list 
# formatTime					return string with time (hh:mm:ss.mil)
# calculateModeFrequencies		returns frequencies from vibration modes
# displayModePeriods			prints periods of vibration modes
# checkListsLengths				checks lists lenghts and negative values

proc accumulateList {valueList {zeroStart false}} {
    set List [list]
    set sum 0.0
    if {$zeroStart} {
        lappend List $sum
    }
    foreach value $valueList {
        set sum [expr {$sum + $value}]
        lappend List $sum
    }
    return $List
}

proc formatTime {time_in_milliseconds} {
    set time_in_milliseconds [expr {int($time_in_milliseconds)}]
    set hours [expr {$time_in_milliseconds / 3600000}]
    set minutes [expr {($time_in_milliseconds % 3600000) / 60000}]
    set seconds [expr {($time_in_milliseconds % 60000) / 1000}]
    set milliseconds [expr {$time_in_milliseconds % 1000}]
    return [format "%02d:%02d:%02d.%03d" $hours $minutes $seconds $milliseconds]
}

proc calculateModeFrequencies {{totalModes 2}} {
	if {$totalModes<2} {
		puts "Warning: The number of total vibrational modes must be at least 2, number corrected..."
		set totalModes 2
	}
	set eigenList [eigen $totalModes]; # 'ArpackSolver::Error with _saupd info = -9999' probably means totalModes too high
	set omegaList [list]
	foreach eigen $eigenList {
		lappend omegaList [expr pow($eigen,0.5)]; # frequency
	} 
	return $omegaList
}

proc displayModePeriods {omegaList {displayModes ""}} {
	set totalModes [llength $omegaList]
	puts "\n---------- Vibrational Modes Periods ----------"
	if {$displayModes eq ""} {
		set displayModes $totalModes
	} elseif {$displayModes>$totalModes || $displayModes<0} {
		puts "Warning: The number of displayed vibrational modes must be between zero and the total amount, all displayed..."
		set displayModes $totalModes
	}
	for {set i 0} {$i<$displayModes} {incr i} {
		set period [expr 2*$::PI/[lindex $omegaList $i]]
		puts "\nMode [expr $i+1] / $totalModes = [format %.6f ${period}] s"
	}
}

proc checkListsLengths {expectedLength list_of_lists} {
    set allLengthCorrect 1
    foreach list $list_of_lists {
        upvar #0 $list g_$list; # Declare each list in list_of_lists as a global variable
        set g_list [set g_$list]; # Access the global variable for this list
        if {[llength $g_list] < $expectedLength} {
            puts "Missing: $list should be length $expectedLength"
            set allLengthCorrect 0
        } elseif {[llength $g_list] > $expectedLength} {
            puts "Warning: $list has more values than $expectedLength"
        }
        set anyNegativeValue 0
        foreach value $g_list {
            if {$value<0} {
                set anyNegativeValue 1
            }
        }
        if {$anyNegativeValue} {
            puts "Warning: $list contains negatives values"
        }
    }
    return $allLengthCorrect
}

proc appendListValues {firstList {secondList ""}} {
    if {$secondList eq ""} {
        set secondList [list ""]
    }
    set resultList [list]
    for {set i 0} {$i<[llength $firstList]} {incr i} {
        for {set j 0} {$j<[llength $secondList]} {incr j} {
            lappend resultList [lindex $firstList $i][lindex $secondList $j]
        }
    }
    return $resultList
}

proc repeatListValues {singleList {repeats ""}} {
    if {$repeats eq ""} {
        set repeats [list ""]
    }
    set multipleList [list]
    for {set i 0} {$i<[llength $singleList]} {incr i} {
        for {set j 0} {$j<[llength $repeats]} {incr j} {
            lappend multipleList [lindex $singleList $i]
        }
    }
    return $multipleList
}

proc displayAnalysisProgress {controlTime timeStep duration {starting_time 0}} {
    # Get global variables (set if not already initialized)
    global recent_times; # smoothed_rate
    set recent_times [expr {[info exists recent_times] ? $recent_times : {}}]
    # set smoothed_rate [expr {[info exists smoothed_rate] ? $smoothed_rate : 0.0}]
    # Maintain a circular buffer for recent times
    set current_time [clock clicks -milliseconds]
    lappend recent_times $current_time
    set circularBuffer 20;  # Adjust as needed
    if {[llength $recent_times] > $circularBuffer} {
        set recent_times [lreplace $recent_times 0 0]
    }
    # Calculate rate incrementally during each time step
    set recent_rate_of_progress [expr {($timeStep * $circularBuffer) / ($current_time - [lindex $recent_times 0])}]
    # # Exponential Moving Average (EMA) for remaining time estimation
    # set alphaEMA 0.1;  # Adjust as needed
    # set smoothed_rate [expr {$alphaEMA * $recent_rate_of_progress + (1 - $alphaEMA) * $smoothed_rate}]
    # set remaining_time [expr {($duration - $controlTime) / max(1e-6, $smoothed_rate)}]
    # Prints
    set progress [expr {$controlTime / $duration * 100}]
    set elapsed_time [expr {$current_time - $starting_time}]
    set remaining_time [expr {($duration - $controlTime) / max(1e-6, $recent_rate_of_progress)}]
    puts -nonewline "Progress: [format %06.3f $progress] % | "
    puts -nonewline "Elapsed time: [formatTime $elapsed_time] | "
    puts "Remaining time: [formatTime $remaining_time]\n"
}