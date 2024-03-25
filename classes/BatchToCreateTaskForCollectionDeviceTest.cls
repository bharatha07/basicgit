/**
* @File Name          : BatchToCreateTaskForCollectionDeviceTest .cls
* @Description        : Batch to find all the optys which are stored and asset freeze date is 7 days ago from today.
* @Author             : Teksystems
* @story              : SFDC-1667
* @Created date       : 5/4/2021
**/
@isTest
public class BatchToCreateTaskForCollectionDeviceTest {
    
    @isTest static void BatchToCreateTaskForCollectionDeviceTestMeth(){
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
        
        List<Asset> astListStrd = new List<Asset>();
        List<Asset> assList =[select id,status,type__c,opportunity__c,FreezeDate__c,SerialNumber from Asset where Opportunity__c =:assetList[1].Opportunity__c];
        assList[0].Status='Stored';
        assList[0].FreezeDate__c=system.today().adddays(-7);
        assList[1].Status='Stored';
        assList[1].FreezeDate__c=system.today().adddays(-7);
        astListStrd.add(assList[0]);
        astListStrd.add(assList[1]);
        update astListStrd;
        
        Test.startTest();    
        BatchToCreateTaskForCollectDeviceSched assbatch = new BatchToCreateTaskForCollectDeviceSched();
        assbatch.execute(null);    
        Test.stopTest();
        
        List<Task> tas = new List<Task>();
        tas = [select id,whatid,Subject,Task_Sub_Type__c from task where whatid=:optyList[0].id and Task_Sub_Type__c='Congrats Call'];
        
        system.assertEquals(tas.size(), 2);
        
    }
}