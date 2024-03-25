/**
* @File Name          : BatchToFindLeadPhoneNumberTest .cls
* @Description        : Batch to create lead and duplicate account with phone and mobile number.
* @Author             : Teksystems
* @story              : SFDC-1413
* @Created date       : 30-JAN-2020 (Teksystems)
**/
@istest
public class BatchToFindLeadPhoneNumberTest {
    
    @istest
    public static void BatchToFindLeadPhoneNumberTestMethod(){
        
        List<Lead> leadList = new List<Lead>();
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        User u = TestDataFactory.createTestUser('Marketo Sync');
        
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        consumerAccountList[0].phone = '1234568901';
        Update consumerAccountList[0];
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        
        system.runAs(u){
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            leadList.add(leadRec1);
            insert leadList;
            
            system.debug('leadList=='+leadList);
        }
        Test.startTest();
        BatchToFindLeadPhoneNumberScheduled batchable = new BatchToFindLeadPhoneNumberScheduled();
        batchable.execute(null);
        test.stopTest();
        OpportunityContact__c oppContact = [select id,Opportunity__c, PersonAccount__c from OpportunityContact__c limit 1];
        system.assertEquals(optyList[0].id, oppContact.Opportunity__c);
    }
    @istest
    public static void BatchToFindLeadPhoneNumberTestMethod1(){
        
        List<Lead> leadList = new List<Lead>();
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        User u = TestDataFactory.createTestUser('Marketo Sync');
        
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        consumerAccountList[0].PersonMobilePhone = '1234568900';
        consumerAccountList[1].PersonMobilePhone = '1234568900';
        Update consumerAccountList[0];
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        optyList[0].Enrollment_Date__c= null;
        optyList[0].AccountId=consumerAccountList[0].id;
        optyList[1].AccountId=consumerAccountList[0].id;
        optyList[1].status__c='Enrolled';
        optyList[1].Enrollment_Date__c=system.now().addhours(1);
        update optyList;
        
        system.runAs(u){
            Lead leadRec1 = new Lead(FirstName='test lead11',LastName='tek leadNew Recc',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',MobilePhone = '1234568900',Email='abc11@test1gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            leadList.add(leadRec1);
            insert leadList;
            
            system.debug('leadList=='+leadList);
        }
        Test.startTest();
        BatchToFindLeadPhoneNumberScheduled batchable = new BatchToFindLeadPhoneNumberScheduled();
        batchable.execute(null);
        test.stopTest();
        OpportunityContact__c oppContact = [select id,Opportunity__c, PersonAccount__c from OpportunityContact__c limit 1];
        system.assertEquals(optyList[0].id, oppContact.Opportunity__c);

    }
    @istest
    public static void BatchToFindLeadPhoneNumberTestMethod2(){
        
        List<Lead> leadList = new List<Lead>();
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        User u = TestDataFactory.createTestUser('Marketo Sync');
        
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        consumerAccountList[0].Phone = '1234568902';
        consumerAccountList[1].Phone = '1234568902';
        Update consumerAccountList[0];
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        optyList[0].Enrollment_Date__c= null;
        optyList[0].AccountId=consumerAccountList[0].id;
        optyList[1].AccountId=consumerAccountList[0].id;
        optyList[1].status__c='Enrolled';
        optyList[1].Enrollment_Date__c=system.now().addhours(1);
        update optyList;
        
        system.runAs(u){
            Lead leadRec1 = new Lead(FirstName='test lead111',LastName='tek leadNew Reccc',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568902',Email='abc11@test1gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            leadList.add(leadRec1);
            insert leadList;
            
            system.debug('leadList=='+leadList);
        }
        Test.startTest();
        BatchToFindLeadPhoneNumberScheduled batchable = new BatchToFindLeadPhoneNumberScheduled();
        batchable.execute(null);
        test.stopTest();
        OpportunityContact__c oppContact = [select id,Opportunity__c, PersonAccount__c from OpportunityContact__c limit 1];
        system.assertEquals(optyList[0].id, oppContact.Opportunity__c);

    }
}