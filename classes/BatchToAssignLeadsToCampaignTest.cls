/******************************************************************************************************
* @File Name          : BatchToAssignLeadsToCampaignTest.cls
* @Description        : Batch Job to assign NonMQL Leads to Campaigns as CampaignMember.
* @Author             : Teksystems
* @story              : SFDC-1619
* @Created date       : 15-APR-2021 (Teksystems)
**********************************************************************************************************/
@istest
public class BatchToAssignLeadsToCampaignTest {
    @istest
    public static void leadAssignedToCmapaignTestMethod(){
        User maerketuser=[select id,name,Profile.name  from user where Profile.name='Marketo Sync' limit 1];
        Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        system.runAs(maerketuser){
            Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(35),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            insert leadRec1;
            Lead leadRec2 = new Lead(FirstName='test lead2',LastName='tek leadNew Rec2',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568902',Email='abc12@test12gmail.com',Due_Date__c = system.today().addDays(45),OwnerId = UserInfo.getUserId(),status = 'Qualified');
            insert leadRec2;
        }
        Campaign camp1 = new Campaign(Name = 'Test Campaign 1', IsActive = True,type='Outbound Dialer');
        insert camp1;
        
        //CampaignMemberStatus campStatus= new CampaignMemberStatus(CampaignId=camp1.id,Label='Ready');
        //insert campStatus;
        
        Test.startTest();
        scheduleBatchToCreateCampaignMember newbatch = new scheduleBatchToCreateCampaignMember();
        newbatch.execute(null);
        Test.stopTest();
        
        List<CampaignMember> newcampaigmember = [select id,name,Status from CampaignMember];
        system.debug('The campainmember is-->'+newcampaigmember);
        system.assertEquals('Ready', newcampaigmember[0].Status);
        system.assertEquals('test lead2 tek leadNew Rec2', newcampaigmember[1].Name);
        system.assertEquals('Ready', newcampaigmember[1].Status);
        system.assertEquals('test lead1 tek leadNew Rec', newcampaigmember[0].Name);
    }
}