/******************************************************************************************************************************
*Component Name: AssetComponentTriggerHandlerTest
*Created Date : 25-AUG-2021 (Teksystems)
* @story -  SFDC-1938
*Description : Test Class for AssetComponentTriggerHandlerTest
*Created By : Teksystems
*******************************************************************************************************************************/

@isTest
public class AssetComponentTriggerHandlerTest {
    
    @isTest static void testAstCmpEvent(){
        test.startTest();
        List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
        
        List<Account> providerAcc = TestDataFactory.createProviderAccounts();
        
        List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
        
        system.debug('The opportunity are-->'+OppList);
        
        List<Asset> oppyAsset = new List<Asset>();
        oppyAsset=TestDataFactory.assetInsert();
        oppyAsset[0].Opportunity__c=OppList[0].id;
        oppyAsset[0].AccountId=providerAcc[0].id;
        oppyAsset[0].FreezeDate__c=system.today().addDays(2);
        Insert oppyAsset[0];
        Asset_Component__c astRec= new Asset_Component__c();
        astRec.Deposit_Id__c=oppyAsset[0].id;
        astRec.Component_Type__c='Major Component';
        astRec.Component_Status__c='Stored';
        insert astRec;
        astRec.Component_Status__c='Released';
        update astRec;
        test.stopTest();
        
    }
}