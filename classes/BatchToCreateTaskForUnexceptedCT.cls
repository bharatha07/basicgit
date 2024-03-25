/**
* @File Name          : BatchToCreateTaskForUnexceptedCT .cls
* @Description        : Batch to find all assets with type Cord Tissue and to check stored ct is greater than Quoted CT, then creating a task.
* @Author             : Teksystems
* @story              : SFDC-1710
* @Created date       : 5/17/2021
**/
global class BatchToCreateTaskForUnexceptedCT implements Database.Batchable<sObject>,Database.Stateful{
    global List<String> oppErrors = new List<String>();
    global List<String> taskErrors = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Opportunity__c,Deposit_ID__c,Opportunity__r.OwnerId,Type__c,Status,FreezeDate__c,Associated_Sample__c,Opportunity__r.Stored_CT__c,Opportunity__r.Quoted_of_CT__c  from Asset where Status=\'Stored\' and Type__c=\'Cord Tissue\' and FreezeDate__c >='+Label.UnExpectedCT_Start+
            'and FreezeDate__c <='+Label.UnExpectedCT_End; 
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope){
        List<Task> taskList= new List<Task>();
        set<string> taskSubject = new set<string>();
        Set<Id> oppIds = new Set<Id>();
        set<id> optyIds =new set<id>();
        for(Asset opsAss:scope){
            oppIds.add(opsAss.Opportunity__c);
        }
        Map<id,task> taskMap = new Map<id,task>();
        if(oppIds!=null && !oppIds.isEmpty()){
            taskMap = new Map<id,task>([Select id,Subject,WhatId from Task where WhatId IN:oppIds AND Subject ='Unexpected Cord Tissue Sample Stored']);
        }
        Map<id,id> OppIdsToTaskId = new Map<Id,Id>();
        if(taskMap!=null && !taskMap.isEmpty()){
            for(Task t:taskMap.values()){
                OppIdsToTaskId.put(t.whatId,t.id);
            }
        }
        //Loop through the opportunities that are inscope and create a task
        for(Asset ass:scope){
            if(!OppIdsToTaskId.containsKey(ass.Opportunity__c)){
                 integer storedCtCount = ass.Opportunity__r.Quoted_of_CT__c !=null ?Integer.valueOf(ass.Opportunity__r.Quoted_of_CT__c) : 0;
                //check if stored of ct value is greater than Quoted of CT.
                if(ass.Opportunity__r.Stored_CT__c > storedCtCount && !optyIds.contains(ass.Opportunity__c)){
                    system.debug('storedCtCount----'+storedCtCount);
                    for(integer i=0;i<(ass.Opportunity__r.Stored_CT__c-storedCtCount);i++){
                        Task unExpectedCTTask = new Task();
                        unExpectedCTTask.Subject='Unexpected Cord Tissue Sample Stored';
                        unExpectedCTTask.Status='Open';
                        unExpectedCTTask.WhatId=ass.Opportunity__c;
                        unExpectedCTTask.ActivityDate=Date.Today()+1;
                        unExpectedCTTask.OwnerId=ass.Opportunity__r.OwnerId;
                        unExpectedCTTask.Task_Type__c='To Do';
                        unExpectedCTTask.Description='Unexpected Cord Tissue sample received at Lab, verify DCS for enrollment';
                        taskList.add(unExpectedCTTask);
                        optyIds.add(ass.Opportunity__c);
                    }
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
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Unexpected CT Catchup Batch', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }  
    global void finish(Database.BatchableContext BC){   
        
    }
}