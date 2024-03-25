/*************************************************
*Component Name:ProviderFacility_batch
Description: Batch to Update Provider address with Facility address
Created By: Teksystems
**************************************************/
global class ProviderFacility_batch implements Database.Batchable<sObject>{

   
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Provider__c,Facility__r.BillingCity,Facility__r.BillingStreet,Facility__r.BillingState,Facility__r.BillingPostalCode,Facility__r.BillingCountry,Facility__r.BillingCountryCode,Facility__r.BillingStateCode FROM Provider_Facility__c WHERE Primary__c = true AND Provider__r.RecordType.Name = ' + '\'' + Label.Acc_RecType_Provider + '\'' + '  AND Facility__c <> NULL'; 
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Provider_Facility__c> scope){ 
        list<Account> prvListToUpdate=new list<Account>();
        map<String,Account> idToAcc=new map<String,Account>();
        
        for(Provider_Facility__c pf : scope){
        system.debug('pf id is::'+pf.Provider__c);
        if(!idToAcc.containsKey(pf.Provider__c)) {
                    idToAcc.put(pf.Provider__c, new Account(Id = pf.Provider__c,BillingCity = pf.Facility__r.BillingCity,
                                           BillingStreet = pf.Facility__r.BillingStreet,
                                           BillingState = pf.Facility__r.BillingState,
                                           BillingStateCode = pf.Facility__r.BillingStateCode,
                                           BillingPostalCode = pf.Facility__r.BillingPostalCode,
                                           BillingCountry = pf.Facility__r.BillingCountry,
                                           BillingCountryCode = pf.Facility__r.BillingCountryCode));
            }
           // idToAcc.get(pf.Provider__c).add(pf);
        
      
        }
        if(!idToAcc.isEmpty()) {
            update idToAcc.values();    
        }
    } 
    
    global void finish(Database.BatchableContext BC){   
        
    }
}