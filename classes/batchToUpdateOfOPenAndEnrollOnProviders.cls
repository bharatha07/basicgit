/*******************************************************************************************************************************************
* Component Name:batchToUpdateOfOPenAndEnrollOnProviders
* Description: Batch to update #of Open and #of Enroll Opty count on providers.
* Created By: TEKsystems
* Created Date: 
* User Story: SFDC - 1519,1520
************************************************************************************************************************************************/
global class batchToUpdateOfOPenAndEnrollOnProviders implements Database.Batchable<sObject> {
    global String PROVIDER = 'Provider';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,of_enrolled_optys__c,of_open_optys__c from Account where Recordtype.Name =: PROVIDER';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> providerIds = new Set<Id>();
        map<id,set<id>> optyMapEnrollNotPri = new map<id,set<id>>();
        Map<id,Account> ProvidLst = new Map<id,Account>();
        for(Account provider:scope){
            providerIds.add(provider.id);
        }
        if(!providerIds.isEmpty()){
            for(AggregateResult agr : [select count(Opportunity__c) countid,Provider__c accid,Opportunity__r.Status__c sts from
                                       Opportunity_Provider__c where Provider__c IN:providerIds AND Primary_Provider__c=true AND (Opportunity__r.Status__c='Open' or Opportunity__r.Enrollment_Date__c !=null)
                                       group by Provider__c,Opportunity__r.Status__c]){
                                           
                                           integer optyCount = (integer)agr.get('countid');
                                           system.debug('optyCount>>>>'+optyCount);
                                           id accid = (id)agr.get('accid');
                                           system.debug('accid>>>>'+accid);
                                           string status = (string)agr.get('sts');
                                           system.debug('status>>>>'+status);
                                           
                                           if(status =='open'){
                                               if(ProvidLst.containskey(accid)){
                                                   account act = ProvidLst.get(accid);
                                                   double opn = act.of_open_optys__c == Null ? 0 : act.of_open_optys__c;
                                                   act.of_open_optys__c=(opn+optyCount);
                                                   system.debug('Open>>>>>');
                                                   ProvidLst.put(act.id,act);
                                                   
                                               }else{
                                                   account acc = new account(id=accid);
                                                   acc.of_open_optys__c=optyCount;
                                                   system.debug('Opeelse>>>>>');
                                                   ProvidLst.put(acc.id,acc);  
                                               }
                                           }
                                           if(status != 'Open'){
                                               if(ProvidLst.containskey(accid)){
                                                   account act = ProvidLst.get(accid);
                                                   system.debug('Enrolled1>>>>'+act.of_enrolled_optys__c);
                                                   double enrol = act.of_enrolled_optys__c == Null ? 0 : act.of_enrolled_optys__c;
                                                   act.of_enrolled_optys__c =(enrol+optyCount);
                                                   system.debug('Enrolled222>>>>'+act.of_enrolled_optys__c);
                                                   //system.debug('Enrolled>>>>');
                                                   ProvidLst.put(act.id,act);
                                               }else{
                                                   account acc = new account(id=accid);
                                                   acc.of_enrolled_optys__c =optyCount;
                                                   system.debug('Enrolledelse>>>>>'+acc.of_enrolled_optys__c);
                                                   ProvidLst.put(acc.id,acc);  
                                               }
                                           }
                                           
                                           
                                       }
            for(AggregateResult agr : [select count(Opportunity__c) countid,Provider__c accid,Opportunity__r.Status__c sts from
                                       Opportunity_Provider__c where Provider__c IN:providerIds AND Primary_Provider__c=true 
                                       AND Opportunity__r.Primary_Source__c != 'I\'m a Current Client' AND Opportunity__r.Enrollment_Date__c !=null
                                       group by Provider__c,Opportunity__r.Status__c]){
                                           
                                           integer optyCount = (integer)agr.get('countid');
                                           system.debug('optyCount>>>>'+optyCount);
                                           id accid = (id)agr.get('accid');
                                           system.debug('accid>>>>'+accid);
                                           string status = (string)agr.get('sts');
                                           system.debug('status>>>>'+status);
                                           
                                           if(ProvidLst.containskey(accid)){
                                                   account act = ProvidLst.get(accid);
                                                   system.debug('Enrolled1>>>>'+act.New_Enrollments__c);
                                                   double enrol = act.New_Enrollments__c == Null ? 0 : act.New_Enrollments__c;
                                                   act.New_Enrollments__c =(enrol+optyCount);
                                                   system.debug('Enrolled222>>>>'+act.of_enrolled_optys__c);
                                                   //system.debug('Enrolled>>>>');
                                                   ProvidLst.put(act.id,act);
                                               }else{
                                                   account acc = new account(id=accid);
                                                   acc.New_Enrollments__c =optyCount;
                                                   system.debug('Enrolledelse>>>>>'+acc.New_Enrollments__c);
                                                   ProvidLst.put(acc.id,acc);  
                                               }
                                       }
            
        }
        set<id> failedProviders = new Set<id>();
        for (Database.SaveResult saveResult : Database.update(ProvidLst.values(),false)) {
            if (!saveResult.isSuccess()) {
                failedProviders.add(saveResult.getId());
                for(Database.Error e:saveResult.getErrors()){
                    system.debug('Error...'+e.getMessage());
                    
                }
            }
        }
        
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}