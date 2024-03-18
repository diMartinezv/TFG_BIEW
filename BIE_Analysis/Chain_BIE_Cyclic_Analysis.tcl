####################################################################################################
##
##      Chain_BIE_Cyclic_Analysis.tcl -- queue multiple cyclic analysis
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

# -------------------------
# Directory of Results
# -------------------------
set directory "cyclic"; # directory where results are saved
file mkdir $directory

# -------------------------
# Studied sections (since cyclic analysis is very demanding it isn't recommended all sections at once)
# -------------------------
set slist [list 28 32 182 217 279]

# -------------------------
# Chain analysis run: first sets values of section geometry
# -------------------------
# Comment for loops (m and/or n) to set specific analysis
for {set m 0 } {$m <= [expr [llength $slist]]} {incr m} {
    # Sets all the geometry values before calling the analysis
    set s [expr ([lindex $slist $m])]
    set name [lindex $namelist $s]
    set d [expr ([lindex $dlist $s])]
    set bf [expr ([lindex $bflist $s])]
    set tf [expr ([lindex $tflist $s])]
    set tw [expr ([lindex $twlist $s])]
    set Lp [expr ([lindex $Lplist $s])]
    set ts [expr ([lindex $tslist $s])]
    set Hs [expr ([lindex $Hslist $s])]
    set bg [expr ([lindex $bglist $s])]
    set tg [expr ([lindex $tglist $s])]
    set Lg [expr ([lindex $Lglist $s])]
    set disp [expr ([lindex $displist $s])]
    set Lb [expr $L-2*$Lp]
    set emin [expr ([lindex $eminlist $s])]
    set emax [expr ([lindex $emaxlist $s])]
    source WSection_BIE_Cyclic_Displacements.tcl; # Displacement path for cycle load
    # Sets number of analyses to be done with each section (different eccentricities)
    for {set n 0 } {$n <= 2} {incr n} {; # Only the max, avg, and min eccentricities are tested, change to account for more variations
        set e [expr $emin + $n*($emax - $emin)/2]; # Sets value of eccentricity before calling the analysis
        source WSections_BIE_Model_Definition.tcl; # Construct model
        # --- Tension start test ---
        set nameT $name-$e-Cyclic-Tension
        puts $nameT
        set direction 1
        source WSection_BIE_Cyclic_Load.tcl
        # --- Compression start test ---
        set nameC $name-$e-Cyclic-Compression
        puts $nameC
        set direction -1;
        source WSection_BIE_Cyclic_Load.tcl
        wipe
    }
}
wipe