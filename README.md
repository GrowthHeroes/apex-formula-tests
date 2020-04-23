# Salesforce Apex Formula Tests

This repository contains tests that show some current formula field errors when using Apex to access them as of Spring '20 / API 48

## Issues Tested

* Formula.recalculateFormulas() does not consistently recalculate formulas that use ADDMONTHS
* Formula.recalculateFormulas() throws a GACK (-817537752) Thrown: lib.gack.GackContext: sfdc.formula.InvalidFieldReferenceException: Field System__{MY custom metadata record} does not exist. Check spelling. Reason: {MY custom metadata} System__{MY custom metadata record} does not exist. Check spelling.
* Apex Trigger.new and Trigger.old records also exhibit the same inconsistent formula calculations when ADDMONTHS is used
* Comparing 2 formulas in a validation rule also results in bugs when using AddMonths()

## Business Requirements

We have a Master object with a Start Date, and an End Date Formula calculated by:
- `ADDMONTHS(Start_Date__c, Months__c,) -1 + Days__c`

We Have a Detail object with a Start Date, and an End Date Formula calculated by:
- `ADDMONTHS(Start_Date__c, Months__c,) -1 + Days__c`

The Detail can start later than the Master, and end Earlier than the Master. We want to know if the Detail and Master end on the Same Date.  So initially we just try to compare the Formula field values in a trigger, and if they match, set a Text field, that can then be rolled up. Think of it as "How many detail records end on the same day the Master ends?"

We noticed inconsistencies in what Apex believes the End Date to be, based on a various start dates that should all end on the same day not matching. 

## Trying to find a pattern

- most but not all examples seem to deal with being close to the end of the month
- most but not all examples seem to deal with crossing February, particularly if it crosses over a leap year february
- We are dealing with Date fields, not Date Time.... hopefully GMT is not wreaking havoc in the background somehow?
- Unfortunately since sometimes Apex ADDMONTHS is short, and sometimes the trigger.new value is short, the only way to be 100% consistent is to SOQL the records and ignore the values coming from trigger.new and ignore the values calculated from Apex ADDMONTHS. Hopefully I am making a mistake that will be obvious to others. Otherwise you have to decide to 100% rely on the stored formula values for dates, or 100% rely on apex for dates and cannot mix the two. 
- the inconsistencies are the same in BEFORE and AFTER trigger contexts, and these scenarios are limited to not making any changes in the formula's referenced fields in the current transaction. So it should not be an issue of current changes not being calcualted yet. 

## Specific Date Examples

### Formula in Trigger.new is 1 day Shorter
- Start 1/30/2018
- Months: 3
- Days: 0
- Formula ADDMONTHS end date in database: 4/29/2018
- __Formula ADDMONTHS end date in TRigger.new: 4/28/2018__
- Apex ADDMONTHS calculated end date: 4/29/2018


### Formula in Trigger.new is 1 day Shorter
- Start 6/29/2015
- Months: 8
- Days: 1
- Formula ADDMONTHS end date in database: 2/29/2016 
- __Formula ADDMONTHS end date in Trigger.new: 2/28/2016__
- Apex ADDMONTHS calculated end date: 2/29/2016


### Apex 1 day Shorter than Formula (this is rarer)
Master:
- Start 9/30/2019
- Months: 15
- Days: 1
- Formula ADDMONTHS end date in database: 12/31/2020
- Formula ADDMONTHS end date in Trigger.new: 12/31/2020
- __Apex ADDMONTHS calculated end date: 12/30/2020__
- This spans across a leap year February, does apex ADDMONTHS not offset for leap year?

Detail:
- Start 4/1/2020
- Months: 8
- Days: 30
- Formula ADDMONTHS end date in database: 12/30/2020
- Formula ADDMONTHS end date in Trigger.new: 12/30/2020
- Apex ADDMONTHS calculated end date: 12/30/2020

### Apex 1 day Shorter than Formula (this is rarer)
Master:
- Start 4/3/2019
- Months: 12
- Days: 1
- Formula ADDMONTHS end date in database: 4/3/2020
- Formula ADDMONTHS end date in Trigger.new: 4/3/2020
- Apex ADDMONTHS calculated end date: 4/3/2020
- This spans across a leap year February, but is correct

Detail:
- Start 9/30/2019
- Months: 6
- Days: 4
- Formula ADDMONTHS end date in database: 4/3/2020
- Formula ADDMONTHS end date in Trigger.new: 4/3/2020
- __Apex ADDMONTHS calculated end date: 4/2/2020__
- This spans across a leap year February, but is wrong in APEX ADDMONTHS


### Validation rule fails comparing 2 Formula fields that use Add Months

Master:
- Start 1/29/2018
- Months: 13
- Days: 0
- Formula ADDMONTHS end date in database: 2/27/2019

Detail:
- Start 3/29/2018
- Months: 10
- Days: 30
- Formula ADDMONTHS end date in database: 2/27/2019

VALIDATION RULE on DETAIL:
- End_Date__c > Master__r.End_Date__c 
- __THROWS VALIDATION ERROR MESSAGE "Detail End Date cannot be greater than Master End Date__"



