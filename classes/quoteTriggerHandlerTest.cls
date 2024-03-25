/**
* @File Name          : quoteTriggerHandlerTest.cls
* @Description        : Test Class for Quote Trigger Handler.
* @Last Modified On   : 07/09/2021
**/
@isTest
public class quoteTriggerHandlerTest {
    public static testMethod void noOfPrimaryQuotesTestMethod(){
        Test.startTest();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1.SBQQ__Primary__c=true;
        quote1.SBQQ__Opportunity2__c=optyList[0].id;
        quote1.SBQQ__Status__c='Draft';
        insert quote1;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
        quote2.SBQQ__Primary__c=false;
        quote2.SBQQ__Opportunity2__c=optyList[0].id;
        quote2.SBQQ__Status__c='Draft';
        insert quote2;
        
        quote2.SBQQ__Primary__c=true;
        update quote2;
        //quering for asserts
        SBQQ__Quote__c queryList =[select id,SBQQ__Primary__c,No_of_primary_quote__c from SBQQ__Quote__c where id =:quote2.Id limit 1];
        system.assertEquals(1, queryList.No_of_primary_quote__c);
        system.assertEquals(true, queryList.SBQQ__Primary__c);
        Test.stopTest();
    }
}