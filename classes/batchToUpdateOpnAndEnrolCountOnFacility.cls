/*******************************************************************************************************************************************
* Component Name:batchToUpdateOpnAndEnrolCountOnFacility
* Description: Batch to update Open And Enroll opty count on delivering facilities.
* Created By: TEKsystems
* Created Date: 
* User Story: SFDC - 1547
************************************************************************************************************************************************/
global class batchToUpdateOpnAndEnrolCountOnFacility implements Database.Batchable<sObject> {
    global String FACILITY = 'Facility';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,of_enrolled_optys__c,of_open_optys__c from Account where Recordtype.Name =: FACILITY AND Type__c  = \'Hospital\'';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> facilityIds = new Set<Id>();
        Map<id,Account> FacliLst = new Map<id,Account>();
        for(Account facility:scope){
            facilityIds.add(facility.id);
        }
        //query on opportunities whose delivering hospital is in scope
        if(facilityIds!=null && !facilityIds.isEmpty()){
            for(AggregateResult agr : [select count(id) countid,Delivering_Hospital__c accid,status__c sts from
                                       opportunity where Delivering_Hospital__c IN :facilityIds AND (status__c ='Open' or status__c ='Enrolled' or Enrollment_Date__c !=null)
                                       group by Delivering_Hospital__c,status__c]){
                                           
                                           integer optyCount = (integer)agr.get('countid');
                                           system.debug('optyCount>>>>'+optyCount);
                                           id accid = (id)agr.get('accid');
                                           system.debug('accid>>>>'+accid);
                                           string status = (string)agr.get('sts');
                                           system.debug('status>>>>'+status);
                                           
                                           if(status =='open'){
                                               if(FacliLst.containskey(accid)){
                                                   account act = FacliLst.get(accid);
                                                   double opn = act.of_open_optys__c == Null ? 0 : act.of_open_optys__c;
                                                   act.of_open_optys__c=(opn+optyCount);
                                                   system.debug('Open>>>>>');
                                                   FacliLst.put(act.id,act);
                                                   
                                               }else{
                                                   account acc = new account(id=accid);
                                                   acc.of_open_optys__c=optyCount;
                                                   system.debug('Opeelse>>>>>');
                                                   FacliLst.put(acc.id,acc);  
                                               }
                                           }
                                           if(status != 'Open'){
                                               if(FacliLst.containskey(accid)){
                                                   account act = FacliLst.get(accid);
                                                   system.debug('Enrolled1>>>>'+act.of_enrolled_optys__c);
                                                   double enrol = act.of_enrolled_optys__c == Null ? 0 : act.of_enrolled_optys__c;
                                                   act.of_enrolled_optys__c =(enrol+optyCount);
                                                   system.debug('Enrolled222>>>>'+act.of_enrolled_optys__c);
                                                   //system.debug('Enrolled>>>>');
                                                   FacliLst.put(act.id,act);
                                               }else{
                                                   account acc = new account(id=accid);
                                                   acc.of_enrolled_optys__c =optyCount;
                                                   system.debug('Enrolledelse>>>>>'+acc.of_enrolled_optys__c);
                                                   FacliLst.put(acc.id,acc);  
                                               }
                                           }
                                       }
        }
        set<id> failedFacilities = new Set<id>();
          for (Database.SaveResult saveResult : Database.update(FacliLst.values(),false)) {
            if (!saveResult.isSuccess()) {
                failedFacilities.add(saveResult.getId());
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