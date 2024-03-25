/**
* @File Name          : LeadConvertBatchOnDailyBasisTest .cls
* @Description        : Batch to convert leads with lead assignment value.
* @Author             : Teksystems
* @story              : SFDC-2083
* @Created date       : 15-SEP-2021 (Teksystems)
**/
@istest
public class LeadConvertBatchOnDailyBasisTest {
    
    @istest
    public static void LeadConvertBatchOnDailyBasisTestMethod(){
        
        List<Lead> leadList = new List<Lead>();
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        User u = TestDataFactory.createTestUser('Marketo Sync');
        
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        consumerAccountList[0].phone = '1234568901';
        Update consumerAccountList[0];
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        optyList[0].status__c='Enrolled';
        optyList[0].Enrollment_Date__c=system.now();
        
        update optyList[0];
        
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        /*optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,Primary__c=true
,Bill_To__c=false,PersonAccount__c=consumerAccountList[0].id));
Insert optyconList;*/
        
        system.runAs(u){
            LeadTriggerHelper.isBatchtestLead=true;
            system.debug('LeadTriggerHelper.isBatchtestLead>>>'+LeadTriggerHelper.isBatchtestLead);
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            leadList.add(leadRec1);
            insert leadList;
            
            leadList[0].Lead_Assignment__c='MQL';
            update leadList[0];
            
            Test.startTest();
            
            LeadConvertBatchOnDailyBasisScheduled batchable = new LeadConvertBatchOnDailyBasisScheduled();
            batchable.execute(null);
            test.stopTest();
        }
        OpportunityContact__c oppContact = [select id,Opportunity__c, PersonAccount__c from OpportunityContact__c limit 1];
        system.assertEquals(optyList[0].id, oppContact.Opportunity__c);
    }
    
    
}