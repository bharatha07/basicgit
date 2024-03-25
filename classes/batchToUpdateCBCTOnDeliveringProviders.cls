/*******************************************************************************************************************************************
* Component batchToUpdateCBCTOnDeliveringProviders
* Description: Batch to update CB/CT count on providers.
* Created By: TEKsystems(Tejaswini)
* Created Date: 
* User Story: SFDC - 2141
************************************************************************************************************************************************/
global class batchToUpdateCBCTOnDeliveringProviders implements Database.Batchable<sObject> {
    global String PROVIDER = 'Provider';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,of_CB_Collected__c,of_CT_Collected__c from Account where Recordtype.Name =: PROVIDER';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> providerIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity_Provider__c> oppProviderMap = new Map<Id,Opportunity_Provider__c>();
        Map<Id,List<Opportunity_Provider__c>> providerToOppMap = new Map<Id,List<Opportunity_Provider__c>>();
        Map<Id,Opportunity_Provider__c> oppProviderUpdateList = new Map<Id,Opportunity_Provider__c>();
        List<Account> providersToUpdate = new List<Account>();
        for(Account provider:scope){
            providerIds.add(provider.id);
        }
        if(providerIds!=null && !providerIds.isEmpty()){
            oppProviderMap = new Map<Id,Opportunity_Provider__c>([select id,Delivering_Provider__c,Provider__c,Opportunity__c,Opportunity__r.Stored_CB__c,Opportunity__r.Stored_CT__c,CountCBCTonDeliveringProvider__c,Opportunity__r.status__c from Opportunity_Provider__c where Provider__c IN:providerIds AND Delivering_Provider__c = true AND CountCBCTonDeliveringProvider__c = false AND Opportunity__r.status__c = 'Stored' LIMIT 49999]);
        }
        
        if(oppProviderMap!=null && !oppProviderMap.isEmpty()){
            for(Opportunity_Provider__c op:oppProviderMap.Values()){
                if(providerToOppMap.containsKey(op.Provider__c)){
                    List<Opportunity_Provider__c> tempList = providerToOppMap.get(op.Provider__c);
                    tempList.add(op);
                    providerToOppMap.put(op.Provider__c,tempList);
                }else{
                    providerToOppMap.put(op.Provider__c,new List<Opportunity_Provider__c>{op});
                }
            }
        }
        
        for(Account provider:scope){
            if(providerToOppMap!=null && providerToOppMap.containsKey(provider.id)){
                Integer CbCount = 0;
                Integer CtCount = 0;
                for(Opportunity_Provider__c oppProv:providerToOppMap.get(provider.id)){
                
                    if(oppProv.opportunity__r.Stored_CB__c!=null && Integer.valueOf(oppProv.opportunity__r.Stored_CB__c)>0){
                        cbCount += Integer.valueOf(oppProv.opportunity__r.Stored_CB__c);
                    }
                    if(oppProv.opportunity__r.Stored_CT__c!=null && Integer.valueOf(oppProv.opportunity__r.Stored_CT__c)>0){
                        ctCount += Integer.valueOf(oppProv.opportunity__r.Stored_CT__c);
                    }
                    oppProv.CountCBCTonDeliveringProvider__c = true;
                    oppProviderUpdateList.put(oppProv.Id,oppProv);
                }
                if(provider.of_CB_Collected__c == null){
                    provider.of_CB_Collected__c = cbCount;
                }
                else{
                    provider.of_CB_Collected__c += cbCount;
                }
                if(provider.of_CT_Collected__c == null){
                    provider.of_CT_Collected__c = ctCount;
                }
                else{
                    provider.of_CT_Collected__c += ctCount;
                }
                providersToUpdate.add(provider);
            }
        }
        
        Set<Id> failedProviders = new Set<Id>();
        List<Database.SaveResult> providerSaveResults = Database.update(providersToUpdate,false);
        for (Database.SaveResult saveResult : providerSaveResults) {
            if (!saveResult.isSuccess()) {
                failedProviders.add(saveResult.getId());
                for(Database.Error e:saveResult.getErrors()){
                    system.debug('Error...'+e.getMessage());
                    
                }
            }
        }
        
        for(Account provider:scope){
            if(failedProviders!=null && failedProviders.contains(provider.id)){
                for(Opportunity_Provider__c opp:oppProviderUpdateList.values()){
                    if(providerToOppMap.get(provider.id).contains(opp)){
                        oppProviderUpdateList.remove(opp.id); 
                    }
                }  
            }
        } 
        
        List<Database.SaveResult> oppSaveResults = Database.update(oppProviderUpdateList.values(),false);
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}