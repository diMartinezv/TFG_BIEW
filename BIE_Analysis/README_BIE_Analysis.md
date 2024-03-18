----------------------------------------------------------------------------------------------------
To execute the individual analysis for W-Section BIEs:

* First: edit "WSections_BIE_Model_Arguments.tcl": (braces dimensions)
----------------------------------------------------------------------------------------------------
For monotonic analysis

* Second: edit "Chain_BIE_Monotonic_Analysis.tcl" 
  * Choose result's folder
* Third: open a OpenSees window and type this:
  * For specific sections (not using the for loop) use "i" (initial section) and "f" (final section)
  *     set i 0; set f 10; source Chain_BIE_Monotonic_Analysis.tcl
  * For all preset sections (using the for loop - not recommended, too many sections):
  *     source Chain_BIE_Monotonic_Analysis.tcl

----------------------------------------------------------------------------------------------------
For cyclyc analysis

* Second: edit "WSections_BIE_Cyclic_Displacements.tcl" to change the default target displacement cycles
* Third: edit "Chain_BIE_Cyclic_Analysis.tcl" for a specific set of target displacements
* Fourth: open a OpenSees window and type this:

  * For specific sections (not using the for loop) use "m" (section) and "n" (eccentricity)
  *     set m 2; set n 1; source Chain_BIE_Cyclic_Analysis.tcl
  * For all preset sections (using the for loop)
  *     source Chain_BIE_Cyclic_Analysis.tcl

----------------------------------------------------------------------------------------------------

* "WSections_BIE_Model_Definition.tcl" is already configured for W-Sections.
* "WSections_BIE_Monotonic_Load.tcl" uses a load protocol of 1 mm per displacement step
* "WSections_BIE_Cyclic_Load.tcl" similar to the monotonic, uses the more complex "WSections_BIE_Cyclic_Displacements.tcl" load protocol
* "dUlist(OpenSees).dat" is used to check the displacements used in the analysis, they can be graphed in another program