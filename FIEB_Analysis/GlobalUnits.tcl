####################################################################################################
##
##      GlobalUnits.tcl -- shared units in the metric system
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
####################################################################################################

set PI [expr 2*asin(1.0)];						# ratio of a circle's circumference to its diameter []
set Gravity 9806.55;							# gravitational acceleration [mm/s^2]
set NumberBig 1.e10; 							# really large number []
set NumberSmall [expr 1/$NumberBig];			# really small number []
set SteelE 200.0; 								# Steel Young's modulus [kN/mm^2]
set Steelnu 0.3; 								# Steel Poisson's ratio [mm/mm]
set SteelG [expr $SteelE/(2*(1+$Steelnu))]; 	# Steel Shear modulus [kN/mm^2]

# Tensile: yield strength [kN/mm^2], ultimate strength [kN/mm^2], and yield ratio (expected yield stress/minimum specified value) []
# ASTM A36 steel:
set FyA36 0.250;
set FuA36 0.400;
set RyA36 1.5;
# ASTM A572 Grade 42 steel:
set FyA572G42 0.290;
set FuA572G42 0.415;
set RyA572G42 1.3;
# ASTM A572 Grade 50 steel:
set FyA572G50 0.345;
set FuA572G50 0.450;
set RyA572G50 1.1;
# ASTM A572 Grade 55 steel:
set FyA572G55 0.380;
set FuA572G55 0.485;
set RyA572G55 1.1;
# ASTM A572 Grade 60 steel:
set FyA572G60 0.415;
set FuA572G60 0.520;
set RyA572G60 1.1; # (?)
# ASTM A572 Grade 65 steel:
set FyA572G65 0.450;
set FuA572G65 0.550;
set RyA572G65 1.1; # (?)
# ASTM A500 Grade A steel:
set FyA500GA 0.270;
set FuA500GA 0.310;
set RyA500GA 1.4; # (?)
# ASTM A500 Grade B steel:
set FyA500GB 0.315;
set FuA500GB 0.400;
set RyA500GB 1.4;
# ASTM A500 Grade C steel:
set FyA500GC 0.345;
set FuA500GC 0.425;
set RyA500GC 1.4;
# ASTM A500 Grade D steel:
set FyA500GD 0.250;
set FuA500GD 0.400;
set RyA500GD 1.4; # (?)
# ASTM A992 steel (Typical of W-Sections):
set FyA992 0.345;
set FuA992 0.450;
set RyA992 1.1;
# ASTM A1085 steel (Typical of HSS-RoundSections):
set FyA1085 0.345;
set FuA1085 0.450;
set RyA1085 1.25;
