/******************************************************************************************************************************
*Component Name: SendOpportunityToAXTest
*Created Date : 16-DEC-2020
* @story - SFDC-1372
*Description : Test Class for SendOpportunityToAX.
*Created By : 
*******************************************************************************************************************************/
@isTest
public class SendOpportunityToAXTest {
    
    @isTest static void testClassForAXButton(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        
        optyList[0].status__c='Stored';
        
        update optyList[0];
        
        
        PageReference pageRef = Page.SendOpportunityToAXVF; 
        pageRef.getParameters().put('id',optyList[0].Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(optyList[0]);
        SendOpportunityToAX obj = new SendOpportunityToAX(sc);
        obj.sendOptyToAX();
        Test.stopTest();
        
        
    }
    @isTest static void testClassForAXButton1(){
        
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        
        PageReference pageRef = Page.SendOpportunityToAXVF; 
        pageRef.getParameters().put('id',optyList[0].Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(optyList[0]);
        SendOpportunityToAX obj = new SendOpportunityToAX(sc);
        obj.sendOptyToAX();
        Test.stopTest();
    }
    
    @isTest static void testClassForAXButton2(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        
        optyList[0].status__c='Enrolled';
        
        update optyList[0];
        
        
        PageReference pageRef = Page.SendOpportunityToAXVF; 
        pageRef.getParameters().put('id',optyList[0].Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(optyList[0]);
        SendOpportunityToAX obj = new SendOpportunityToAX(sc);
        obj.sendOptyToAX();
        Test.stopTest();
    }
    @isTest static void testClassForAXButton3(){
        List<Account> ConsAcct = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(ConsAcct);
        
        optyList[0].status__c='Closed_Lost';
        optyList[0].Loss_Reason__c='Collection Activity';
        
        update optyList[0];
        
        
        PageReference pageRef = Page.SendOpportunityToAXVF; 
        pageRef.getParameters().put('id',optyList[0].Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(optyList[0]);
        SendOpportunityToAX obj = new SendOpportunityToAX(sc);
        obj.sendOptyToAX();
        Test.stopTest();
    }
}