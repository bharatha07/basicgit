/**
 * @File Name          : campaignInfluenceTriggerHelperTest.cls
 * @Description        : 
 * @Author             : Tejaswini
 * @User Story              : SFDC - 984
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/22/2020, 7:01:24 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/22/2020   Tejaswini                 Initial Version
**/
@isTest
public class campaignInfluenceTriggerHelperTest {
    public @IsTest
    static void unitTest(){
        User u = TestDataFactory.createTestUser('Marketo Sync');
        Test.startTest();
        System.runAs(u){
            List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
            List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
            List<OpportunityContact__C> optyContacs = [Select id,PersonAccount__C,PersonAccount__r.PersonContactId,opportunity__c from OpportunityContact__c Where primary__c = true];
            Campaign c = new Campaign(Name ='TestCampaign',Campaign_Code__c='Test Record12');
            insert c;
            CampaignInfluence ci = new CampaignInfluence();
            ci.CampaignId = c.id;
            ci.OpportunityId = optyContacs[0].Opportunity__c;
            ci.ContactId = optyContacs[0].PersonAccount__r.PersonContactId;
            ci.Modelid =Label.Campaign_Model_Id;
            insert ci;
        }
        List<Account> accRecord = [select id,Last_Touch_Code__pc from account where Last_Touch_Code__pc = 'Test Record12'];
        System.debug('accRecord---'+accRecord);
        System.assertEquals(accRecord.size(), 1);
        Test.stopTest();
        
    }
}