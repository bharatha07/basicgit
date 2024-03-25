/******************************************************************************************************************************
*Component Name: sendBillToPlatformEventsTest
*Created Date :1/4/2021
*Description : Test Class for sendBillToPlatformEventsTest
*Created By : 
*******************************************************************************************************************************/
@isTest
public class sendBillToPlatformEventsTest {
    @isTest static void sendBillToPlatformEventsTestMet(){
        TestDataFactory.CustomSettingRecords();
        List<id> OptycontactListId = new List<id>();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        
        /*optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,Primary__c=false,Bill_To__c=true,delay_BillTo__c=true
                                            ,PersonAccount__c=consumerAccountList[0].id));
        Insert optyconList; */
        optyconList = [select id,Role__c,Opportunity__c,Primary__c,Bill_To__c,PersonAccount__c,PersonAccount__r.BillingCountry,PersonAccount__r.BillingStreet,PersonAccount__r.BillingCity,PersonAccount__r.BillingState,PersonAccount__r.BillingPostalCode from OpportunityContact__c];
        system.debug('The oppyContactlist are-->'+optyconList);
        Test.startTest();
        //optyconList[0].Primary__c=false;
        optyconList[0].Role__c = 'father';
        optyconList[0].Bill_To__c = true;
        update optyconList;
        
        //optyconList[0].primary__c = true;
        //update optyconList;
        Test.stopTest();
        OptycontactListId.add(optyconList[0].id);
       // OpportunityContact__C opCon=[select id , Name,Role__c,PersonAccount__c,Bill_To__c from OpportunityContact__C where Role__c='Father' limit 1 ];
        sendBillToPlatformEvents.billToChange(OptycontactListId);
                
    }
    
}