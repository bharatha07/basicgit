/*
Name : CountStoredOppBatchHistoricalData 
Description : Batch class to count stored opp and show on Provider if related opp provider exists. This batch is for historical data
Created By: Tejaswini
Created Date: 07/10/2019
*/
global class CountStoredOppBatchHistoricalData implements Database.Batchable<sObject>, Database.Stateful{
    global String PROVIDER = 'Provider'; 
    global String STORED = 'Stored';
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Stored_opportunities__c from Account where RecordType.Name =: PROVIDER';
        return Database.getQueryLocator(query);
    }
     global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<Id,Set<Id>> providerOptyProviders = new Map<Id,Set<Id>>();
        Map<id,opportunity_provider__c> oppProviderMap = new Map<Id,Opportunity_Provider__c>();
        Map<id,Account> accountMap = new Map<Id,Account>();
        List<Account> providersList = new List<Account>();
        for(Account acc:scope){
            accountMap.put(acc.id,acc);
        }
        if(accountMap!=null && !accountMap.isEmpty()){
            oppProviderMap = new Map<Id,Opportunity_Provider__c>([select id,Provider__c, Opportunity__c from Opportunity_Provider__c where Provider__c != null And (Opportunity__r.StageName = :STORED OR Opportunity__r.Status__c = :STORED ) AND Provider__c IN: accountMap.keyset()]);
        }
        if(oppProviderMap!=null && !oppProviderMap.isEmpty()){
            for(Opportunity_Provider__c op:oppProviderMap.values()){
                if(providerOptyProviders.containsKey(op.Provider__c)){
                    Set<Id> optyIds = new Set<id>();
                    optyIds = providerOptyProviders.get(op.provider__c);
                    optyIds.add(op.Opportunity__c);
                    providerOptyProviders.put(op.provider__c,optyIds);
                }
                else{
                    providerOptyProviders.put(op.provider__c,new set<Id>{op.Opportunity__c});
                }
                
            }
        }
        if(providerOptyProviders!=null && !providerOptyProviders.isEmpty()){
            for(Account provider:scope){
                if(providerOptyProviders.get(provider.id)!=null && providerOptyProviders.get(provider.id).size()>0){
                    provider.Stored_opportunities__c = providerOptyProviders.get(provider.id).size();
                    providersList.add(provider);
                }
                
            }
        }
        List<Database.saveResult> saveResults = Database.update(providersList,false);
        system.debug('saveResults---------'+saveResults);
     }
     global void finish(Database.BatchableContext BC){}
}