----------------------------------------------------------------------------------------------------
To execute the Cyclic Load Analysis for W-Section BIEs:

* First: edit "CHAINCYCLIC_BIE_ANALYSIS.tcl"
  * W-Section dimensions
  * Set of sections to be tested
* Second: edit "CYCLIC_DISPLACEMENTS.tcl" for a specific set of target displacements
* Third: open a OpenSees window and type this:

  * For specific sections (not using the for loop)
  *     set m 2; set n 1; source CYCLIC_ANALYSIS_ISOLATED_BIE.tcl
  * For all preset sections (using the for loop)
  *     source CYCLIC_ANALYSIS_ISOLATED_BIE.tcl

----------------------------------------------------------------------------------------------------

* "CYCLIC_LOAD_BIE.tcl" is the same as the monotonic load, only the loading protocol changes.
* "dUlist(OpenSees).dat" is used to check the displacements used in the analysis, they can be graphed in another program 