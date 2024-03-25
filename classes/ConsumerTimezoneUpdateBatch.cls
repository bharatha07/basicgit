/*******************************************************************************************************************************
* Component Name: ConsumerTimezoneUpdateBatch
* Description : Batch class to update timezone of consumer accounts.
* Created Date: 21 August 2019
* Developed By: Tejaswini(TEKsystems)
********************************************************************************************************************************/
global class ConsumerTimezoneUpdateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'Select id,Timezone__c, BillingPostalCode, BillingCountry,RecordtypeId From Account Where BillingPostalCode!= null AND BillingCountry= \'United States\' AND Timezone__c = NULL AND Client_Account_Number__c!= null AND isPersonAccount = TRUE';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> records){
        Map<String,US_Zipcode__c> ZipcodeNameRecMap = new Map<String,US_Zipcode__c>();
        LIst<US_Zipcode__c> usZipcodes = new List<US_Zipcode__c>();
        usZipcodes = [select id,Time_Zone__c, Name from US_Zipcode__c];
        if(usZipcodes!=null && !usZipcodes.isEmpty()){
            for(US_Zipcode__c usZipcode:usZipcodes){
                ZipcodeNameRecMap.put(usZipcode.Name,usZipcode);
            }
        }
        Id consumerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        LIst<Account> finalAccountToUpdate = new List<Account>();
        if(records!=null && !records.isEmpty() && ZipcodeNameRecMap!=null && !ZipcodeNameRecMap.isEMpty()){
                for(Account acc:records){
                    if(acc.RecordtypeId == consumerAccountRecordTypeId && String.isNotBlank(acc.BillingPostalCode)){
                        acc.Timezone__c = ZipcodeNameRecMap.get(acc.BillingPostalCode).Time_Zone__c;
                        finalAccountToUpdate.add(acc);
                    }
                }
        }
        List<Database.saveResult> saveResults = Database.Update(finalAccountToUpdate,false);
        system.debug(saveResults);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}