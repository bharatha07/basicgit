/*************************************************************************************************************************
* Component Name: NewOpportunityControllerTest
* Description: Test class for NewOpportunityController
* DevelopedBy: TEKsystems
*****************************************************************************************************************************/
@isTest
public class NewOpportunityControllerTest{
    @isTest static void unitTest1(){
        List<Account> accList = TestDataFactory.createConsumerAccounts();
        system.debug('accList ---'+accList);
        List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
        system.debug('oppList===='+oppList);
        List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
        system.debug('oppContactList----------'+oppContactList);
        Test.StartTest();
        //Test stored opportunity Account
        PageReference pageRef = Page.NewOpportunity;
        String str1 =  NewOpportunityController.checkOpportunityOnContact(accList[0].id);
        system.debug('str1----'+str1);
        //system.assertEquals('CreateOpp',str1);
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accid',accList[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
        NewOpportunityController newOppObj = New NewOpportunityController(sc);
        ApexPages.currentPage().getParameters().put('accId',accList[0].id);
        newOppObj.saveOpportunity();

        Test.StopTest();

    }
    @isTest static void unitTest2(){
        Id CSSProfileId = system.Label.CSS_Profile_Id;
        User CSSUser = TestDataFactory.createTestUser('Client Support Specialist');
        system.runAs(CSSUser){
            List<Account> accList = TestDataFactory.createConsumerAccounts();
            system.debug('accList==='+accList);
            List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
            system.debug('oppList===='+oppList);
            system.debug('oppList===='+oppList);
            List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
            Test.StartTest();
            //Test stored opportunity Account
            PageReference pageRef = Page.NewOpportunity;
            String str1 =  NewOpportunityController.checkOpportunityOnContact(accList[0].id);
            system.debug('str1----'+str1);
            //system.assertEquals('CreateOpp',str1);
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('accid',accList[0].id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
            NewOpportunityController newOppObj = New NewOpportunityController(sc);
            ApexPages.currentPage().getParameters().put('accId',accList[0].id);
            newOppObj.saveOpportunity();
            List<Opportunity> oppList1 = [Select id from opportunity];
            Integer oppListSize= oppContactList.size() +1;
            system.assertEquals(oppList1.size(),oppListSize);
            Test.StopTest(); 
        }
        
    }
    @isTest static void unitTest3(){
        Id NSCEProfileId = system.Label.NCSE_Profile_Id;
        User NSCEUser = [Select id,UserName,ProfileId from User where ProfileId =: NSCEProfileId AND IsActive = true LIMIT 1];
        system.runAs(NSCEUser){
            List<Account> accList = TestDataFactory.createConsumerAccounts();
            List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
            system.debug('oppList===='+oppList);
            List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
            Test.StartTest();
            //Test stored opportunity Account
            PageReference pageRef = Page.NewOpportunity;
            String str1 =  NewOpportunityController.checkOpportunityOnContact(accList[0].id);
            system.debug('str1----'+str1);
            //system.assertEquals('CreateOpp',str1);
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('accid',accList[0].id);
            ApexPages.StandardController sc = new ApexPages.StandardController(accList[0]);
            NewOpportunityController newOppObj = New NewOpportunityController(sc);
            ApexPages.currentPage().getParameters().put('accId',accList[0].id);
            newOppObj.saveOpportunity();
            List<Opportunity> oppList1 = [Select id from opportunity];
            Integer oppListSize= oppContactList.size() +1;
            system.assertEquals(oppList1.size(),oppListSize);
            Test.StopTest(); 
        }
        
    }
   
}