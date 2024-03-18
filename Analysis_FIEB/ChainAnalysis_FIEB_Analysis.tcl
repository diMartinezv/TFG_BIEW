####################################################################################################
##
##      ChainAnalysis_FIEB_Analysis.tcl -- queue multiple accelerograms for analysis
##
##      Length: [mm] milimeter
##      Time: [s] second
##      Force: [kN] kilonewton
##
##      Story configuration
##          ...|/|\|...
##
##      Example left for "cor" cortical and "sub" subduction type records and for 12-Story model
##
####################################################################################################

# -------------------------
# Source Common Files (NEEDS TO BE SET BEFORE EXECUTING)
# -------------------------
# Since the model arguments are the only change between different models, its recommended to keep them in their own folder to also differentiate between results, the rest of the files can be kept in a shared folder (use "C:/Users/..." to specify a complete different directory)
set modelStoryNumber 12;
set multiStoryModel "${modelStoryNumber}Story_WSection_ModelArguments.tcl"; # Name to change for different models
set dirMultiStoryModel "${modelStoryNumber}-Stories/"; # Directory path of model to run analysis
set dirTclOpenSees ""; # Tcl/OpenSees files directory for procedures (if they are kept in a different directory)
set dirAccelerograms "Records/"; # Accelerograms files directory
source ${dirTclOpenSees}GlobalUnits.tcl
source ${dirTclOpenSees}ProceduresTclOpenSees.tcl
source ${dirTclOpenSees}ProceduresSectionsOpenSees.tcl

# -------------------------
# Options (CHECK OR LEAVE DEFAULTS)
# -------------------------
set safe_Results 0; # safe results with recorders. Defaults to true
set display_Analysis 1; # show display window with model (barely works and only with OpenSees 3.3). Defaults to false
set stop_at_Modes 0; # stops process after displaying periods of vibrational modes. Defaults to false
set stop_at_Analysis 0; # stops process before running analysis (to test time to start). Defaults to false
set totalModes 2; # total modes of vibrations to calculate (>= 2). Defaults to 2
set displayModes 0; # modes of vibrations displayed in console (<= totalModes). Comment to not display
# set detailedProgress 300; # show progress every n dt steps in duration. Comment to not display (doesn't work)

# -------------------------
# Accelerograms Data (CHECK WHERE TO EDIT)
# -------------------------
set recordList [list]
set timeStepList [list]
set durationList [list]
set scaleList [list]
set dirAccelerogramList [list]
set extensionList [list]; # Accelerograms data extension (exp. ".tcl" or ".txt")
set indexAccelerogram 0
if {![info exists type] || $type == "cor"} {
    # EDIT THIS FOR CORTICAL RECORDS #
    set directionCor [list ""]; # used if the record's names dont already diffentiate between directions, check "sub" case
    set recordCor [list "Imperial_Valley-08(360)" "Imperial_Valley-08(180)" "Northern_Calif-03(44)" "Northern_Calif-03(314)" "Victoria_Mexico(102)" "Victoria_Mexico(192)" "Hollister-01(181)" "Hollister-01(271)" "Westmorland(225)" "Westmorland(315)" "Westmorland(90)" "Westmorland(180)" "Parkfield(50)" "Parkfield(320)" "Coalinga-01(270)" "Coalinga-01(360)" "Coalinga-01(0)" "Coalinga-01(90)" "Coalinga-05(45)" "Coalinga-05(135)" "Managua_Nicaragua-02(90)" "Managua_Nicaragua-02(180)"];
    set timeStepCor [list 0.005 0.005 0.005 0.005 0.01 0.01 0.005 0.005 0.005 0.005 0.005 0.005 0.01 0.01 0.01 0.01 0.01 0.01 0.005 0.005 0.005 0.005];
    set durationCor [list 40 40 40 40 27 27 40.46 40.48 28.755 28.755 65 65 26.2 26.21 64.99 64.99 59.99 59.99 21.735 21.765 47.885 47.89];
    set scaleCor [list 5.360380772 5.360380772 2.16702876 2.16702876 2.527793648 2.527793648 5.110338992 5.110338992 4.085235456 4.085235456 1.570587636 1.570587636 4.799311412 4.799311412 1.876194256 1.876194256 2.98898182 2.98898182 2.548393296 2.548393296 2.810225664 2.810225664];
    # ------------------------------ #
    lappend recordList {*}[appendListValues $recordCor]
    lappend timeStepList {*}[repeatListValues $timeStepCor]
    lappend durationList {*}[repeatListValues $durationCor]
    lappend scaleList {*}[repeatListValues $scaleCor]
    for {set i $indexAccelerogram} {$i<[llength $recordList]} {incr i} {
        lappend dirAccelerogramList ${dirAccelerograms}cor/
        lappend extensionList ".dat"; # CHECK THIS
    }
    set indexAccelerogram [llength $recordList]
}
if {![info exists type] || $type == "sub"} {
    # EDIT THIS FOR SUBDUCTION RECORDS #
    set directionSub [list "EW" "NS"]
    set recordSub [list "HDKH070309260608" "HDKH070809110921" "IWTH151103111509" "KSRH090809110921" "TKCH080809110921" "HKD0950309260608" "HKD0950809110921" "HKD0970309260608" "HKD0970809110921" "HKD1070309260608" "HKD1110309260608"];
    set timeStepSub [list 0.005 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
    set durationSub [list 300 258 300 300 214 234 286 230 117 140 133];
    set scaleSub [list 1 1 1 1 1 1 1 1 1 1 1];
    # ------------------------------__ #
    lappend recordList {*}[appendListValues $recordSub $directionSub]
    lappend timeStepList {*}[repeatListValues $timeStepSub $directionSub]
    lappend durationList {*}[repeatListValues $durationSub $directionSub]
    lappend scaleList {*}[repeatListValues $scaleSub $directionSub]
    for {set i $indexAccelerogram} {$i<[llength $recordList]} {incr i} {
        lappend dirAccelerogramList ${dirAccelerograms}sub/
        lappend extensionList ".txt"; # CHECK THIS
    }
    set indexAccelerogram [llength $recordList]
}
if {[info exists type] && ($type != "cor" && $type != "sub")} {
    error "Error: Invalid period: '$type'"
}
puts $recordList

# -------------------------
# Source Analysis (DONT EDIT EXCEPT THE FOLDER NAME IF YOU WANT)
# -------------------------
# Manualy set 'm' and 'n' for specific records otherwise run all
if {![info exist m]} {
    if {![info exist n]} {
        set m 0
        set n [expr $indexAccelerogram-1]
    } else {
        error "Error: 'n' cannot be used without 'm'"
    }
} else {
    if {$m < 0 || $m >= [llength $recordList]} {
        error "Error: 'm' out of bounds"
    } else {
        if {![info exist n]} {
            set n $m
        } elseif {$n < $m || $n >= [llength $recordList]} {
            error "Error: 'n' out of bounds"
        }
    }
}
for {set l $m} {$l<=$n} {incr l} {
    set dirRecord [lindex $dirAccelerogramList $l]
    set record [lindex $recordList $l]
    set timeStep [lindex $timeStepList $l]
    set duration [lindex $durationList $l]
    set scale [lindex $scaleList $l]
    set dirResults "${dirMultiStoryModel}${record}-results"; # Results folder name (EDIT)
    set extAccelerograms [lindex $extensionList $l]
    source ${dirMultiStoryModel}${multiStoryModel}; # Call model arguments
    source ${dirTclOpenSees}FIEB_Model_Definition.tcl; # Define FIEB model
    source ${dirTclOpenSees}FIEB_Sismic_Analysis.tcl; # Run analysis
}
puts "Chain Analysis Completed for Records: [lindex $recordList $m] to [lindex $recordList $n]\n"