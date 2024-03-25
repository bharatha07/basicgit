/**
* @File Name          : OpportunityTaskCreationBatchTest .cls
* @Description        : TestBatch to find all the optys which are 7 and 16 days past due date and create task for those.
* @Author             : Teksystems
* @story              : SFDC-1037
* @Created date       : 5/10/2020
**/
@istest
public class OpportunityTaskCreationBatchTest {
    
    @istest
    public static void unitTest1(){
        
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<Account> providerAccList = TestDataFactory.createProviderAccounts();
        List<Account> faciltiyAccList = TestDataFactory.createFacilityAccounts();
        
        test.Starttest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipOpportunityValidation__c = true;
        upsert byPassSetting;
        
        oppList[0].Due_Date__c = system.today().addDays(-10);
        oppList[0].Status__c = 'Enrolled';
        oppList[0].Stored_CB__c = null;
        oppList[0].Stored_CT__c = null;
        update oppList;
        
        OpportunityTaskCreationBatchScheduled oppbatch = new OpportunityTaskCreationBatchScheduled();
        oppbatch.execute(null);
        Test.Stoptest();
        Opportunity oppTest = [select id,Due_Date__c,Storage_Date__c,X16_Days_checkbox__c,X7_Days_checkbox__c,Status__c,StageName,Enrollment_Date__c,Stored_CB__c,Stored_CT__c,OwnerId from opportunity where id =:oppList[0].id];
        system.assertEquals(true,oppTest.X7_Days_checkbox__c);
        
        Task testTask =[select id,WhatId,ActivityDate,OwnerId,Status,Subject,Task_Type__c,Task_Sub_Type__c from task where WhatId =:oppList[0].id];
        system.assertEquals(oppList[0].id, testTask.WhatId);
        system.assertEquals(Date.today()+1, testTask.ActivityDate);
        system.assertEquals(oppTest.OwnerId, testTask.OwnerId);
        system.assertEquals('Open', testTask.Status);
        system.assertEquals('Due Date passed No Storage', testTask.Subject);
        system.assertEquals('To Do', testTask.Task_Type__c);
        system.assertEquals('Past Due', testTask.Task_Sub_Type__c);
        
    }
    
    @istest
    public static void unitTest2(){
        
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<Account> providerAccList = TestDataFactory.createProviderAccounts();
        List<Account> faciltiyAccList = TestDataFactory.createFacilityAccounts();
        
        test.Starttest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipOpportunityValidation__c = true;
        upsert byPassSetting;
        
        oppList[0].Due_Date__c = system.today().addDays(-20);
        oppList[0].Status__c = 'Enrolled';
        oppList[0].Stored_CB__c = null;
        oppList[0].Stored_CT__c = null;
        update oppList;
        
        OpportunityTaskCreationBatchScheduled oppbatch = new OpportunityTaskCreationBatchScheduled();
        oppbatch.execute(null);
        Test.Stoptest();
        Opportunity oppTest = [select id,Due_Date__c,Storage_Date__c,X16_Days_checkbox__c,X7_Days_checkbox__c,Status__c,StageName,Enrollment_Date__c,Stored_CB__c,Stored_CT__c,OwnerId from opportunity where id =:oppList[0].id];
        system.assertEquals(true,oppTest.X16_Days_checkbox__c);
        
        Task testTask =[select id,WhatId,ActivityDate,OwnerId,Status,Subject,Task_Type__c,Task_Sub_Type__c from task where WhatId =:oppList[0].id];
        system.assertEquals(oppList[0].id, testTask.WhatId);
        system.assertEquals(Date.today()+1, testTask.ActivityDate);
        system.assertEquals(oppTest.OwnerId, testTask.OwnerId);
        system.assertEquals('Open', testTask.Status);
        system.assertEquals('Auto Cancellation in 6 days', testTask.Subject);
        system.assertEquals('To Do', testTask.Task_Type__c);
        system.assertEquals('Cancellation Pending', testTask.Task_Sub_Type__c);
        
    }
}