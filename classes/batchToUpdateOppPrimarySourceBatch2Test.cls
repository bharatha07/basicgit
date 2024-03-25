/**
* @File Name          : batchToUpdateOppPrimarySourceBatch2Test .cls
* @Description        : Batch to update primary source to I'm a Current Client.
* @Author             : Teksystems
* @story              : SFDC-1563
* @Created date       : 21/04/2020
**/
@isTest
public class batchToUpdateOppPrimarySourceBatch2Test {
    public static testMethod void updateOptyPrimySourTest(){
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        User u = TestDataFactory.createTestUser('CBR Integration Profile');    
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        
        List<Opportunity> optyList1=new list<Opportunity>();
        optyList1.add(new Opportunity(Name= 'OppTest1test',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Open',Primary_Source__c='Email from CBR'));
        optyList1.add(new Opportunity(Name= 'OppTest1test1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Stored',Primary_Source__c='Email from CBR'));
        insert optyList1;
        
        
        
        List<Opportunity> oppList=new list<Opportunity>();
        oppList= [Select id,of_Babies__c,StageName,status__c,Primary_Source__c,Account.of_Stored_Opportunities__c from Opportunity  WHERE Id = :optyList1[0].Id limit 1];
        oppList[0].Status__c='Enrolled';
        oppList[0].Enrollment_date__c=system.now();
        update oppList;
        
        List<Account> accList = [select id,of_Stored_Opportunities__c from account where id =:consumerAccountList[0].id];
        
        system.runAs(u){
            Test.startTest();    
            batchToUpdateOppPrimarySourceBatch2Schdr oppbatch = new batchToUpdateOppPrimarySourceBatch2Schdr();
            oppbatch.execute(null);    
            Test.stopTest();
        }
        Opportunity oppty = [Select id,of_Babies__c,StageName,status__c,Primary_Source__c,Enrollment_date__c from Opportunity  WHERE Enrollment_date__c =TODAY limit 1];
        
        system.assertEquals('I\'m a Current Client', oppty.Primary_Source__c);
    }
}