/******************************************************************************************************************************
*Component Name: AssetTriggerHandlerTest
*Created Date : 25-SEP-2020
* @story - SFDC-695
*Description : Test Class for AssetTriggerHandler
*Created By : 
*******************************************************************************************************************************/
@isTest
public class AssetTriggerHandlerTest{
    @isTest static void updateOptyStatusTest(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Account> provdAcct1 = TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        List<Asset> asstList = new List<Asset>();
        
        optyList[0].of_CB__c='0';
        optyList[0].of_CT__c='1';
        optyList[0].status__c='Enrolled';
        update optyList[0];
            
        List<Asset> assetList  = TestDataFactory.assetInsert();
        assetList[0].AccountId=provdAcct1[1].id;
        assetList[0].Opportunity__c=optyList[0].id;
        asstList.add(assetList[0]);
        
        
        assetList[1].AccountId=provdAcct1[1].id;
        assetList[1].Opportunity__c=optyList[0].id;
        asstList.add(assetList[1]);
        
        insert asstList;
        
        
        Test.startTest();
        List<Asset> astListStrd = new List<Asset>();
        List<Asset> assList =[select id,status,type__c,opportunity__c from Asset where Opportunity__c =:assetList[1].Opportunity__c];
        assList[0].Status='Stored';
        assList[1].Status='Stored';
        astListStrd.add(assList[0]);
        astListStrd.add(assList[1]);
        update astListStrd;
        
                
        opportunity opp =[select id,of_CB__c,of_CT__c,Display_Quoted_of_CB__c,Display_Quoted_of_CT__c,status__c from opportunity where id=:assList[0].opportunity__c];
        Test.stopTest();
        //system.assertEquals(string.valueOf(1),opp.of_CT__c);
    }
    @isTest static void updateOptyStatusTest1(){
        List<Account> provdAcct1 = TestDataFactory.createProviderAccounts();
        List<Account> consumerAcct1 = TestDataFactory.createConsumerAccounts();        
        List<Opportunity> optyList1 = TestDataFactory.createOpportunities(consumerAcct1);
        List<Asset> assetList1  = TestDataFactory.assetInsert();
        assetList1[0].AccountId=provdAcct1[0].id;
        assetList1[0].Opportunity__c=optyList1[0].id;
        insert assetList1[0];
        
        assetList1[1].AccountId=provdAcct1[0].id;
        assetList1[1].Opportunity__c=optyList1[0].id;
        insert assetList1[1];
        
        assetList1[2].AccountId=provdAcct1[0].id;
        assetList1[2].Opportunity__c=optyList1[0].id;
        insert assetList1[2];
        
        Test.startTest();
        Asset assList1 =[select id,status,type__c,opportunity__c from Asset where id =:assetList1[0].id];
        assList1.Status='Stored';
        update assList1;
        
        Asset assList2 =[select id,status,type__c,opportunity__c from Asset where id =:assetList1[1].id];
        assList2.Status='Released';
        update assList2;
        
        opportunity opp =[select id,of_CB__c,of_CT__c from opportunity where id=:assList1.opportunity__c];
        Test.stopTest();
        //system.assertEquals(string.valueOf(1),opp.of_CB__c);
    }
    
}