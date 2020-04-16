//Description: Trigger on custom object 'Detail__c'

trigger Detail_Trigger on Detail__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{  
    Detail_TriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType); 
}