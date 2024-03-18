####################################################################################################
##
##      WSection_BIE_Monotonic_Load.tcl -- monotonic test of W-Shaped Brace with Intentional Eccentricity
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

# -------------------------
# Recorders
# -------------------------
# Global Response Recorder
recorder Node -file [format "$directory/$nameT.dat"] -node [expr $elg+$elp+$elb+$elp+$elg+3] -dof 1 reaction 
system UmfPack
numberer RCM
constraints Transformation
integrator LoadControl 1 1 1 1
test EnergyIncr 1.0e-3 30 0
algorithm Newton
analysis Static

# -------------------------
# Loading Protocol - monotonic -
# -------------------------
set peaks [ list 0.0 -$disp*$direction]; #negative produces tension
for {set i 1 } { $i <= 1 } {incr i } {
set dU [expr ([lindex $peaks $i ]-[lindex $peaks [expr $i-1]])/$disp ]
integrator DisplacementControl 1 1 $dU 1 $dU $dU
analyze $disp
}
wipe