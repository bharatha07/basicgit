/**
* @File Name          : optyConTriggerhelperTest.cls
* @Description        : 
* @Author             : tejaswini(TEKsystems)
* @Created On   : 6/29/2020
* @Modification Log   : 
* Ver       Date            Author              Modification
* 1.0    6/29/2020         Tejaswini               Creating CampaignInfluence on creation of opty by lead conversion
**/
@istest
public class optyConTriggerhelperTest {
    public static testMethod void unitTest1(){
        User u = TestDataFactory.createTestUser('Marketo Sync');
        
        system.runAs(u){
            Test.Starttest();
            Campaign c = new Campaign(Name ='TestCampaign',Campaign_Code__c='Test Record OPPCON');
            insert c;
            List<Lead> leadList = new List<lead>();
            Lead leadRec1 = new Lead(FirstName='test lead1',Last_Touch_Code__c = 'Test Record OPPCON',LastName='tek leadNew Rec',LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified',Lead_Assignment__c = 'Test Opp Con');
            leadList.add(leadRec1);
            insert leadList;
            Account acc = [Select id from Account];
            Opportunity opp = [Select id,AccountId,Lead_RecordType_Name__c,Account.PersonContactId,OnLeadConvertion__c,Opty_Source_Code__c from Opportunity];
            List<OpportunityContact__C> oppCons = [select id,Opportunity__c from OpportunityContact__c];
            list<CampaignInfluence> cIList = [select id,Campaignid from CampaignInfluence where Campaignid =: c.id];
            System.assertEquals(cIList.size(), 1);
            Test.Stoptest();
        }
        
    }
    /*************************************************************************************************
* @description This method is used to publish platform event(AX) for primary flag on opty contact
* @param - Trigger map
* @story - SFDC-1165
* @return Void
* @date - 25-Sep-2020 (Teksystems)
*/   
    public static testMethod void axOptyConPriUpdateEvtTest(){
        Test.startTest();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
         system.debug('the accounts are are '+consumerAccountList);
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        system.debug('the oppybefore are '+optyList);
        optyList[0].AX_Order_Id__c='1212121212';
        optyList[1].AX_Order_Id__c='2323232323';
        update optyList;
        system.debug('the oppy are '+optyList);
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,Primary__c=false
                                                  ,Bill_To__c=false,PersonAccount__c=consumerAccountList[2].id));
        Insert optyconList;
        
        optyconList[0].Primary__c=true;
        //optyconList[0].Bill_To__c=true;
        OpportunityContact__C opCon=[select id , Name,Role__c,PersonAccount__c from OpportunityContact__C where Role__c='Father' limit 1 ];
        update optyconList;
        
        
       // AX_Opportunity_Primary_Event__e  consumerevent = new AX_Opportunity_Primary_Event__e (Ax_Contact_Id__c =optyconList[0].PersonAccount__c,Ax_Opportunity_Id__c = optyconList[0].Opportunity__C);
       // Database.SaveResult saveResult = EventBus.publish(consumerevent);
        
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.AXOpportunityPrimaryEvent accWrp=new PlatformEventWrapper.AXOpportunityPrimaryEvent();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='AX Opportunity Primary Event';
                   
         accWrp.AxContactId=optyconList[0].PersonAccount__c;
         accWrp.AxOpportunityId=optyconList[0].Opportunity__C;
         cbrEvt.EventData__c=JSON.serialize(accWrp);
         cbrEvtList.add(cbrEvt);
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
        Test.StopTest();
        System.assertEquals(true, saveResults[0].isSuccess());
    }
    /*************************************************************************************************
     * @description This method is used to publish platform event for primary or bill to flag on opty contact
     * @param - Trigger map
     * @story - SFDC-1196 and 1236
     * @return Void
     * @date - 25-Sep-2020 (Teksystems)
     * @modified date - 08-Oct-2020 (Teksystems)- Added opty id in event parameter ,
     * @this method was moved from process builder(Opportunity Contact Role Update,V4) to apex method.
     */
    
    public static testMethod void optyConBilltoUpdateEvtTest(){
        Test.startTest();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        
        optyList[0].Status__C='Stored';
        optyList[0].AX_Order_Id__c='';
        update optyList[0];
        optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,Primary__c=false
                                                  ,PersonAccount__c=consumerAccountList[1].id));
        Insert optyconList;
        system.debug('The oppyContactlist are-->'+optyconList);
        optyconList[0].Primary__c=true;
        OpportunityContact__C opCon=[select id , Name,Role__c,PersonAccount__c from OpportunityContact__C where Role__c='Father' limit 1 ];
        update optyconList;
        system.debug('The oppyContacts are-->'+opCon);
        
       // Opportunity_Contact_BillTo_Update__e  consumerevent = new Opportunity_Contact_BillTo_Update__e (Account_ID__c =optyconList[0].PersonAccount__c,Opportunity_ID__c = optyconList[0].Opportunity__C);
       // Database.SaveResult saveResult = EventBus.publish(consumerevent);
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.OpportunityContactBillToUpdate optyConWrp=new PlatformEventWrapper.OpportunityContactBillToUpdate();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='Opportunity Contact BillTo Update';
                   
        optyConWrp.AccountID=optyconList[0].PersonAccount__c;
        optyConWrp.OpportunityID=optyconList[0].Opportunity__C;
        cbrEvt.EventData__c=JSON.serialize(optyConWrp);
        cbrEvtList.add(cbrEvt); 
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
        Test.StopTest();
        System.assertEquals(true, saveResults[0].isSuccess());
        
    }
    /*************************************************************************************************
     * @description This method is used to publish Qucik ABO Event.
     * @param - Trigger map
     * @story - SFDC-1410
     * @return Void
     * @date - 27-Jan-2021 (Teksystems)
     */
    
    public static testMethod void sendAboEventTest(){
        
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        Map<Id,OpportunityContact__c> OldMap = new Map<id,OpportunityContact__c>();
        Map<Id,OpportunityContact__c> newMap = new Map<id,OpportunityContact__c>();
        
        Opportunity oppOne = [select id,Status__C,StageName,MotherRole__c from Opportunity where id=:optyList[1].id limit 1];
        oppOne.Status__C='Enrolled';
        update oppOne;
        system.debug('oppOne>>>'+oppOne);
        
        Test.startTest();
        OpportunityContact__C opCon=[select id, Opportunity_Status__c,Opportunity__r.MotherRole__c,Opportunity__r.Status__C, Name,Role__c,PersonAccount__c from OpportunityContact__C where Opportunity__c =:oppOne.id limit 1 ];
        opCon.Role__c='Father';
        Update opCon;
        
        opCon.Role__c='Mother';
        Update opCon;
        
        system.debug('The oppyContacts are111-->'+opCon);
        test.stopTest();
        
            
    }
    //SFDC-2158 test coverage
    public static testMethod void updateOppConsToNonPrimaryTest(){
    Test.StartTest();
   
     Profile p = [SELECT Id FROM Profile WHERE Name='CBR Integration Profile'];
        User usr = new User(FirstName='MulesoftUser',LastName='MulesoftUser',Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName='testMulsft@tsetuser.com',UserPermissionsMarketingUser = true);
        insert usr;
         system.runAs(usr){
         List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        LIst<OpportunityContact__c> oppConList = [select id,Opportunity__c,primary__c from OpportunityContact__c];
        List<OpportunityContact__c> oppContsToInsert = new List<OpportunityContact__c>();
        oppContsToInsert.add(new OpportunityContact__c(primary__c = true,bill_to__C = true,ship_to__c = true,opportunity__c = optyList[0].id,personAccount__c =consumerAccountList[1].id ));
        insert oppContsToInsert;  
        
        test.Stoptest(); 
        }
    }
        
}