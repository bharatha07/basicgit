/**
* @File Name          : LeadTriggerHelperTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 6/24/2020, 2:32:20 PM
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    6/17/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class LeadTriggerHelperTest {
    
    
    public static testMethod void unitTest1() {
        User u = TestDataFactory.createTestUser('Client Support Specialist');
        String message = 'test';
        System.runAs(u){
            test.startTest();
            Lead leadRec = new Lead();
            Lead leadRec1=new Lead();
            leadRec.FirstName='tek lead';
            leadRec.LastName='lead for test';
            leadRec.LeadSource='CSS Referral';
            leadRec.Phone = '1234568901';
            leadRec.Email='abc@test12gmail.com';
            leadRec.Due_Date__c = system.today().addDays(3);
            leadRec.OwnerId = UserInfo.getUserId();
            insert leadRec;
            try{
                leadRec1.FirstName='tek lead';
                leadRec1.LastName='tek lead';
                leadRec1.LeadSource='CSS Referral';
                leadRec1.Phone = '1234568901';
                leadRec1.Email='abc@test12gmail.com';
                leadRec1.Due_Date__c = system.today().addDays(3);
                leadRec1.OwnerId = UserInfo.getUserId();
                
                insert leadRec1; 
            }
            catch(DMLexception e){ 
                system.debug('value is ::'+e.getMessage());
                message=e.getMessage();  
            }
            test.stopTest();
            Lead l=[select id,status from Lead where FirstName='tek lead' limit 1];
            // System.assertEquals('Qualified', l.Status);
            // System.assertNotEquals('test', message);
        } 
    }
    public static testMethod void unitTest2(){
        User u = TestDataFactory.createTestUser('Marketo Sync');
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        system.runAs(u){
            Test.Starttest();
            List<Account> consumerAccountList = new List<Account>();
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',phone='1234568901',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            Account consumerAccount1 = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst7',LastName = 'TestLast7',phone='1234568901',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test1.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            consumerAccountList.add(consumerAccount);
            consumerAccountList.add(consumerAccount1);
            insert consumerAccountList;
            List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
            List<Lead> leadList = new List<lead>();
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified',Lead_Assignment__c = 'Test Lead Assign');
            Lead leadRec3 = new Lead(FirstName='test lead3',LastName='tek leadNew Rec3',LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified',Lead_Assignment__c = 'Test Lead Assign');
            Lead leadRec2 = new Lead(FirstName='test lead2',LastName='To Update',LeadSource='Phone',Phone = '1212121212',Email='abc1112@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified',Lead_Assignment__c = null);
            leadList.add(leadRec1);
            leadList.add(leadRec3);
            leadList.add(leadRec2);
            system.debug('leadList----'+leadList);
            insert leadList;
            system.debug('leadList----'+leadList);
            
            Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True,type='Outbound Dialer');
            insert camp1;
            
            //CampaignMemberStatus campStatus= new CampaignMemberStatus(CampaignId=camp1.id,Label='Ready');
            //insert campStatus;
            
            //CampaignMemberStatus campStatus1= new CampaignMemberStatus(CampaignId=camp1.id,Label='Remove Pending');
            //insert campStatus1;
            
            List<CampaignMember> CampMemb1 = new List<CampaignMember>();
            CampMemb1.add(new CampaignMember(LeadId =leadRec2.id , CampaignId = camp1.id, Status = 'Ready'));
            insert CampMemb1;
            
            leadRec2.Lead_Assignment__c = 'Test Lead assign value';
            update leadRec2;
            Test.Stoptest();
        }
        
    }
    
    public static testMethod void beforeUpdateTest(){
        User u = TestDataFactory.createTestUser('Marketo Sync');
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CSS Referral').getRecordTypeId();
        system.runAs(u){
            Test.Starttest();
            List<Lead> leadList = new List<lead>();
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',Email='',RecordTypeId=RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Manually Qualified',Marketo_Sync__c=false);
            leadList.add(leadRec1);
            
            insert leadList;
            Lead ld1 = [select id,FirstName,Marketo_Sync__c,Email from Lead where FirstName='test lead1' limit 1];
            ld1.Email='test111@test.com';
            update ld1;
            
            Lead ld2 = [select id,FirstName,Marketo_Sync__c,Email from Lead where Email='test111@test.com' limit 1];
            System.assertEquals(ld2.Marketo_Sync__c, true);
            Test.Stoptest();
        }
        
    }
    //adding
    public static testMethod void unitTest6() {
        User u = TestDataFactory.createTestUser('Client Support Specialist');
        String message = 'test';
        //  System.runAs(u){
        test.startTest();
        Lead leadRec = new Lead();
        Lead leadRec1=new Lead();
        leadRec.FirstName='tek lead';
        leadRec.LastName='lead for test';
        leadRec.LeadSource='CSS Referral';
        leadRec.Phone = '1234568901';
        leadRec.Email='abc@test12gmail.com';
        leadRec.Due_Date__c = system.today().addDays(3);
        leadRec.OwnerId = UserInfo.getUserId();
        leadRec.Lead_Assignment__c = 'Test Lead assign value';
        // leadRec.IsConverted = true;
        insert leadRec;
        try{
            leadRec1.FirstName='tek lead';
            leadRec1.LastName='lead for test';
            leadRec1.LeadSource='CSS Referral';
            leadRec1.Phone = '1234568901';
            leadRec1.Email='abc1@test12gmail.com';
            leadRec1.Due_Date__c = system.today().addDays(4);
            leadRec1.OwnerId = UserInfo.getUserId();
            leadRec1.Lead_Assignment__c = 'Test Lead assign value';
            leadRec1.IsConverted = true;
            leadRec1.Status = 'Qualified';
            
            insert leadRec1; 
        }
        catch(DMLexception e){ 
            system.debug('value is 2::'+e.getMessage());
            message=e.getMessage();  
        }
        test.stopTest();
        Lead l=[select id,status from Lead where FirstName='tek lead' limit 1];
        // System.assertEquals('Qualified', l.Status);
        // System.assertNotEquals('test', message);
        // } 
    }
    //For story SFDC-1722.  
    public static testMethod void timeZone(){
        User u = TestDataFactory.createTestUser('Marketo Sync');
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        usZipCode.State__c='ton';
        usZipCode.Time_Zone__c='(GMT-05:00) Eastern Time (US & Canada)';
        update usZipCode;
        system.runAs(u){
            Test.Starttest();
            List<Lead> leadList = new List<lead>();
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',Email='',RecordTypeId=RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Manually Qualified',Marketo_Sync__c=false,PostalCode='10009');
            leadList.add(leadRec1);
            
            insert leadList;
        }
        
    }
    
}