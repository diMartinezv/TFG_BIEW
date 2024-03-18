####################################################################################################
##
##      12Story_WSection_Model_Arguments.tcl -- arguments for model construction
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##      Story configuration
##          ...|/|\|...
##
##		Example left for 12 Story Model, can be changed to any number of stories n, with each list containing the n number of entries
##
####################################################################################################

wipe all
setMaxOpenFiles 2048
model Basic Builder -ndm 2 -ndf 3;

# -------------------------
# General Frame Information
# -------------------------
set braceSection "W"; # Only possibilities "W" or "HSS"
set numberStories 12; # Number of stories
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
set weight [list 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 3036.60140625 1460.93625];
# Point loads on end columns in kN, from bottom to top (tributary area is supposed equal on exterior and interior columns, loads are such that combined with the beam loads and leaning frame loads produce same amount as factored gravity load as considered in design):
set columnloadsend [list 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 194.867702678571 85.5691232142857];
# Point loads on center columns in kN, from bottom to top:
set columnloadscenter [list 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0];
# Distributed gravity loads on beams in kN/mm, from bottom to top:
set beamloads [list 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.0216519669642857 0.00950768035714286];
# Point loads in kN to be applied in leaning column for P-delta effects consideration:
set leaningframeloads [list 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 6820.36959375 2994.9193125];

# -------------------------
# Braces Information
# -------------------------
# Eccentricity:
set e [list 190 200 210 220 230 240 250 260 270 280 290 300];
# W-Section depth:
set d_br [list 419 419 419 419 419 419 419 419 419 419 419 419];
# W-Section flange width:
set bf_br [list 262 262 262 262 262 262 262 262 262 262 262 262];
# W-Section flange thickness:
set tf_br [list 19.3 19.3 19.3 19.3 19.3 19.3 19.3 19.3 19.3 19.3 19.3 19.3];
# W-Section web thickness:
set tw_br [list 11.6 11.6 11.6 11.6 11.6 11.6 11.6 11.6 11.6 11.6 11.6 11.6];
# HSS-Section depth:
set h_br [list]
# HSS-Section width:
set b_br [list]
# HSS-Section thickness:
set t_br [list]
# Side-plate eccentering assembly length:
set Lp [list 650 650 650 650 650 650 650 650 650 650 650 650];
# Side-plate thickness:
set ts [list 50 50 50 50 50 50 50 50 50 50 50 50];
# Side-plate height:
set Hs [list 675 675 675 675 675 675 675 675 675 675 675 675];
# Knife-plate width:
set bg [list 650 650 650 650 650 650 650 650 650 650 650 650];
# Knife-plate thickness:
set tg [list 25 25 25 25 25 25 25 25 25 25 25 25];
# Knife-plate clearance length:
set Lg [list 50 50 50 50 50 50 50 50 50 50 50 50];
# Brace free length:
set Lb [list 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924 6749.84471899924];
# Cross-section area of knife-gusset-angles assembly:
set Ai [list 29200 29200 29200 29200 29200 29200 29200 29200 29200 29200 29200 29200];
# Moment of Inertia of knife-gusset-angles assembly:
set Ii [list 924000000 924000000 924000000 924000000 924000000 924000000 924000000 924000000 924000000 924000000 924000000 924000000];

# -------------------------
# External Columns Information (bottom to top)
# -------------------------
# W-Section depth:
set d_ec [list 394 394 394 361 361 361 353 353 353 351 351 351];
# W-Section flange width:
set bf_ec [list 399 399 399 371 371 371 254 254 254 204 204 204];
# W-Section flange thickness:
set tf_ec [list 36.6 36.6 36.6 19.8 19.8 19.8 16.4 16.4 16.4 15.1 15.1 15.1];
# W-Section web thickness:
set tw_ec [list 22.6 22.6 22.6 12.3 12.3 12.3 9.53 9.53 9.53 8.64 8.64 8.64];

# -------------------------
# Internal Columns Information (bottom to top)
# -------------------------
# W-Section depth:
set d_ic [list 455 455 455 406 406 406 368 368 368 353 353 351];
# W-Section flange width:
set bf_ic [list 419 419 419 404 404 404 373 373 373 254 254 204];
# W-Section flange thickness:
set tf_ic [list 67.6 67.6 67.6 43.7 43.7 43.7 23.9 23.9 23.9 16.4 16.4 15.1];
# W-Section web thickness:
set tw_ic [list 42.2 42.2 42.2 27.2 27.2 27.2 15 15 15 9.53 9.53 8.64];

# -------------------------
# Beams Information (bottom to top)
# -------------------------
# W-Section depth:
set d_be [list 551 551 551 549 549 549 419 419 419 467 467 351];
# W-Section flange width:
set bf_be [list 315 315 315 214 214 214 262 262 262 193 193 204];
# W-Section flange thickness:
set tf_be [list 24.4 24.4 24.4 23.6 23.6 23.6 19.3 19.3 19.3 19.1 19.1 15.1];
# W-Section web thickness:
set tw_be [list 15.2 15.2 15.2 14.7 14.7 14.7 11.6 11.6 11.6 11.4 11.4 8.64];

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