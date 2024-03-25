/**
* @File Name          : PrimarySourceUpdateOneTimeBatchTest .cls
* @Description        : Batch to update primary source to I'm a Current Client.
* @Author             : Teksystems
* @story              : SFDC-1563
* @Created date       : 21/04/2020
**/
@isTest
public class PrimarySourceUpdateOneTimeBatchTest {
public static testMethod void updateOptyPrimySourTest(){
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        User u = TestDataFactory.createTestUser('CBR Integration Profile');    
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        
        List<Opportunity> optyList1=new list<Opportunity>();
        optyList1.add(new Opportunity(Name= 'OppTest1test',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Stored',Primary_Source__c='Email from CBR',Storage_Date__c=system.now()-1));
        optyList1.add(new Opportunity(Name= 'OppTest1test1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Stored',Primary_Source__c='Email from CBR',Storage_Date__c=system.now()-3));
        insert optyList1;
        
        system.runAs(u){
            Test.startTest();    
            PrimarySourceUpdateOneTimeBatchScheduler oppbatch = new PrimarySourceUpdateOneTimeBatchScheduler();
            oppbatch.execute(null);    
            Test.stopTest();
        }
        Opportunity oppty = [Select id,of_Babies__c,StageName,status__c,Primary_Source__c,Enrollment_date__c,Storage_Date__c from Opportunity  WHERE id =:optyList1[0].id];
        
        system.assertEquals('I\'m a Current Client', oppty.Primary_Source__c);
    }
}