/**
 * @File Name          : oppContactRoleCreatebatch_HistoricalData.cls
 * @Description        : 
 * @Author             : Tejaswini(TEKsystems)
 * @Created date       : 07/06/2020
 * 
**/
@isTest
public with sharing class oppContactRoleCreatebatch_HisTest {
    @isTest
    static void unitTest(){
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c,personaccount__c,PersonAccount__r.personContactId from OpportunityContact__c];
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = oppContactList[0].Opportunity__c, isPrimary = false, ContactId = oppContactList[0].PersonAccount__r.personContactId, role = 'Partner' );
        insert ocr;
        Test.startTest();
        oppContactRoleCreatebatch_HistoricalData b = new oppContactRoleCreatebatch_HistoricalData('Open');
        Database.executeBatch(b);
        Test.stopTest();
        List<OpportunityContactRole> ocrList = [Select id,Role,isPrimary from opportunitycontactRole];
        System.assertEquals(oppList.size(),ocrList.size() );
    }
}