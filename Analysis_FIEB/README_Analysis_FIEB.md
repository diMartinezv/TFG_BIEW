----------------------------------------------------------------------------------------------------
To execute the Non Linear Response History Analysis of Multi Story Models:

* First: edit "#Story_WSection_ModelArguments.tcl" (inside "#-Stories" folder)
  * W-Section dimensions (or HSS)
  * Material properties
  * Masses and loads
* Second: edit "ChainAnalysis_FIEB_Analysis.tcl"
  * Records selection
  * Other options
* Third: copy acceleration records in "Records" folder (check the example left) 
* Fourth: open a OpenSees window and type this:

  *     set type (type); set m (m); set n (n); source ChainAnalysis_FIEB_Analysis.tcl
  * If no "type" is set, both will be run
  * If no "m" (first record) and "n" (last record) are set, all records will be queued
  * Use "m" and "n" to run multiple analysis in parallel windows for example:
  *     set m 0; set n 5; source ChainAnalysis_FIEB_Analysis.tcl
  *     set m 6; set n 9; source ChainAnalysis_FIEB_Analysis.tcl
----------------------------------------------------------------------------------------------------

* "FIEB_Model_Definition.tcl" is ready to test W-Section Braces, it can test HSS Square Sections, but it needs to be edited first.
* "FIEB_Sismic_Analysis.tcl" should work for any case, edit to modify recorded results. 
* "GlobalUnits.tcl" recurrent engineering units used in the analysis, edit if there is a missing value.
* "ProceduresSectionsOpenSees.tcl" collection of section patches to create the cross sections, check for use of procedures
* "ProceduresTclOpenSees.tcl" miscellaneous procedures used in the analysis, check for use of procedures
