/**
 * @File Name          : oppContactRoleCreatebatch_Test.cls
 * @Description        : 
 * @Author             : Tejaswini(TEKsystems)
 * @Created date       : 6/3/2020
 * 
**/
@isTest
public with sharing class oppContactRoleCreatebatch_Test {
    @isTest
    static void unitTest(){
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
        Test.startTest();
        oppContactRoleCreatebatch b = new oppContactRoleCreatebatch(true,false);
        Database.executeBatch(b);
        Test.stopTest();
        List<OpportunityContactRole> ocrList = [Select id,Role,isPrimary from opportunitycontactRole];
        System.assertEquals(oppList.size(),ocrList.size() );
    }
    @isTest
    static void unitTest1(){
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c,PersonAccount__r.PersonContactId from OpportunityContact__c];
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityId = oppContactList[0].opportunity__c,contactId = oppContactList[0].PersonAccount__r.PersonContactId,Role = 'Father' );
        insert ocr;
        List<OpportunityContact__c> oppConListToUpdate = new List<OpportunityContact__c>();
        for(OpportunityContact__c oc:oppContactList){
            oc.Role__c = 'Mother';
            oppConListToUpdate.add(oc);
        }
        Update oppConListToUpdate;
        Test.startTest();
        oppContactRoleCreatebatch b = new oppContactRoleCreatebatch(false,true);
        Database.executeBatch(b);
        Test.stopTest();
    }
    @isTest
    static void unitTest2(){
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
        Test.startTest();
        SchedulableContext sc = null;
        oppContactRoleCreatebatch_Schedule sch = new oppContactRoleCreatebatch_Schedule();
        sch.execute(sc);
        Test.stopTest();
    }
    
}