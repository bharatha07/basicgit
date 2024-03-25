/**
* @File Name          : BatchToFetchEnrolledOptysToStoredTest .cls
* @Description        : This Batch job is to fetch enrolled optys for yesterday and check for stored assets in order to make opty as stored.
* @Author             : Teksystems
* @story              : SFDC-1629
* @Created date       : 08-Apr-2021 (Teksystems)
**/
@istest
public class BatchToFetchEnrolledOptysToStoredTest {
    @istest
    public static void BatchToFetchEnrolledOptysToStoredTestMethod(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Account> provdAcct1 = TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        List<Asset> asstList = new List<Asset>();
        
        optyList[0].of_CB__c='0';
        optyList[0].of_CT__c='1';
        optyList[0].Enrollment_Date__c=system.now()-1;
        system.debug('Dateifdate'+optyList[0].Enrollment_Date__c);
        //optyList[0].status__c='Enrolled';
        system.debug('Dateifdatestatus'+optyList[0].status__c);
        update optyList[0];
            
        List<Asset> assetList  = TestDataFactory.assetInsert();
        assetList[0].AccountId=provdAcct1[1].id;
        assetList[0].Opportunity__c=optyList[0].id;
        system.debug('opty0'+assetList[0].Opportunity__c);
        asstList.add(assetList[0]);
        
        
        assetList[1].AccountId=provdAcct1[1].id;
        assetList[1].Opportunity__c=optyList[0].id;
        system.debug('opty1'+assetList[1].Opportunity__c);
        asstList.add(assetList[1]);
        
        insert asstList;
        
        
        
        List<Asset> astListStrd = new List<Asset>();
        List<Asset> assList =[select id,status,type__c,FreezeDate__c,opportunity__c from Asset where Opportunity__c =:assetList[1].Opportunity__c];
        assList[0].Status='Stored';
        assList[0].FreezeDate__c=system.now();
        assList[1].Status='Stored';
        assList[1].FreezeDate__c=system.now().adddays(-1);
        astListStrd.add(assList[0]);
        astListStrd.add(assList[1]);
        update astListStrd;
        
        opportunity opp = [select id,status__c,Enrollment_Date__c from opportunity where id =:optyList[0].id];
        opp.Status__c='Enrolled';
        update opp;
        
        Test.startTest();
        BatchToFetchEnrledOptysToStordScheduler batchable = new BatchToFetchEnrledOptysToStordScheduler();
        batchable.execute(null);
        Test.stopTest();
                
        opportunity opp1 =[select id,of_CB__c,of_CT__c,Display_Quoted_of_CB__c,Display_Quoted_of_CT__c,status__c from opportunity where id=:assList[0].opportunity__c];
        
        system.assertEquals(string.valueOf(1),opp1.of_CT__c);
    }

}