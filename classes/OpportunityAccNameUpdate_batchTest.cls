/*************************************************
*Component Name:OpportunityAccNameUpdate_batchTest
Description: Batch Job to update account name from opty contact to Opportunity
Created By: Teksystems
**************************************************/
@istest
private class OpportunityAccNameUpdate_batchTest {
     @TestSetup
    public static void dataSetup(){
       // List<Account> acclist=TestDataFactory.createConsumerAccounts();
       
         Id consumerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst1',LastName = 'TestLast1',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-2),PersonEmail = 'TestPersonEmail1@test.com',BillingStreet = 'Test12',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
       
        insert accList;
        System.debug('We are here after account'+[SELECT Id FROM OpportunityContact__c]);
        opportunity opp=new opportunity();
        opp.Name='Test1JK';
        opp.Baby_Name__c='babyTest1';
        opp.Status__c='Stored';
        opp.StageName='Open';
        opp.Storage_Date__c=system.today();
        opp.CloseDate=system.today()+3;
        opp.AccountId = acclist[0].Id;
        insert opp;
        System.debug('We are here after opp'+[SELECT Id FROM OpportunityContact__c]);
       
        
    } 
    static testmethod void Oppo_testbatch(){
       List<OpportunityContact__c> oppContactList = new List<OpportunityContact__c>();
        Opportunity testOpty=[select id ,Baby_Name__c, name from Opportunity where Baby_Name__c='babyTest1' limit 1];
        Account testAcc=[Select id,BillingCity,PersonEmail,name from account where PersonEmail ='TestPersonEmail1@test.com' LIMIT 1 ];
        oppContactList.add(new OpportunityContact__c(Opportunity__c = testOpty.id ,Primary__c=true,PersonAccount__c = testAcc.Id ,Role__c = 'Mother'));
       system.debug('rec for acc ::'+testAcc);
         system.debug('rec for opty ::'+testOpty);
        //insert oppContactList;
         system.debug('rec for opty con ::'+oppContactList);
        System.debug('We are here  now'+[SELECT Id FROM OpportunityContact__c]);
          
        Test.startTest();
        //OpportunityAccNameUpdate_batchTest obj =new OpportunityAccNameUpdate_batchTest();
        DateTime dtstart = System.now().addDays(-1);
        DateTime dtstop = System.now().addDays(1);
        Database.executeBatch(new OpportunityAccNameUpdate_batch(DateTime.newInstanceGmt(dtstart.year(), dtstart.month(),  dtstart.day(),  dtstart.hour(),  dtstart.minute(),  dtstart.second()),
                                                                 DateTime.newInstanceGmt(dtstop.year(), dtstop.month(),  dtstop.day(),  dtstop.hour(),  dtstop.minute(),  dtstop.second())), 200);
       // Database.executeBatch(obj,200);
        Test.stopTest();
        
       // Opportunity oppa=[select id ,Stored_CB__c, name from opportunity where id=:opp.id limit 1];
       // system.assertEquals(oppa.Stored_CB__c, 1);
       
        
    }
}