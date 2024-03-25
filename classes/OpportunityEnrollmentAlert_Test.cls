@isTest
public class OpportunityEnrollmentAlert_Test{
    @istest static void unitTest1(){
        List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(consumerAccList);
        Test.StartTest();
        
        OpportunityEnrollmentAlert oEA = new OpportunityEnrollmentAlert();
        id batchId = Database.executeBatch(oEA);
        Test.stopTest();
    }
    @istest static void unitTest2(){
        List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(consumerAccList);
        
        Test.StartTest();
        List<opportunity> oppList1 = [select id,Primary_contact__c,Email_Address__c from Opportunity];
        OpportunityEnrollmentAlert oEA = new OpportunityEnrollmentAlert();
        oEA.reSendEmails.put(oppList1[0].Primary_contact__c,oppList1[0].Email_Address__c);
        Database.executeBatch(oEA);
        
        Test.stopTest();
    }
    @istest static void unitTest3(){
        List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(consumerAccList);
        
        Test.StartTest();
        ScheduleOpportunityEnrollmentAlert obj = new ScheduleOpportunityEnrollmentAlert();
        obj.execute(null);
        
        Test.stopTest();
    }
}