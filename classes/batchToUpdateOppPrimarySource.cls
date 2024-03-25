/*************************************************************************************************
* @description This Batch job is to update primary source based on below conditions.
* @param - 
* @story - SFDC-1652 & 1242
* @Author -Teksystems
* @date - 21-APR-2021 (Teksystems)
*/
public class batchToUpdateOppPrimarySource implements Database.Batchable<sObject>{
    public String SOURCE = 'I\'m a Current Client';
  
   public Database.QueryLocator start(Database.BatchableContext BC){
   String query ='select id,status__c,AccountId from opportunity where Primary_Source__c =:SOURCE AND (Status__c =\'Enrolled\' or Status__c =\'Open\') AND Account.of_Stored_Opportunities__c =0';
       return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        if(!scope.isEmpty()){
            for(Opportunity opp:scope){
                opp.Primary_Source__c = null;
            }
        }
        List<database.saveResult> saveresults = Database.update(scope,false);
    }

   public void finish(Database.BatchableContext BC){
   }
}