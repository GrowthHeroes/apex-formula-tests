@isTest
public class Detail_TriggerHandler_Test{

    @testSetup
    static void testSetup(){
        // static resources contain known bad ADDMONTHS dates that apex wrongly calculates
        List<sObject> masters = Test.loadData(Master__c.sObjectType, 'MasterTestData');
        List<sObject> details = Test.loadData(Detail__c.sObjectType, 'DetailTestData');
        //insert masters;
        //insert details;

    }

    // Shows how Trigger.new formula values can be off by 1 day short with certain ADDMONTHS dates
    @isTest
    public static void TestTriggerNewValueForFormulaWithADDMONTHS(){
        List<Detail__c> details = [select Id, Name, Start_Date__c, Months__c, Days__c, End_Date__c, End_Date_Trigger_Value__c, Master__r.End_Date__c, Master_End_Date__c, Master_End_Date_Trigger_Value__c FROM Detail__c];
        for(Detail__c detail : details){
            system.assertEquals(detail.End_Date__c, detail.End_Date_Trigger_Value__c, 'End Dates do not match: ' + detail.End_Date__c + ' / ' + detail.End_Date_Trigger_Value__c );
        }

    }

    // Shows how Formula.recalculateFormulas contains the same wrong values as Trigger.new
    @isTest
    public static void TestFormulaRecalulateFormulasForFormulaWithADDMONTHS(){
        List<Detail__c> details = [select Id, Name, Start_Date__c, Months__c, Days__c, End_Date__c, End_Date_Trigger_Value__c, Master__r.End_Date__c, Master_End_Date__c, Master_End_Date_Trigger_Value__c FROM Detail__c];
        Map<Detail__c, Detail__c> DetailsAndTheirClones = new Map<Detail__c, Detail__c>();
        for ( Detail__c detail : details ) { 
            DetailsAndTheirClones.put(detail, detail.Clone()); 
        }
        Formula.recalculateFormulas(DetailsAndTheirClones.values());
        
        for(Detail__c detail : details){
            Detail__c detailClone = DetailsAndTheirClones.get(detail);
            system.assertEquals(detail.End_Date__c, detailClone.End_Date__c, 'End Dates do not match: ' + detail.End_Date__c + ' / ' + detailClone.End_Date__c );
        }

    }    

    // Shows how having a formula that references a custom metadata record causes a GACK when calling Formula.recalculateFormulas
    @isTest
    public static void TestRecalculateFormulawithCustomMetadata(){
        List<Master__c> masters = [select Id, Name, Start_Date__c, Months__c, Days__c, End_Date__c, Metadata_Formula__c 
            FROM Master__c];
        Formula.recalculateFormulas(masters);

    }

}

/*
@isTest  private class caseUtil {      
    static testmethod void testLoadData() {          
        List < sObject > ls = Test.loadData(Case.sObjectType, 'testCases');          
        Case c = (Case) ls[0];          
        System.assert(ls.size() == 1);          
        String cStatus = c.Status;          
        DateTime cDate = c.CreatedDate;          
        System.debug('Case Id: ' + c.Id);          
        System.debug('Case Status: ' + cStatus);          
        System.debug('Case Date: ' + cDate);          c.status = 'New';          
        update c;          
        System.debug('Case status: ' + c.status);      } }
        */