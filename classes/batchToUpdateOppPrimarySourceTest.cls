/**
* @File Name          : batchToUpdateOppPrimarySourceTest .cls
* @Description        : Batch to update primary source to null.
* @Author             : Teksystems
* @story              : SFDC-1242
* @Created date       : 25/11/2020
**/
@isTest
public class batchToUpdateOppPrimarySourceTest {
    
    public static testMethod void updateOptyPrimySourTest(){
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        User u = TestDataFactory.createTestUser('CBR Integration Profile');    
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        
        List<Opportunity> optyList1=new list<Opportunity>();
        optyList1.add(new Opportunity(Name= 'OppTest1test',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Open',Primary_Source__c='I\'m a Current Client'));
        insert optyList1;
        
        
        List<Opportunity> oppList=new list<Opportunity>();
        oppList= [Select id,of_Babies__c,StageName,status__c,Primary_Source__c,Account.of_Stored_Opportunities__c from Opportunity  WHERE Id = :optyList1[0].Id limit 1];
        oppList[0].Status__c='Enrolled';
        oppList[0].Enrollment_date__c=system.now()-1;
        update oppList;
        
        List<Account> accList = [select id,of_Stored_Opportunities__c from account where id =:consumerAccountList[0].id];
        
        system.runAs(u){
            Test.startTest();    
            batchToUpdateOppPrimarySourceScheduler oppbatch = new batchToUpdateOppPrimarySourceScheduler();
            oppbatch.execute(null);    
            Test.stopTest();
        }
        Opportunity oppty = [Select id,of_Babies__c,StageName,status__c,Primary_Source__c,Enrollment_date__c from Opportunity  WHERE Enrollment_date__c =YESTERDAY limit 1];
        
        system.assertEquals(null, oppty.Primary_Source__c);
    }
}