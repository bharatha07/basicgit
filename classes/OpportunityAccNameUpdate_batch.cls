/*************************************************
*Component Name:OpportunityAccNameUpdate_batch
Description: Batch to update opty account name with opty contact(primary) account name
Created By: Teksystems
**************************************************/
global class OpportunityAccNameUpdate_batch implements Database.Batchable<AggregateResult> { 
    private DateTime startDateTime;
    private DateTime endDateTime;

    public OpportunityAccNameUpdate_batch(DateTime startDateTime, DateTime endDateTime) {
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC){ 
        return new AggregateResultIterable(startDateTime, endDateTime); 
    } 
    
    global void execute(Database.BatchableContext BC, List<AggregateResult> scope){ 
        Set<String> setOfOppUnderConsideration = new Set<String>();
        List<Opportunity> lstOfMismatchOpp = new List<Opportunity>();
        for(AggregateResult ag : scope) {
            setOfOppUnderConsideration.add((String)ag.get('Opportunity__c'));
        }
        if(!setOfOppUnderConsideration.isEmpty()) {
            for(Opportunity opp : [SELECT Id,AccountId,(SELECT Id,PersonAccount__c FROM Account_Opportunities__r WHERE Primary__c = true) FROM Opportunity WHERE Id IN : setOfOppUnderConsideration]) {
                if(opp.AccountId <> opp.Account_Opportunities__r[0].PersonAccount__c) {
                    lstOfMismatchOpp.add(opp);
                }
            }
        }
        System.debug('>>>>>' + lstOfMismatchOpp);
    } 
    
    global void finish(Database.BatchableContext BC){   
        
    }
}