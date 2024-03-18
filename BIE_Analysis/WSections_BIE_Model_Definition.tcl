####################################################################################################
##
##      WSections_BIE_Model_Definition.tcl -- construct BIE models of W-Shaped Brace with Intentional Eccentricity -- Out-of-Plane Bending Gusset Plate and Side-Plated Connection
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

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