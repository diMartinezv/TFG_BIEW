####################################################################################################
##
##      4Story_WSection_Model_Arguments.tcl -- arguments for model construction
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##      Story configuration
##          ...|/|\|...
##
##		Example left for 4 Story Model, can be changed to any number of stories n, with each list containing the n number of entries
##
####################################################################################################

wipe all
setMaxOpenFiles 2048
model Basic Builder -ndm 2 -ndf 3;

# -------------------------
# General Frame Information
# -------------------------
set braceSection "W"; # Only possibilities "W" or "HSS"
set numberStories 4; # Number of stories
set L 9000.0; # Width of bay
set H [list]; # Story height
for {set i 0} {$i<$numberStories} {incr i} {
	lappend H [expr 4500.0]
}
set imperfection 0.001; # out-of-plane imperfection of members (braces, beams, and columns), fraction of length (max. deflection at mid-point)
set damping 0.03; # equivalent damping ratio
set integrationPoints 7; # number of integration points in each forceBeamColumn element
set elemColBeam 8; # number of elements per column/beam
set elemBrace 8; # number of elements per brace
set elemKnife 2; # number of elements per hinging knife plate

# -------------------------
# Weight and gravity loads (Load Combination: 1.05CP + 0.5CT + CS)
# -------------------------
# Story Seismic Weights in kN from bottom to top story:
set weight [list 3036.60140625 3036.60140625 3036.60140625 1460.93625];
# Point loads on end columns in kN, from bottom to top (tributary area is supposed equal on exterior and interior columns, loads are such that combined with the beam loads and leaning frame loads produce same amount as factored gravity load as considered in design):
set columnloadsend [list 194.867702678571 194.867702678571 194.867702678571 85.5691232142857];
# Point loads on center columns in kN, from bottom to top:
set columnloadscenter [list 0 0 0 0];
# Distributed gravity loads on beams in kN/mm, from bottom to top:
set beamloads [list 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.00950768035714286];
# Point loads in kN to be applied in leaning column for P-delta effects consideration:
set leaningframeloads [list 6820.36959375 6820.36959375 6820.36959375 2994.9193125];

# -------------------------
# Braces Information
# -------------------------
# Eccentricity:
set e [list 180 190 200 210];
# W-Section depth:
set d_br [list 302 302 302 302];
# W-Section flange width:
set bf_br [list 203 203 203 203];
# W-Section flange thickness:
set tf_br [list 13.1 13.1 13.1 13.1];
# W-Section web thickness:
set tw_br [list 7.49 7.49 7.49 7.49];
# HSS-Section depth:
set h_br [list]
# HSS-Section width:
set b_br [list]
# HSS-Section thickness:
set t_br [list]
# Side-plate eccentering assembly length:
set Lp [list 500 500 500 500];
# Side-plate thickness:
set ts [list 19 19 19 19];
# Side-plate height:
set Hs [list 525 525 525 525];
# Knife-plate width:
set bg [list 500 500 500 500];
# Knife-plate thickness:
set tg [list 19 19 19 19];
# Knife-plate clearance length:
set Lg [list 38 38 38 38];
# Brace free length:
set Lb [list 7049.84471899924 7049.84471899924 7049.84471899924 7049.84471899924];
# Cross-section area of knife-gusset-angles assembly:
set Ai [list 15100 15100 15100 15100];
# Moment of Inertia of knife-gusset-angles assembly:
set Ii [list 256000000 256000000 256000000 256000000];

# -------------------------
# External Columns Information (bottom to top)
# -------------------------
# W-Section depth:
set d_ec [list 351 351 351 351];
# W-Section flange width:
set bf_ec [list 204 204 204 204];
# W-Section flange thickness:
set tf_ec [list 15.1 15.1 15.1 15.1];
# W-Section web thickness:
set tw_ec [list 8.64 8.64 8.64 8.64];

# -------------------------
# Internal Columns Information (bottom to top)
# -------------------------
# W-Section depth:
set d_ic [list 363 363 363 351];
# W-Section flange width:
set bf_ic [list 371 371 371 204];
# W-Section flange thickness:
set tf_ic [list 21.8 21.8 21.8 15.1];
# W-Section web thickness:
set tw_ic [list 13.3 13.3 13.3 8.64];

# -------------------------
# Beams Information (bottom to top)
# -------------------------
# W-Section depth:
set d_be [list 467 467 467 351];
# W-Section flange width:
set bf_be [list 282 282 282 204];
# W-Section flange thickness:
set tf_be [list 19.6 19.6 19.6 15.1];
# W-Section web thickness:
set tw_be [list 12.2 12.2 12.2 8.64];

# -------------------------
# Material Properties
# -------------------------
set matBraceTag 1
set matAssemTag 2
set FyBrace [expr $FyA992*$RyA992]; # Brace sections yield stress
set EhBrace [expr (0.1*$FyBrace/0.04)/$SteelE]; # Brace sections strain-hardening ratio
set FyAssem [expr $FyA992*$RyA992]; # Assembly sections yield stress
set EhAssem [expr (0.1*$FyAssem/0.04)/$SteelE]; # Assembly sections strain-hardening slope
set R0 30.0; # Parameter that controls transition form elastic to plastic branches, recommended value between 10 and 20. Value of 30 is used as recommended by Prof. Tremblay.
set CR1 0.925;# Parameter that controls transition form elastic to plastic branches, recommended value 0.925
set CR2 0.15; # Parameter that controls transition form elastic to plastic branches, recommended value 0.15
set a1 0.4; # isotropic hardening parameter, increase of compression yield envelope as proportion of yield strength after a plastic strain of $a2*($Fy/E0); value recommended by Prof. Tremblay
set a2 22.0; # isotropic hardening parameter; value recommended by Prof. Tremblay
set a3 0.4; # isotropic hardening parameter, increase of tension yield envelope as proportion of yield strength after a plastic strain of $a4*($Fy/E0); value recommended by Prof. Tremblay
set a4 22.0; # isotropic hardening parameter; value recommended by Prof. Tremblay
uniaxialMaterial Steel02 $matBraceTag $FyBrace $SteelE $EhBrace $R0 $CR1 $CR2 $a1 $a2 $a3 $a4; # Brace steel
uniaxialMaterial Steel02 $matAssemTag $FyAssem $SteelE $EhAssem $R0 $CR1 $CR2 $a1 $a2 $a3 $a4; # Assembly steel