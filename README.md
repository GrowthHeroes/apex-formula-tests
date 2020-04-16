# Salesforce Apex Formula Tests

This repository contains tests that show some current formula field errors when using Apex to access them as of Spring '20 / API 48

## Issues Tested

* Formula.recalculateFormulas() does not consistently recalculate formulas that use ADDMONTHS
* Formula.recalculateFormulas() throws a GACK (-817537752) Thrown: lib.gack.GackContext: sfdc.formula.InvalidFieldReferenceException: Field System__{MY custom metadata record} does not exist. Check spelling. Reason: {MY custom metadata} System__{MY custom metadata record} does not exist. Check spelling.
* Apex Trigger.new and Trigger.old records also exhibit the same inconsistent formula calculations when ADDMONTHS is used



