/*******************************************************************************************************************************************
* Component Name:batchToUpdateCBCTOnProviders
* Description: Batch to update CB/CT count on providers.
* Created By: TEKsystems(Tejaswini)
* Created Date: 
* User Story: SFDC - 20
************************************************************************************************************************************************/
global class batchToUpdateCBCTOnProviders implements Database.Batchable<sObject> {
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
        Map<Id,Set<id>> providerToOppMap = new Map<Id,Set<Id>>();
        Map<Id,Opportunity> oppUpdateList = new Map<Id,Opportunity>();
        List<Account> providersToUpdate = new List<Account>();
        for(Account provider:scope){
            providerIds.add(provider.id);
        }
        if(providerIds!=null && !providerIds.isEmpty()){
            oppProviderMap = new Map<Id,Opportunity_Provider__c>([select id,Primary_Provider__c,Provider__c,Opportunity__c,Opportunity__r.CBCTCountUpdatedOnProvider__c,Opportunity__r.status__c from Opportunity_Provider__c where Provider__c IN:providerIds AND Primary_Provider__c = true AND Opportunity__r.CBCTCountUpdatedOnProvider__c = false AND Opportunity__r.status__c = 'Stored']);
        }
        
        if(oppProviderMap!=null && !oppProviderMap.isEmpty()){
            for(Opportunity_Provider__c op:oppProviderMap.Values()){
                oppIds.add(op.opportunity__c);
                if(providerToOppMap.containsKey(op.Provider__c)){
                    Set<Id> tempList = providerToOppMap.get(op.Provider__c);
                    tempList.add(op.opportunity__c);
                    providerToOppMap.put(op.Provider__c,tempList);
                }else{
                    providerToOppMap.put(op.Provider__c,new Set<id>{op.opportunity__c});
                }
            }
        }
        
        if(oppIds!=null && !oppIds.isEmpty()){
            oppMap = new Map<Id,opportunity>([select id,Stored_CB__c,Stored_CT__c,CBCTCountUpdatedOnProvider__c   from opportunity where Id IN:oppIds]);
        }
        system.debug('oppMap ----->' + oppMap );
        for(Account provider:scope){
            if(providerToOppMap!=null && providerToOppMap.containsKey(provider.id)){
                Integer CbCount = 0;
                Integer CtCount = 0;
                for(Id oppId:providerToOppMap.get(provider.id)){
                    Opportunity tempOpp = oppMap.get(oppId);
                    if(tempOpp.Stored_CB__c!=null && Integer.valueOf(tempOpp.Stored_CB__c)>0){
                        cbCount += Integer.valueOf(tempOpp.Stored_CB__c);
                    }
                    if(tempOpp.Stored_CT__c!=null && Integer.valueOf(tempOpp.Stored_CT__c)>0){
                        ctCount += Integer.valueOf(tempOpp.Stored_CT__c);
                    }
                    tempOpp.CBCTCountUpdatedOnProvider__c = true;
                    oppUpdateList.put(tempOpp.id,tempOpp);
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
                for(Opportunity opp:oppUpdateList.values()){
                    if(providerToOppMap.get(provider.id).contains(opp.id)){
                        oppUpdateList.remove(opp.id); 
                    }
                }  
            }
        } 
        
        List<Database.SaveResult> oppSaveResults = Database.update(oppUpdateList.values(),false);
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}