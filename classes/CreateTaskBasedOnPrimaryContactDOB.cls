/*************************************************************************************************
* @description This method is used to create task if primary contact DOB is less than 18 years old.
* @param - Trigger.new
* @story - SFDC-1860
* @return Void
* @date - 27-Jul-2021 (Teksystems)
*/
public class CreateTaskBasedOnPrimaryContactDOB {
    
    public static void validateAcctDoB(Set<id> OpportunityIds){
        List<Task> taskList= new List<Task>();
        set<string> taskSubject = new set<string>();
        List<OpportunityContact__c> OptyContactList = new List<OpportunityContact__c>();
        taskSubject.add('Verify Primary Contact DOB');
        Set<Id> oppIds = new Set<Id>();
        if(!OpportunityIds.isEmpty()){
            for(OpportunityContact__c primOppConc: [select id,PersonAccount__c,Opportunity__c,PersonAccount__r.PersonBirthdate from OpportunityContact__c where Primary__c=true and Opportunity__c in :OpportunityIds and PersonAccount__r.PersonBirthdate !=NULL]){
                date dt =primOppConc.PersonAccount__r.PersonBirthdate;
                Integer days = dt.daysBetween(Date.Today());
                Integer age = Integer.valueOf(days/365.25);
                system.debug('age----'+age);
                if(age < 18){
                    oppIds.add(primOppConc.Opportunity__c);
                    OptyContactList.add(primOppConc);                    
                }
            }
        }
        Map<id,task> taskMap = new Map<id,task>();
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        if(oppIds!=null && !oppIds.isEmpty()){
            taskMap = new Map<id,task>([Select id,Subject,WhatId from Task where WhatId IN:oppIds AND Subject IN : taskSubject]);
            for(opportunity opp1 :[select id,ownerid from opportunity where id IN:oppIds] ){
                oppMap.put(opp1.id,opp1);
            }
        }
        Map<id,id> OppIdsToTaskId = new Map<Id,Id>();
        if(taskMap!=null && !taskMap.isEmpty()){
            for(Task t:taskMap.values()){
                OppIdsToTaskId.put(t.whatId,t.id);
            }
        }
        
        if(!OptyContactList.isEmpty()){
            for(OpportunityContact__c optyCon : OptyContactList){
                if(!OppIdsToTaskId.containskey(optyCon.Opportunity__c) && oppMap.containsKey(optyCon.Opportunity__c)){
                    opportunity opp = oppMap.get(optyCon.Opportunity__c);
                    Task dobTask = new Task();
                    dobTask.Subject='Verify Primary Contact DOB';
                    dobTask.Status='Open';
                    dobTask.WhatId=optyCon.Opportunity__c;
                    dobTask.ActivityDate=system.today();
                    dobTask.OwnerId=opp.OwnerId;
                    dobTask.Task_Type__c='To Do';
                    dobTask.Task_Sub_Type__c='Follow Up';
                    taskList.add(dobTask);
                }
            }
        }
        if(!taskList.isEmpty()){
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            string ErrDetail;
            for(Database.SaveResult sr : Database.insert(taskList,false)){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }  
            } 
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Primary Contact DOB Less Than 18', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
    }
    
}