@isTest
public class lwc_OpportunityContactsControllerTest{
    @isTest static void UnitTest1(){
         List<Account> accList = TestDataFactory.createConsumerAccounts();
         List<Opportunity> oppList = TestDataFactory.createOpportunities(accList);
         List<OpportunityContact__c> oppContactList = [Select id,Opportunity__c,Role__c,Primary__c from OpportunityContact__c];
         Test.StartTest();
         List<OpportunityContact__c> oppContacts = lwc_OpportunityContactsController.getOpportunityContacts(oppList[0].id);
         system.assertEquals(1,oppContacts.size());
         lwc_OpportunityContactsController.upsertOpportunityContacts(oppContacts);
         lwc_OpportunityContactsController.deleteOppContact(oppContacts[0]);
         List<OpportunityContact__c> emptyList = new List<OpportunityContact__c>();
         lwc_OpportunityContactsController.upsertOpportunityContacts(emptyList);
         lwc_OpportunityContactsController.deleteOppContact(new OpportunityContact__c());
         lwc_OpportunityContactsController.deleteOppContact(null);

         oppContacts[0].Ship_To__c = true;
         lwc_OpportunityContactsController.upsertOpportunityContacts(oppContacts);

         Test.StopTest();
    }
}