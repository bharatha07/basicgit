/*************************************************
*For Component Name:OpportunityClose_batch
Description: Test Case to change status of opportunity to close
Story : CBRSFDC8-246,SFDC-1839
Created By: Teksystems
**************************************************/
@isTest
public class OpportunityClose_batch_test{
    @istest
    public static void unitTest1(){
        
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<Account> providerAccList = TestDataFactory.createProviderAccounts();
        List<Account> faciltiyAccList = TestDataFactory.createFacilityAccounts();
        List<Provider_Facility__c> providerFaciltiyList = TestDataFactory.providerFacilityRecords(faciltiyAccList,providerAccList);
        
        
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipOpportunityValidation__c = true;
        upsert byPassSetting;
        
        oppList[0].Due_Date__c = system.today().addDays(-15);
        oppList[0].Enrollment_Date__c = null;
        oppLIst[0].Status__c = 'Open';
        
        oppList[1].Due_Date__c = system.today().addDays(-22);
        oppList[1].Storage_Date__c = null;
        oppList[1].Status__c = 'Enrolled';
        oppList[1].Enrollment_Date__c = system.today();
        update oppList;
        
        
        list<opportunity> opplis = [select id,Status__c,Loss_Reason__c, Due_Date__c, Enrollment_Date__c,StageName, Storage_Date__c,Type,Stored_CB__c,Stored_CT__c from opportunity where Id =:oppList[1].id];
        opplis[0].Status__c = 'Enrolled';
        update opplis[0];
        
        test.Starttest();
        OpportunityClose_batch oppbatch = new OpportunityClose_batch();
        DataBase.executeBatch(oppbatch);
        Test.Stoptest();
    }
    
   
}