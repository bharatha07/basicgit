/*************************************************************************************************
* @description This Batch job is to update primary source based on opty status.
* @param - 
* @story - SFDC-1653
* @Author -Teksystems
* @date - 21-APR-2021 (Teksystems)
*/
public class PrimarySourceUpdateOneTimeBatch implements Database.Batchable<sObject>,Database.Stateful{
    public String SOURCE = 'I\'m a Current Client';
    public map<Id,id> accOptyIds = new map<Id,id>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query ='select id,status__c,AccountId,Primary_Source__c,Storage_Date__c from opportunity where Primary_Source__c !=:SOURCE AND Status__c =\'Stored\' AND Account.of_Stored_Opportunities__c >1 order by Storage_Date__c asc';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opptyList){
        List<Opportunity> optyPrimarySourList = new List<Opportunity>();
        if(!opptyList.isEmpty()){
            for(Opportunity opp:opptyList){
                if(!accOptyIds.containskey(opp.AccountId)){
                    accOptyIds.put(opp.AccountId,opp.id);
                }
                
            }
        }
        
        if(!accOptyIds.isEmpty()){
            for(opportunity oppty : opptyList){
                
                if(accOptyIds.containskey(oppty.accountid)){
                    id optyid =  accOptyIds.get(oppty.accountid);
                    if(optyid !=oppty.id){
                        if(oppty.Primary_Source__c !=SOURCE){
                        oppty.Primary_Source__c =SOURCE;
                        optyPrimarySourList.add(oppty);
                        }
                    }
                    
                }
            }  
        }
        
        
        if(!optyPrimarySourList.isEmpty()){
            List<Database.SaveResult> saveResults = Database.Update(optyPrimarySourList,false);    
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}