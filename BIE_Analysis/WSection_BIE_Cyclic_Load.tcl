####################################################################################################
##
##      WSection_BIE_Cyclic_Load.tcl -- cyclic test of W-Shaped Brace with Intentional Eccentricity
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
if {$n == 0} {
	recorder Node -file [format "$directory/$nameT-disp.dat"] -node 1 -dof 1 disp
}
recorder Node -file [format "$directory/$nameT-force.dat"] -node [expr $elg+$elp+$elb+$elp+$elg+3] -dof 1 reaction 
system UmfPack
numberer RCM
constraints Transformation
integrator LoadControl 1 1 1 1
test EnergyIncr 1.0e-3 30 0
algorithm Newton
analysis Static

# -------------------------
# Loading Protocol - cyclic -
# -------------------------
set dUi 0.0
for {set i 0} {$i < [llength $dUlist]} {incr i} {
    set dUf [expr ([lindex $dUlist $i])]
    set dU [expr ($dUi-$dUf)*$direction]; # Negative for tension start, if direction 1=Tension / -1=Compression
    integrator DisplacementControl 1 1 $dU 1 $dU $dU
    analyze 1
    set dUi $dUf
}
wipe