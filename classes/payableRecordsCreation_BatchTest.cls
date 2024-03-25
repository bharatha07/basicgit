/**************************************************************************************************************************************
*Component Name : payableRecordsCreation_BatchTest 
*Developed By   : TEKsystems
*Description    :Test Class for payableRecordsCreation_Batch.
*User Story     :  SFDC-1083
**********************************************************************************************************************************/
@isTest
public class payableRecordsCreation_BatchTest {
    public static testmethod void testPayableRecords(){
        try{
            //Consumer Accounts
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
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
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today().addDays(-1);
            Insert oppyAsset;
            system.debug('The Asset are-->'+oppyAsset);
            //Opportunity Provider
            recursiveClass.optyProviderPayable=true;
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true));
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
    public static testmethod void testPayable2(){
        //test.StartTest();
        try{
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
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
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today().addDays(-1);
            Insert oppyAsset;
            system.debug('The Asset are-->'+oppyAsset);
            //Opportunity Provider
            recursiveClass.optyProviderPayable=true;
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true));
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
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=false,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
            provideragrrements.add(provideraggr1);
            insert provideragrrements;
            
            List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
            lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='tuscon',Tax_ID__c='45678987',Zip_Code__c='12333',Provider_Agreement__c=provideragrrements[0].id));
            insert lstPayTo;
            test.StartTest();
            
            payableRecordsCreation_Batch xyz= new payableRecordsCreation_Batch(2);
            Id batchJobId2 = Database.executeBatch(xyz, 200);
            
            schedulePayablecreation newbatch = new schedulePayablecreation();
            String cronstr = '0 0 0 ? * *';
            id jobid = System.schedule('Payable Records Creation for Yesterday', cronStr, newbatch);
            CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(cronstr, cronTrigger1.CronExpression);
            // Assert that the cron job has not started
            System.assertEquals(0, cronTrigger1.TimesTriggered);
            Test.Stoptest();
            
            List<Payable__c> allpayable=[select id,name,Asset__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Opportunity__c IN:OppList];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
            system.assertEquals(oppyAsset[0].id, allpayable[0].Asset__c);
            system.assertEquals(oppyAsset[0].Opportunity__c, allpayable[0].Opportunity__c);
            system.assertEquals(provideragrrements[0].id, allpayable[0].HPN_Provider_Agreement__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        
    }
    public static testmethod void testPayable3(){
        //test.StartTest();
        try{
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
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
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today().addDays(-1);
            Insert oppyAsset;
            system.debug('The Asset are-->'+oppyAsset);
            //Opportunity Provider
            recursiveClass.optyProviderPayable=true;
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true));
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
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
            provideragrrements.add(provideraggr1);
            insert provideragrrements;
            
            List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
            lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='zooba',Tax_ID__c='4567876567',Zip_Code__c='12333',Provider_Agreement__c=null));
            insert lstPayTo;
            
            aggrement.CBR_PAY_TO__c=lstPayTo[0].id;
            update aggrement;
            
            test.StartTest();
            
            payableRecordsCreation_Batch xyz= new payableRecordsCreation_Batch(2);
            Id batchJobId2 = Database.executeBatch(xyz, 200);
            
            schedulePayablecreation newbatch = new schedulePayablecreation();
            String cronstr = '0 0 0 ? * *';
            id jobid = System.schedule('Payable Records Creation for Yesterday', cronStr, newbatch);
            CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.assertEquals(cronstr, cronTrigger1.CronExpression);
            // Assert that the cron job has not started
            System.assertEquals(0, cronTrigger1.TimesTriggered);
            Test.Stoptest();
            
            List<Payable__c> allpayable=[select id,name,Asset__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Opportunity__c IN:OppList];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
            system.assertEquals(oppyAsset[0].id, allpayable[0].Asset__c);
            system.assertEquals(oppyAsset[0].Opportunity__c, allpayable[0].Opportunity__c);
            system.assertEquals(provideragrrements[0].id, allpayable[0].HPN_Provider_Agreement__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }    
    }
}