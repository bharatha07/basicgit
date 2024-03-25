/*************************************************************************************************
* @description This class will check for the count of asset type and update the opty based on Of_cb_c and Of_ct__c
* @param - 
* @story - SFDC-1668
* @Author -Teksystems
* @date - 01-May-2021 (Teksystems)
*/
@isTest
public class ToUpdateOfCBCTOnOptyFromAssetTest {
    @isTest static void ToUpdateOfCBCTOnOptyFromAssetTestTestMeth(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Account> provdAcct1 = TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        List<id> optyListOne = new List<id>();
        List<Asset> asstList = new List<Asset>();
        
        optyList[0].of_CB__c='0';
        optyList[0].of_CT__c='1';
        update optyList[0];
        
        optyListOne.add(optyList[0].id);
        
        List<Asset> assetList  = TestDataFactory.assetInsert();
        assetList[0].AccountId=provdAcct1[1].id;
        assetList[0].Opportunity__c=optyList[0].id;
        asstList.add(assetList[0]);
        
        
        assetList[1].AccountId=provdAcct1[1].id;
        assetList[1].Opportunity__c=optyList[0].id;
        asstList.add(assetList[1]);
        
        insert asstList;
        
        ToUpdateOfCBCTOnOptyFromAsset.AssetList(optyListOne);
        
        opportunity opp = [select id,of_CB__c from opportunity where id =:optyList[0].id];
        //system.assertEquals(string.valueOf(1), opp.of_CB__c);
    }

}