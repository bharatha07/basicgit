@isTest
public class OpportunityTaskCreateTest{

    public static testmethod void testBatch(){
        test.StartTest();
        
       List<Account> accList = TestDataFactory.createConsumerAccounts();
       List<Opportunity> OppList = TestDataFactory.createOpportunities(accList);
      
      OppList[0].Storage_Date__c = system.today().addMonths(-60).addDays(90);
       OppList[0].Status__c = 'Stored';
       OppList[0].Program_Enrolled_in__c  = 'Newborn Possibilities Program - Designated Treatment Protocol';
       update OppList;
       
        ScheduleOpportunityTaskCreate oppbatch = new ScheduleOpportunityTaskCreate();
       String cronstr = '0 30 00 * * ?';
       id jobid = System.schedule('Test opportunity Stage1'+system.now(), cronStr, oppbatch);
        Test.Stoptest();
    }
      public static testmethod void testBatch1(){
        test.StartTest();
        
        List<Account> accList = TestDataFactory.createConsumerAccounts();
       List<Opportunity> OppList = TestDataFactory.createOpportunities(accList);
       
       OppList[0].Storage_Date__c = system.today().addMonths(-60).addDays(90);
       OppList[0].Status__c = 'Stored';
       OppList[0].Program_Enrolled_in__c  = 'Newborn Possibilities Program - Designated Treatment Protocol';
       update OppList;
        List<opportunity> optylist = [Select id,ownerId,Storage_Date__c from Opportunity where id=:opplist[0].id];
        List<Task> taskList = new List<Task>();
         Task t = new Task();
                t.Subject = 'Call';
                t.WhatId=optylist[0].ID;    
                t.OwnerId = optylist[0].ownerId;
                t.Status ='Open';
                t.ActivityDate= optylist[0].Storage_Date__c.Date().addMonths(60).addDays(-30);
                t.Priority='High';
                t.Description='Approaching end of NPP free storage period. Contact client to discuss conversion to family banking.';
                
               // Add all tasks to a list  
                taskList.add(t);
                insert taskList;
        
        ScheduleOpportunityTaskCreate oppbatch = new ScheduleOpportunityTaskCreate();
       String cronstr = '0 30 00 * * ?';
       id jobid = System.schedule('Test opportunity Stage1'+system.now(), cronStr, oppbatch);
        Test.Stoptest();
      }
    
}