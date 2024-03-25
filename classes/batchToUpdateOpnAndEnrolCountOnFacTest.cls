/*******************************************************************************************************************************************
*Component Name: batchToUpdateOpnAndEnrolCountOnFacTest
*Description: Test class for batchToUpdateOpnAndEnrolCountOnFacility.
*Created By: TEKsystems
*Created Date: 
************************************************************************************************************************************************/
@isTest
public class batchToUpdateOpnAndEnrolCountOnFacTest {
    @isTest
    static void batchToUpdateOpnAndEnrolCountOnFacMeth(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        insert optyList;

        List<Opportunity> facstatlist =new List<Opportunity>();
        set<id> oplst = new set<id>();
        oplst.add(optyList[0].id);
        oplst.add(optyList[1].id);
        oplst.add(optyList[2].id);
        facstatlist= [Select id,Delivering_Hospital__c,status__c from Opportunity  WHERE Id IN:oplst limit 3];
        facstatlist[0].Enrollment_Date__c=system.now();
        facstatlist[0].status__c='Enrolled';
        facstatlist[1].Enrollment_Date__c=system.now();
        facstatlist[1].Delivering_Hospital__c=facilityAccountList[5].id;
        facstatlist[1].status__c='Enrolled';
        update facstatlist;
        
        Test.startTest();
        batchToUpdateOpnAndEnrolCountOnFacSched sch = new batchToUpdateOpnAndEnrolCountOnFacSched();
        sch.execute(null);
        Test.stopTest();
        Account acc = [select id,of_open_optys__c,of_enrolled_optys__c from account where id=:facilityAccountList[4].id];
        system.assertEquals(1, acc.of_enrolled_optys__c);
        system.assertEquals(2, acc.of_open_optys__c);
    }
}