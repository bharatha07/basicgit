/******************************************************************************************************************************
*Component Name: cbr_MessageTriggerHandlerTest
*Created Date :1/4/2021
*Description : Test Class for cbr_MessageTriggerHandlerTest
*Created By : 
*******************************************************************************************************************************/
@isTest
public class cbr_MessageTriggerHandlerTest {
    @isTest static void cbr_MessageTriggerHandlerTestMet(){
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        Message__c msg = new Message__c();
        msg.Status__c='New';
        msg.Event_Type__c='AX Opportunity Primary Event';
        msg.Direction__c='Outbound';
        Test.startTest();
        insert msg;
        Test.stopTest();

    }
    
    
}