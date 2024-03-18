####################################################################################################
##
##      Chain_BIE_Monotonic_Analysis.tcl -- queue multiple monotonic analysis
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

# -------------------------
# Directory of Results
# -------------------------
set directory "design properties"
file mkdir $directory; # directory where results are saved

# -------------------------
# Chain analysis run: first sets values of section geometry
# -------------------------
# Comment the start of the for loop and uncomment the other to switch between running all tests in a single window and running specific tests in parallalel windows
#for {set m 0 } {$m <= [expr [llength $dlist]-1]} {incr m} {
for {set m $i } {$m <= $f} {incr m} {
    # Sets all the geometry values before calling the analysis
    set name [lindex $namelist $m]
    set d [expr ([lindex $dlist $m])]
    set bf [expr ([lindex $bflist $m])]
    set tf [expr ([lindex $tflist $m])]
    set tw [expr ([lindex $twlist $m])]
    set Lp [expr ([lindex $Lplist $m])]
    set ts [expr ([lindex $tslist $m])]
    set Hs [expr ([lindex $Hslist $m])]
    set bg [expr ([lindex $bglist $m])]
    set tg [expr ([lindex $tglist $m])]
    set Lg [expr ([lindex $Lglist $m])]
    set disp [expr ([lindex $displist $m])]
    set Lb [expr $L-2*$Lp]; # Brace length
    # Sets number of analyses to be done with each section (different eccentricities)
    set num [expr (([lindex $emaxlist $m])-([lindex $eminlist $m]))/10+1]
    for {set n 0 } {$n <= [expr $num-1]} {incr n} {
        set e [expr ([lindex $eminlist $m])+10*$n]; # Sets value of eccentricity before calling the analysis
        source WSections_BIE_Model_Definition.tcl; # Construct model
        # --- Tension analysis ---
        set nameT $name-$e-Tension
        puts $nameT
        set direction 1
        source WSection_BIE_Monotonic_Load.tcl
        # --- Compression analyses ---
        set nameC $name-$e-Compression
        puts $nameC
        set direction -1
        source WSection_BIE_Monotonic_Load.tcl
        wipe
    }
}
wipe