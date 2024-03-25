/**
* @File Name          : OpportunityTaskCreationBatch .cls
* @Description        : Batch to find all the optys which are 7 and 16 days past due date and create task for those.
* @Author             : Teksystems
* @story              : SFDC-1037
* @Created date       : 5/10/2020
**/
global class OpportunityTaskCreationBatch implements Database.Batchable<sObject>,Database.Stateful{
    global List<String> oppErrors = new List<String>();
    global List<String> taskErrors = new List<String>();
    global final Date DueCheck21 = system.today().addDays(-21);
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Status__c,Stored_CB__c,Stored_CT__c, Due_Date__c, StageName, Storage_Date__c,X16_Days_checkbox__c,X7_Days_checkbox__c,OwnerId FROM Opportunity Where Status__c=\'Enrolled\' AND Due_Date__c >: DueCheck21 AND Stored_CB__c = NULL AND Stored_CT__c = NULL'; 
                 
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('Inside execute method');
        system.debug('scope=====>>>>>'+scope);
        List<Opportunity> opplist= new List<Opportunity>();
        List<Task> taskList= new List<Task>();
        
        for(Opportunity opp:scope){
            Integer noDays = 0;
             noDays += (Date.valueOf(opp.Due_Date__c)).daysBetween(system.today());
            system.debug('noDays>>>'+noDays);
            if(noDays > 7 && noDays < 17 && opp.X7_Days_checkbox__c==false){ 
                system.debug('noDays>>>1'+noDays);
                Task pastDue = new Task();
                pastDue.Subject='Due Date passed No Storage';
                pastDue.Status='Open';
                pastDue.WhatId=opp.id;
                pastDue.ActivityDate=Date.Today()+1;
                pastDue.OwnerId=opp.OwnerId;
                pastDue.Task_Type__c='To Do';
                pastDue.Task_Sub_Type__c='Past Due';
                taskList.add(pastDue);
                
                opp.X7_Days_checkbox__c=true;
                opplist.add(opp) ;
            }
            
            else if(noDays > 16 && noDays < 22 && opp.X16_Days_checkbox__c==false){
                system.debug('noDays>>>2'+noDays);
                Task canPend = new Task();
                canPend.Subject='Auto Cancellation in 6 days';
                canPend.Status='Open';
                canPend.WhatId=opp.id;
                canPend.ActivityDate=Date.Today()+1;
                canPend.OwnerId=opp.OwnerId;
                canPend.Task_Type__c='To Do';
                canPend.Task_Sub_Type__c='Cancellation Pending';
                taskList.add(canPend);
                
                opp.X16_Days_checkbox__c=true;
                opplist.add(opp) ;
            }
            
        }
        system.debug('opplist=====>>>>>'+opplist);
        
        List<Database.SaveResult> saveResultsTask = Database.insert(taskList,false);
        for (Database.SaveResult saveResult1 : saveResultsTask) {
            if (!saveResult1.isSuccess()) {
                for (Database.Error e : saveResult1.getErrors()) {
                    system.debug('error1..................'+e.getMessage());
                    taskErrors.add(e.getMessage());
                }
            }
        }
        system.debug(taskErrors);
        system.debug('error size'+taskErrors.size());
        
        List<Database.SaveResult> saveResultsOpp = Database.update(opplist,false);
        for (Database.SaveResult saveResult : saveResultsOpp) {
            if (!saveResult.isSuccess()) {
                for (Database.Error e : saveResult.getErrors()) {
                    system.debug('error..................'+e.getMessage());
                    oppErrors.add(e.getMessage());
                }
            }
        }
        
        system.debug(oppErrors);
        system.debug('error size'+oppErrors.size());
        
                
    }  
    global void finish(Database.BatchableContext BC){   
        
    }
}