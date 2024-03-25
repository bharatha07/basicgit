/*************************************************
*Component Name:OpportunityCBCTUpdate_batch
Description: Batch Job to update CB and CT count from Assets to Opportunity
Created By: Teksystems
**************************************************/

global class OpportunityCBCTUpdate_batch implements Database.Batchable<sObject>,Database.Stateful{

    global List<String> errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Getting opportunity record where status is stored
        String query = 'SELECT Id, Name, Status__c,Stored_CB__c,Stored_CT__c FROM Opportunity Where Status__c=\'Stored\''; 
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('Inside execute method');
        system.debug('scope=====>>>>>'+scope);
        Map<Id,list<Asset>> oppToAssetMap = new Map<id,list<Asset>>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        //getting Asset record where status is stored and Asset is associated with opportunity
        for(Asset asObj: [SELECT Id, Name, Status,Type__c, Opportunity__c FROM Asset
                             WHERE Status = 'Stored' AND Opportunity__c IN :scope])
        {
            if(!oppToAssetMap.containsKey(asObj.Opportunity__c)) {
                oppToAssetMap.put(asObj.Opportunity__c, new list<Asset>());
            }
            oppToAssetMap.get(asObj.Opportunity__c).add(asObj);
        }
        
        for(Id oppId: oppToAssetMap.keySet()) {
            Integer Stored_CB = 0;
            Integer Stored_CT = 0;
            for(Asset assetObj: oppToAssetMap.get(oppId)) {
                 if(assetObj.Type__c=='Cord Blood'){
                    Stored_CB+=1;
                 }
                 else if(assetObj.Type__c=='Cord Tissue'){
                     Stored_CT+=1;
                 }                
            }
            oppToUpdate.add(new Opportunity(
                Id = oppId,
                Stored_CB__c = Stored_CB,
                Stored_CT__c =Stored_CT
            ));
        }
       
        
        system.debug('oppToUpdate=====>>>>>'+oppToUpdate);
        List<Database.SaveResult> saveResults = Database.update(oppToUpdate,false);
        system.debug(saveResults);
        for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    system.debug('error..................'+e.getMessage());
                    errors.add(e.getMessage());
                   
                }
            }
        }
        system.debug(errors);
        system.debug('error size'+errors.size());        
    }  
    
    global void finish(Database.BatchableContext BC){   
        
    }
    
   
}