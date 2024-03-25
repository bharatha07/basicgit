/*******************************************************************************************************************************************
*Component Name: batchToUpdateOfOPenAndEnrollOnProTest
*Description: Test class for batchToUpdateOfOPenAndEnrollOnProviders.
*Created By: TEKsystems
*Created Date: 
************************************************************************************************************************************************/
@isTest
public class batchToUpdateOfOPenAndEnrollOnProTest {
    @isTest
    static void batchToUpdateOfOPenAndEnrollOnProMeth(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        insert optyList;
        
        Opportunity_Provider__c Opptyprovider= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[0].Id,Primary_Provider__c =true);
        Insert Opptyprovider;
        
        Opportunity_Provider__c Opptyprovider1= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[1].Id,Primary_Provider__c =true);
        Insert Opptyprovider1;
        
        Opportunity_Provider__c Opptyprovider2= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[2].Id,Primary_Provider__c =true);
        Insert Opptyprovider2;
        
        Opportunity_Provider__c Opptyprovider3= new Opportunity_Provider__c(Provider__c=providerAccountList[1].id,Opportunity__c=optyList[3].Id,Primary_Provider__c =true);
        Insert Opptyprovider3;
        
        List<Opportunity> facstatlist =new List<Opportunity>();
        set<id> oplst = new set<id>();
        oplst.add(optyList[0].id);
        oplst.add(optyList[1].id);
        oplst.add(optyList[2].id);
        oplst.add(optyList[3].id);
        facstatlist= [Select id,Delivering_Hospital__c,status__c from Opportunity  WHERE Id IN:oplst limit 4];
        facstatlist[0].Enrollment_Date__c=system.now();
        facstatlist[0].status__c='Enrolled';
        facstatlist[1].Enrollment_Date__c=system.now();
        facstatlist[3].status__c='Enrolled';
        update facstatlist;
        
        Test.startTest();
        batchToUpdateOfOPenAndEnrollOnProvSched sch = new batchToUpdateOfOPenAndEnrollOnProvSched();
        sch.execute(null);
        Test.stopTest();
        
        Account acc = [select id,of_open_optys__c,of_enrolled_optys__c from account where id=:providerAccountList[0].id];
        system.assertEquals(1, acc.of_enrolled_optys__c);
        system.assertEquals(2, acc.of_open_optys__c);
    }
    @isTest
    static void batchToUpdateOfOPenAndEnrollOnProMeth1(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        insert optyList;
        
        Opportunity_Provider__c Opptyprovider= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[3].Id,Primary_Provider__c =true);
        Insert Opptyprovider;
        
        Opportunity_Provider__c Opptyprovider1= new Opportunity_Provider__c(Provider__c=providerAccountList[2].id,Opportunity__c=optyList[2].Id,Primary_Provider__c =true);
        Insert Opptyprovider1;
        
        Opportunity_Provider__c Opptyprovider2= new Opportunity_Provider__c(Provider__c=providerAccountList[1].id,Opportunity__c=optyList[1].Id,Primary_Provider__c =true);
        Insert Opptyprovider2;
        
        Opportunity_Provider__c Opptyprovider3= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[0].Id,Primary_Provider__c =true);
        Insert Opptyprovider3;
        
        List<Opportunity> facstatlist =new List<Opportunity>();
        set<id> oplst = new set<id>();
        oplst.add(optyList[0].id);
        oplst.add(optyList[1].id);
        oplst.add(optyList[2].id);
        oplst.add(optyList[3].id);
        facstatlist= [Select id,Delivering_Hospital__c,status__c from Opportunity  WHERE Id IN:oplst limit 4];
        facstatlist[0].Enrollment_Date__c=system.now();
        facstatlist[0].status__c='Enrolled';
        facstatlist[1].Enrollment_Date__c=system.now();
        facstatlist[3].status__c='Enrolled';
        update facstatlist;
        
        Test.startTest();
        batchToUpdateOfOPenAndEnrollOnProvSched sch = new batchToUpdateOfOPenAndEnrollOnProvSched();
        sch.execute(null);
        Test.stopTest();
        
        Account acc = [select id,of_open_optys__c,of_enrolled_optys__c from account where id=:providerAccountList[0].id];
        system.assertEquals(1, acc.of_enrolled_optys__c);
        system.assertEquals(0, acc.of_open_optys__c);
    }
}