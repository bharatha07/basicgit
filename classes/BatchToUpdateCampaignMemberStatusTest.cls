/**
* @File Name          : BatchToUpdateCampaignMemberStatusTest .cls
* @Description        : This Batch job is to campaign member status when below criteria is satisfied.
* @Author             : Teksystems
* @story              : SFDC-1639
* @Created date       : 15-APR-2021 (Teksystems)
**/
@istest
public class BatchToUpdateCampaignMemberStatusTest {
    @istest
    public static void BatchToUpdateCampaignMemberStatusTestMethod(){
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        Lead leadRec1 = new Lead();
        User u = TestDataFactory.createTestUser('Marketo Sync');
        system.runAs(u){
        leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(13),OwnerId = UserInfo.getUserId(),status = 'Qualified');
        insert leadRec1;
        }
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True,type='Outbound Dialer');
        insert camp1;
        
        //CampaignMemberStatus campStatus= new CampaignMemberStatus(CampaignId=camp1.id,Label='Ready');
        //insert campStatus;
        
        //CampaignMemberStatus campStatus1= new CampaignMemberStatus(CampaignId=camp1.id,Label='Remove Pending');
        //insert campStatus1;
        
        List<CampaignMember> CampMemb1 = new List<CampaignMember>();
        CampMemb1.add(new CampaignMember(LeadId =leadRec1.id , CampaignId = camp1.id, Status = 'Ready'));
        insert CampMemb1;
        
        Test.startTest();
        BatchToUpdtCampgnMemberStatsScheduler batchable = new BatchToUpdtCampgnMemberStatsScheduler();
        batchable.execute(null);
        Test.stopTest();
        
        CampaignMember campAftUp = [select id,Status from CampaignMember where id =:CampMemb1[0].id];
        system.assertEquals('Remove Pending', campAftUp.Status);
    }
}