public class Detail_TriggerHandler {

    public static void handleTrigger(List<Detail__c> newRecords, List<Detail__c> oldRecords, Map<Id, Detail__c> newMap, Map<Id, Detail__c> oldMap, System.TriggerOperation triggerEvent){
        switch on triggerEvent {
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
            when BEFORE_INSERT {
                system.debug('#### Detail_TriggerHandler when BEFORE_INSERT');         
                // create clones for Formula.recalculateFormulas, because it throws an error if you use it on the trigger.new records
                List<Id> detailIDs = new List<Id>();

                Map<Detail__c, Detail__c> DetailsAndTheirClones = new Map<Detail__c, Detail__c>();
                for ( Detail__c detail : newRecords ) { 
                    detailIDs.add(detail.Id);
                    DetailsAndTheirClones.put(detail, detail.Clone()); 
                }
                // recalculate values on the clones
                Formula.recalculateFormulas(DetailsAndTheirClones.values());

                // SOQL the detail records for comparison to trigger.new versions
                List<Detail__c> detailList = [select Id, Name, Start_Date__c, Days__c, Months__c, End_Date__c, Master_End_Date__c from Detail__c WHERE Id IN :detailIDs];

                for (Detail__c detail : newRecords)
                {
                    Detail__c detailClone = DetailsAndTheirClones.get(detail);
                    date startDate = detail.Start_Date__c;
                    Integer months = detail.Months__c != null ? detail.Months__c.intValue() : 0;
                    Integer days = detail.Days__c != null ? detail.Days__c.intValue() : 0;
                    date endDate = startDate.addMonths(months).addDays(-1).addDays(days);
                    system.debug('#### Start_Date__c / End_Date__c: ' + detail.Start_Date__c + ' / ' + detail.End_Date__c);
                    system.debug('#### calculated end date: ' + endDate);
                    system.debug('#### clone recalculated end date: ' + detailClone.End_Date__c);
                    detail.End_Date_Trigger_Value__c = detailClone.End_Date__c;
                    detail.Master_End_Date_Trigger_Value__c = detail.Master_End_Date__c;  
                }

            }
            when BEFORE_UPDATE {
                system.debug('#### Detail_TriggerHandler when BEFORE_UPDATE');

            }
            when AFTER_INSERT {
                system.debug('#### Detail_TriggerHandler when AFTER_INSERT');
            }
            when AFTER_UPDATE {
               system.debug('#### Detail_TriggerHandler when AFTER_UPDATE');
            }
            when BEFORE_DELETE {
                system.debug('#### Detail_TriggerHandler when BEFORE_DELETE');
            }
            when AFTER_DELETE{
                system.debug('#### Detail_TriggerHandler when AFTER_DELETE');             
            }
            when else {
                system.debug('#### Detail_TriggerHandler when else - Do Nothing');
            }
        }
    }
}