/*************************************************
*Component Name:OpportunityCBCTUpdate_batch
Description: Batch Job to update CB and CT count from Assets to Opportunity
Created By: Teksystems
**************************************************/

global class OpportunityCBCTUpdate_batchv2 implements Database.Batchable<sObject>,Database.Stateful{
    
    global List<String> errors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Getting opportunity record where status is stored
        String query = 'SELECT Id, Name, Status__c,Stored_CB__c,Stored_CT__c FROM Opportunity Where Status__c=\'Stored\' AND assetBoolenonOptyforcbct__c=False';
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        Map<Id,Opportunity>  oppMap = new Map<Id,Opportunity>(scope);
        
        //CT
        for(AggregateResult aggr: [SELECT Count(Id) AssetCount, Type__c,Opportunity__c FROM Asset
                                   WHERE Status = 'Stored' AND DiscontinuedStorage__c = false AND Opportunity__c IN: scope Group by Type__c,Opportunity__c ])
        {
            if(aggr.get('Type__c') == 'Cord Blood') {
                oppMap.get((String)aggr.get('Opportunity__c')).Stored_CB__c= (Integer)aggr.get('AssetCount');
                
            } else if(aggr.get('Type__c') == 'Cord Tissue') {
                oppMap.get((String)aggr.get('Opportunity__c')).Stored_CT__c = (Integer)aggr.get('AssetCount');
                
                
            }
            oppMap.get((String)aggr.get('Opportunity__c')).assetBoolenonOptyforcbct__c= True;
        }
        List<Database.SaveResult> saveResults = Database.update(oppMap.values(),false);
               for (Database.SaveResult saveResult : saveResults) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    system.debug('error..................'+e.getMessage());
                    errors.add(e.getMessage());
                    
                }
            }
        }
        
    }  
    
    global void finish(Database.BatchableContext BC){   
        
    }
  }