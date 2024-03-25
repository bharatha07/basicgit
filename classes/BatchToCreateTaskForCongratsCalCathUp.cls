/**
* @File Name          : BatchToCreateTaskForCongratsCalCathUp .cls
* @Description        : Batch to find all the optys which are stored and asset freeze date between 14th April to 6th May.
* @Author             : Teksystems
* @story              : SFDC-1709
* @Created date       : 5/17/2021
**/
global class BatchToCreateTaskForCongratsCalCathUp implements Database.Batchable<sObject>,Database.Stateful{
    global List<String> oppErrors = new List<String>();
    global List<String> taskErrors = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Opportunity__c,SerialNumber,Opportunity__r.OwnerId,Type__c,Status,FreezeDate__c,DiscontinuedStorage__c  from Asset where Status=\'Stored\' and FreezeDate__c >='+label.Congrats_Call_Start +
            ' and DiscontinuedStorage__c =false'; 
        system.debug('query---'+query);
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope){
        List<Task> taskList= new List<Task>();
        set<string> taskSubject = new set<string>();
        Set<Id> oppIds = new Set<Id>();
        for(Asset opsAss:scope){
            oppIds.add(opsAss.Opportunity__c);
            string astSub =opsAss.Type__c+' Stored - Collection Device:'+opsAss.SerialNumber;
            taskSubject.add(astSub);
        }
        Map<id,task> taskMap = new Map<id,task>();
        if(oppIds!=null && !oppIds.isEmpty()){
            taskMap = new Map<id,task>([Select id,Subject,WhatId from Task where WhatId IN:oppIds AND Subject IN : taskSubject]);
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
                Task congratsTask = new Task();
                congratsTask.Subject=ass.Type__c+' Stored - Collection Device:'+ass.SerialNumber;
                congratsTask.Status='Open';
                congratsTask.WhatId=ass.Opportunity__c;
                congratsTask.ActivityDate=Date.Today();
                congratsTask.OwnerId=ass.Opportunity__r.OwnerId;
                congratsTask.Task_Type__c='To Do';
                congratsTask.Task_Sub_Type__c='Congrats Call';
                taskList.add(congratsTask);
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
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Collection device Congrats Call CatchUp', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }  
    global void finish(Database.BatchableContext BC){   
        
    }
}