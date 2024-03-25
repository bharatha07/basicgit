/*
Name : CountStoredOpportunitiesBatch 
Description : 1003 - Batch class to count stored opp and show on Provider if related opp provider exists.
Created By: Nitish Bansal (TEK)
Created Date: 06/03/2019
*/

global class CountStoredOpportunitiesBatch implements Database.Batchable<sObject>, Database.Stateful{

   global String STORED = 'Stored'; 
   global Map<Id, List<Id>> accountToOppIdsMap = new Map<Id, List<Id>>();
   global Boolean isTestClass;
   global CountStoredOpportunitiesBatch(Boolean isRunTest){
       isTestClass = isRunTest;
   }
   global Database.QueryLocator start(Database.BatchableContext BC){
      String query = 'Select Id, Provider__c, Opportunity__c from Opportunity_Provider__c where Provider__c != null And (Opportunity__r.StageName = :STORED  OR Opportunity__r.Status__c = :STORED )'; 
      if(isTestClass = true){
          query += ' AND LASTModifiedDate = TODAY';
      }
      else{
          query += ' AND LASTModifiedDate = YESTERDAY';
      }
     
      system.debug('query : '+query);
      return Database.getQueryLocator(query);
   }
   
   global void execute(Database.BatchableContext BC, List<Opportunity_Provider__c> scope){
      List<Id> opportunityIds = new List<Id>();
      
      //Processing all the opportunity providers which are associated to a provider and Stored opportunity.
      for(Opportunity_Provider__c op: scope){
         opportunityIds = new List<Id>(); 
         if(accountToOppIdsMap.containsKey(op.Provider__c) ){
            opportunityIds.addAll(accountToOppIdsMap.get(op.Provider__c)) ;
         } 
         opportunityIds.add(op.Opportunity__c);        
         accountToOppIdsMap.put(op.Provider__c, opportunityIds);                     
      }
   }
    
    global void finish(Database.BatchableContext BC){
        List<Account> providers = new List<Account>();
        List<Id> accIds = new List<Id>();
        
        //Removing duplicate records
        for(Id accountId : accountToOppIdsMap.keyset()){
            if(accountToOppIdsMap.containsKey(accountId )){
                Set<Id> oppIds = new Set<Id>();
                List<Id> oppIdsList = new List<Id>();
                oppIds.addAll(accountToOppIdsMap.get(accountId ));
                oppIdsList.addAll(oppIds);
                accountToOppIdsMap.put(accountId, oppIdsList);
            } 
        }
        
        //Updating the account with the stored opportunities count for records having opportunity provider
        for(Account acc : [Select Id, Stored_opportunities__c from account 
                           where Id In:accountToOppIdsMap.keyset()]){
            if(accountToOppIdsMap.containsKey(acc.Id)){
                acc.Stored_opportunities__c = accountToOppIdsMap.get(acc.Id).size();
                providers.add(acc); 
            }
        }
        
        if(providers.size() > 0)
            update providers; 
        
        //Doing separate DML as we won't run into number of DML limits here but in order to avoid no of records per DML transaction limit in future
            
        //Restting the stored opportunities count for the accounts which don't have any opportunity provider associated
        providers = new List<Account>();
        for(Account acc : [Select Id, Stored_opportunities__c from account 
                           where Id NOT In:accountToOppIdsMap.keyset() and Stored_opportunities__c > 0]){
            acc.Stored_opportunities__c = 0;
            providers.add(acc); 
            
        }
        if(providers.size() > 0)
            update providers; 
    }
}