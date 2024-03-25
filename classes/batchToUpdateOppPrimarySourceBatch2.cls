/*************************************************************************************************
* @description This Batch job is to update primary source based on opty status.
* @param - 
* @story - SFDC-1653
* @Author -Teksystems
* @date - 21-APR-2021 (Teksystems)
*/
public class batchToUpdateOppPrimarySourceBatch2 implements Database.Batchable<sObject>{
    public String SOURCE = 'I\'m a Current Client';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query ='select id,status__c,AccountId from opportunity where Primary_Source__c !=:SOURCE AND Enrollment_date__c = TODAY AND Status__c =\'Enrolled\' AND Account.of_Stored_Opportunities__c >0';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opptyList){
        if(!opptyList.isEmpty()){
            for(Opportunity opp:opptyList){
                opp.Primary_Source__c = SOURCE;
            }
        }
        List<database.saveResult> saveresults = Database.update(opptyList,false);
    }

    
    
    public void finish(Database.BatchableContext BC){
    }
}