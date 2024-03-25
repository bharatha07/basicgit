/******************************************************************************************************************************
*Component Name: ConPayPrflTriggerHandlerTest
*Created Date :05-OCT-2020 (Teksystems)
*Description : Test Class for ConPayPrflTriggerHandler
*Created By : TekSystems
*******************************************************************************************************************************/
@isTest
public class ConPayPrflTriggerHandlerTest {
    
    /*************************************************************************************************
* @description This test method is used to test the  publish platform event for new contcat payement profile creation
* @param - None
* @story - SFDC-1200
* @return Void
* @date - 06-OCT-2020 (Teksystems)
*/
    @isTest static void ConPayPFeventTestM1(){
        Test.startTest();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        consumerAccountList[0].AX_Customer_Id__pc='testAxCusId';
        
        Update consumerAccountList;
        
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        /* optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,
PersonAccount__c=consumerAccountList[0].id,Primary__c=true));   

Insert optyconList; */
        optyconList = [select id,Role__c,Opportunity__c,PersonAccount__c,Primary__c from OpportunityContact__c];
        
        List<Contact_Payment_Profile__c> conPayList = new List<Contact_Payment_Profile__c>();
        conPayList.add(new Contact_Payment_Profile__c(Credit_Card_Type__c='Visa',Card__c='Testcard',
                                                      Account__c=consumerAccountList[0].id,Primary__c=true,Last_4_Digits__c='1234',Expiration_Month__c='12',Expiration_Year__c='2030'));   
        Insert conPayList;
        
        // Ax_Customer_Update_Event__e consumerevent = new Ax_Customer_Update_Event__e (Ax_Consumer_Id__c =consumerAccountList[0].id);
        // Database.SaveResult saveResult = EventBus.publish(consumerevent );
        /*List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
PlatformEventWrapper.AxCustomerUpdateEvent accWrp=new PlatformEventWrapper.AxCustomerUpdateEvent();
CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
cbrEvt.EventType__c='Ax Customer Update Event';

accWrp.AxConsumerId=consumerAccountList[0].id;
cbrEvt.EventData__c=JSON.serialize(accWrp);
cbrEvtList.add(cbrEvt);  

List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
Test.StopTest();
System.assertEquals(true, saveResults[0].isSuccess());*/
        
    }
    
    @isTest static void updatePayPrflPFeventTestMethod(){
        Test.startTest();
        List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
        consumerAccList[0].AX_Customer_Id__pc='testAxCusIdPri';
        
        Update consumerAccList;
        
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccList);
                
        List<Contact_Payment_Profile__c> conPayList = new List<Contact_Payment_Profile__c>();
        conPayList.add(new Contact_Payment_Profile__c(Credit_Card_Type__c='Visa',Card__c='TestcardE',AX_CC_Id__c='25363634',
                                                      Account__c=consumerAccList[0].id,Primary__c=false,Last_4_Digits__c='3234',Expiration_Month__c='11',Expiration_Year__c='2031'));   
        Insert conPayList;
        
        conPayList[0].Primary__c = true;
        update conPayList[0];
    }
}