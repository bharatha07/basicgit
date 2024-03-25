@istest
public class opportunityproviderTriggerHandlerTest {
    public static testmethod void testPayableRecords(){
        try{
            //Consumer Accounts
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
            List<Account> facilityAcc=TestDataFactory.createFacilityAccounts();
            List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAcc,providerAcc);  
            //opportunity as Stored
            List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
            //OppList[0].Storage_Date__c = system.today();
            OppList[0].Status__c = 'Stored';
            OppList[0].Program_Enrolled_in__c  = 'Family Banking';
            //OppList[1].Storage_Date__c =system.today();
            OppList[1].Status__c = 'Stored';
            OppList[1].Program_Enrolled_in__c  = 'Family Banking';
            update OppList;
            system.debug('The opportunity are-->'+OppList);
            //Assets with different freeze dates
            List<Asset> oppyAsset = new List<Asset>();
            List<Asset> oppyAsset1 = new List<Asset>();
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today();
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today();
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today();
            oppyAsset1.add(oppyAsset[0]);
            oppyAsset1.add(oppyAsset[1]);
            oppyAsset1.add(oppyAsset[2]);
            insert oppyAsset1;
            Test.startTest();
            //Opportunity Provider
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true,Provider_Facility__c=providerFacilityList[0].ID));
            insert oppyProviderList;
            //Opportunity Contact
            List<OpportunityContact__c> opyCon = new  List<OpportunityContact__c>();
            opyCon.add(new OpportunityContact__c(PersonAccount__c =consumerAcc[2].id,Opportunity__c =OppList[0].id));
            insert opyCon;
            //Program
            Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
            Insert program;
            System.debug('The Program is -->'+program);
            //Agreement
            Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
            insert aggrement;
            //Provider Agreement
            List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
            provideragrrements.add(provideraggr1);
            insert provideragrrements;
            //Test starts here
            Test.stopTest();
            
            List<Payable__c> allpayable=[select id,name,Asset__c,Status__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c IN:oppyAsset];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
            system.assertEquals(oppyAsset[0].id, allpayable[0].Asset__c);
            system.assertEquals(oppyAsset[0].Opportunity__c, allpayable[0].Opportunity__c);
            system.assertEquals(provideragrrements[0].id, allpayable[0].HPN_Provider_Agreement__c);  
            system.assertEquals('Pending Accounting', allpayable[0].Status__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
    }
    public static testmethod void testPayableRecords2(){
        try{
            //Consumer Accounts
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
             List<Account> facilityAcc=TestDataFactory.createFacilityAccounts();
            List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAcc,providerAcc);  
            //opportunity as Stored
            List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
            //OppList[0].Storage_Date__c = system.today();
            OppList[0].Status__c = 'Stored';
            OppList[0].Program_Enrolled_in__c  = 'Family Banking';
            //OppList[1].Storage_Date__c =system.today();
            OppList[1].Status__c = 'Stored';
            OppList[1].Program_Enrolled_in__c  = 'Family Banking';
            update OppList;
            system.debug('The opportunity are-->'+OppList);
            //Assets with different freeze dates
            List<Asset> oppyAsset = new List<Asset>();
            List<Asset> oppyAsset1 = new List<Asset>();
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today();
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today();
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today();
            oppyAsset1.add(oppyAsset[0]);
            oppyAsset1.add(oppyAsset[1]);
            oppyAsset1.add(oppyAsset[2]);
            insert oppyAsset1;
            //Opportunity Provider
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=false,Provider_Facility__c=providerFacilityList[0].ID));
            insert oppyProviderList;
            
            oppyProviderList[0].Delivering_Provider__c=true;
            update oppyProviderList[0];
            //Opportunity Contact
            List<OpportunityContact__c> opyCon = new  List<OpportunityContact__c>();
            opyCon.add(new OpportunityContact__c(PersonAccount__c =consumerAcc[2].id,Opportunity__c =OppList[0].id));
            insert opyCon;
            //Program
            Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
            Insert program;
            System.debug('The Program is -->'+program);
            //Agreement
            Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
            insert aggrement;
            //Provider Agreement
            List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
            provideragrrements.add(provideraggr1);
            insert provideragrrements;
            //Test starts here
            test.StartTest();
            payableRecordsCreation_Batch abc= new payableRecordsCreation_Batch(2);
            Id batchJobId = Database.executeBatch(abc, 200);
            
            schedulePayablecreation newbatch = new schedulePayablecreation();
            String cronstr = '0 0 0 ? * *';
            id jobid = System.schedule('Payable Records Creation for Yesterday', cronStr, newbatch);
            
            CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(cronstr, cronTrigger1.CronExpression);
            // Assert that the cron job has not started
            System.assertEquals(0, cronTrigger1.TimesTriggered);
            Test.Stoptest();//Test ends here
            
            List<Payable__c> allpayable=[select id,name,Asset__c,Status__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c IN:oppyAsset];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
            system.assertEquals(oppyAsset[0].id, allpayable[0].Asset__c);
            system.assertEquals(oppyAsset[0].Opportunity__c, allpayable[0].Opportunity__c);
            system.assertEquals(provideragrrements[0].id, allpayable[0].HPN_Provider_Agreement__c);  
            system.assertEquals('Pending Accounting', allpayable[0].Status__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
    }
    @isTest
    static void batchToUpdateOfOPenAndEnrollOnProMeth(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAccountList,providerAccountList);  
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,StageName = 'Pending',status__c = 'Open'));
        insert optyList;
        
        Opportunity_Provider__c Opptyprovider= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[0].Id,Primary_Provider__c =true,Provider_Facility__c=providerFacilityList[0].ID);
        Insert Opptyprovider;
        
        Opportunity_Provider__c Opptyprovider1= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[1].Id,Primary_Provider__c =true,Provider_Facility__c=providerFacilityList[0].ID);
        Insert Opptyprovider1;
        
        Opportunity_Provider__c Opptyprovider2= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[2].Id,Primary_Provider__c =true,Provider_Facility__c=providerFacilityList[0].ID);
        Insert Opptyprovider2;
        
        Opportunity_Provider__c Opptyprovider3= new Opportunity_Provider__c(Provider__c=providerAccountList[1].id,Opportunity__c=optyList[3].Id,Primary_Provider__c =true,Provider_Facility__c=providerFacilityList[1].ID);
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
    }  
}