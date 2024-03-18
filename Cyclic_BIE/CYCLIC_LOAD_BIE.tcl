####################################################################################################
##
##      CYCLIC_LOAD_BIE.tcl -- construct BIE models and run cyclic test of W-Shaped Brace with Intentional Eccentricity -- Out-of-Plane Bending Gusset Plate and Side-Plated Connection
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

model Basic Builder -ndm 2 -ndf 3
set pi 3.14159265359;

# -------------------------
# Material Definition
# -------------------------
set Fy 0.345; # Yield stress for brace
set Fyg 0.345; # Yield stress for plates 
set E0 200; # Elasticity Modulus
set b [expr (0.1*$Fy/0.04)/$E0]; # Strain Hardening ratio
set R0 30.0; # Parameter that controls transition form elastic to plastic branches, recommended value between 10 and 20. Value of 30 is used as recommended by Prof. Tremblay.
set CR1 0.925; # Parameter that controls transition form elastic to plastic branches, recommended value 0.925
set CR2 0.15; # Parameter that controls transition form elastic to plastic branches, recommended value 0.15
set a1 0.4; # isotropic hardening parameter, increase of compression yield envelope as proportion of yield strength after a plastic strain of $a2*($Fy/E0); value recommended by Prof. Tremblay
set a2 22.0; # isotropic hardening parameter; value recommended by Prof. Tremblay
set a3 0.4; # isotropic hardening parameter, increase of tension yield envelope as proportion of yield strength after a plastic strain of $a4*($Fy/E0); value recommended by Prof. Tremblay
set a4 22.0; # isotropic hardening parameter; value recommended by Prof. Tremblay
uniaxialMaterial Steel02 1 $Fy $E0 $b $R0 $CR1 $CR2 $a1 $a2 $a3 $a4; # Brace steel
uniaxialMaterial Steel02 2 $Fyg $E0 $b $R0 $CR1 $CR2 $a1 $a2 $a3 $a4; # Assembly steel

# -------------------------
# Sections Definition
# -------------------------
set ns 21; #number of fibers along edges of W
set nc 15; #number of fibers along round fillets of HSS
set nt 1; #number of fibers across thickness of W
set ng 34; #number of fibers across thickness of plates 
set nb 1; #number of fibers along plates width

section fiberSec 1 {
    # Web definition
    patch quad 1 $ns $nt [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf] [expr -$tw/2] [expr $d/2-$tf]
    # Bottom Flange definition
    patch quad 1 $ns $nt [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf] [expr -$bf/2] [expr -$d/2+$tf]
    # Top Flange definition
    patch quad 1 $ns $nt [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2] [expr -$bf/2] [expr $d/2]
}

section fiberSec 2 {
	# Knife Plate definition
	patch rect 2 $ng $nb [expr -$tg/2] [expr -$bg/2] [expr $tg/2] [expr $bg/2]
}

section fiberSec 3 {
	# Knife Plate definition
	patch rect 2 $ng $nb [expr -$e-$tg/2] [expr -$bg/2] [expr -$e+$tg/2] [expr $bg/2]
	# Bottom Side Plate definition
	patch rect 2 $nb $ng [expr -$e+$tg/2] [expr -$d/2-$ts] [expr -$e+$tg/2+$Hs] [expr -$d/2]
	# Top Side Plate definition
	patch rect 2 $nb $ng [expr -$e+$tg/2] [expr $d/2] [expr -$e+$tg/2+$Hs] [expr $d/2+$ts]
    # Web definition
    patch quad 1 $ns $nt [expr -$tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr -$d/2+$tf] [expr $tw/2] [expr $d/2-$tf] [expr -$tw/2] [expr $d/2-$tf]
    # Bottom Flange definition
    patch quad 1 $ns $nt [expr -$bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2] [expr $bf/2] [expr -$d/2+$tf] [expr -$bf/2] [expr -$d/2+$tf]
    # Top Flange definition
    patch quad 1 $ns $nt [expr -$bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2-$tf] [expr $bf/2] [expr $d/2] [expr -$bf/2] [expr $d/2]
}

# -------------------------
# Geometric Transformation
# -------------------------
geomTransf Corotational 1

# -------------------------
# Nodes and elements definition
# -------------------------
set elb 72; #number of elements along brace, use even number
set elg 12; #number of elements along free gusset, use even number
set elp 2; #number of elements along plated connection, use even number
set ip 7; #number of integration points along elements

# Nodes
node 1 0 0
for {set i 1 } { $i <= [expr $elg] } {incr i } {
node [expr $i+1] [expr $i*$Lg/$elg] 0
}
node [expr $elg+2] [expr $Lg] $e
for {set i 1 } { $i <= [expr $elp] } {incr i } {
node [expr $elg+2+$i] [expr $i*$Lp/$elp+$Lg] $e
}
for {set i 1 } { $i <= [expr $elb] } {incr i } {
node [expr 2+$elg+$elp+$i] [expr $Lg+$Lp+$i*$Lb/$elb] [expr $e+sin($pi*$i/$elb)*$imp*$Lb]
}
for {set i 1 } { $i <= [expr $elp] } {incr i } {
node [expr $elg+$elp+$elb+2+$i] [expr $i*$Lp/$elp+$Lg+$Lp+$Lb] $e
}
node [expr $elg+$elp+$elb+$elp+3] [expr $Lg+$Lp+$Lb+$Lp] 0
for {set i 1 } { $i <= [expr $elg] } {incr i } {
node [expr $elg+$elp+$elb+$elp+3+$i] [expr ($i)*$Lg/$elg+$Lg+$Lp+$Lb+$Lp] 0
}
fix 1 0 1 1; #moveable in x for applying displacement
fix [expr 2*($elp+$elg)+$elb+3] 1 1 1; #encastrement

# Elements
for {set i 1 } { $i <= $elg} {incr i } {
element forceBeamColumn [expr $i] [expr $i] [expr $i+1] 1 Lobatto 2 $ip
}
rigidLink beam [expr $elg+1] [expr $elg+2]
for {set i 1 } { $i <= $elp } {incr i } {
element forceBeamColumn [expr $elg+$i] [expr $elg+1+$i] [expr $elg+2+$i] 1 Lobatto 3 $ip
}
for {set i 1 } { $i <= $elb } {incr i } {
element forceBeamColumn [expr $elg+$elp+$i] [expr $elg+$elp+1+$i] [expr $elg+$elp+2+$i] 1 Lobatto 1 $ip
}
for {set i 1 } { $i <= $elp } {incr i } {
element forceBeamColumn [expr $elg+$elp+$elb+$i] [expr $elg+$elp+$elb+1+$i] [expr $elg+$elp+$elb+2+$i] 1 Lobatto 3 $ip
}
rigidLink beam [expr $elg+$elp+$elb+$elp+2] [expr $elg+$elp+$elb+$elp+3]
for {set i 1 } { $i <= $elg } {incr i } {
element forceBeamColumn [expr $elg+$elp+$elb+$elp+$i] [expr $elg+$elp+$elb+$elp+2+$i] [expr $elg+$elp+$elb+$elp+3+$i] 1 Lobatto 2 $ip
}
pattern Plain [expr 1] Linear {load 1 1.0 0.0 0.0}

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