/**
* @File Name          : BatchToCreateTaskForCollectionDevice .cls
* @Description        : Batch to find all the optys which are stored and asset freeze date is 7 days ago from today.
* @Author             : Teksystems
* @story              : SFDC-1667
* @Created date       : 5/4/2021
**/
global class BatchToCreateTaskForCollectionDevice implements Database.Batchable<sObject>,Database.Stateful{
    global List<String> oppErrors = new List<String>();
    global List<String> taskErrors = new List<String>();
    global final Date FreezCheck = system.today().addDays(-7);
    global final Date FreezCheck1 = system.today().addDays(-6);
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Opportunity__c,Deposit_ID__c,Opportunity__r.OwnerId,Type__c,Status,FreezeDate__c,Associated_Sample__c,SerialNumber  from Asset where Opportunity__r.Status__c =\'Stored\' and FreezeDate__c >=:FreezCheck and FreezeDate__c <=:FreezCheck1 and Status=\'Stored\''; 
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope){
        List<Task> taskList= new List<Task>();
        
        for(Asset ass:scope){
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
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Collection device Congrats Call', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }

    }  
    global void finish(Database.BatchableContext BC){   
        
    }
}