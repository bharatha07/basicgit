/**************************************************************************************************************************************
*Component Name : updatepayableStatus_BatchTest 
*Developed By   : TEKsystems
*Description    : Test class for updatepayableStatusButton_Batch
*User Story     :  SFDC-1545
**********************************************************************************************************************************/
@isTest
public class updatepayableStatus_BatchTest {
    @testSetup static void datasetup() {
        //Consumer Accounts
        List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
        //Provider Accounts
        List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
        providerAcc[0].HPN_Flag__c=true;
        providerAcc[1].HPN_Flag__c=true;
        update providerAcc;
        system.debug('The provideraccount are-->'+providerAcc);
        //opportunity as Stored
        List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
        //OppList[0].Storage_Date__c = system.today();
        OppList[0].Status__c = 'stored';
        OppList[0].Program_Enrolled_in__c  = 'Family Banking';
        //OppList[1].Storage_Date__c =system.today();
        OppList[1].Status__c = 'stored';
        OppList[1].Program_Enrolled_in__c  = 'Family Banking'; 
        update OppList;
        system.debug('The opportunity are-->'+OppList);
        //Assets with different freeze dates
        List<Asset> oppyAsset = new List<Asset>();
        oppyAsset=TestDataFactory.assetInsert();
        oppyAsset[0].Opportunity__c=OppList[0].id;
        oppyAsset[0].AccountId=providerAcc[0].id;
        oppyAsset[0].Status='Active';
        oppyAsset[0].FreezeDate__c=system.today();
        oppyAsset[1].Opportunity__c=OppList[1].id;
        oppyAsset[1].AccountId=providerAcc[1].id;
        oppyAsset[1].Status='Stored';
        oppyAsset[1].FreezeDate__c=system.today();
        oppyAsset[2].Opportunity__c=OppList[1].id;
        oppyAsset[2].AccountId=providerAcc[0].id;
        oppyAsset[2].Status='Stored';
        oppyAsset[2].FreezeDate__c=system.today();
        Insert oppyAsset;
        system.debug('The Asset are-->'+oppyAsset);
        //Opportunity Provider
        List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
        oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true));
        oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[1].id,Opportunity__c =OppList[1].id,Delivering_Provider__c=false));
        insert oppyProviderList;
    }
    public static testmethod void fetchPayTo_2(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=false, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,HPN_Provider_Agreement__c=lstPA[0].id,Status__c='Pending Accounting');
        insert pay;
        system.debug('The Payables are-->'+pay);
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='',Tax_ID__c='',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        insert lstPayTo;
        pay.CBR_PAY_TO__c=lstPayTo[0].id;
        update pay;
        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        system.assertEquals('Needs Attention',afterupdate.Status__c );
        //updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
        
    }
    public static testmethod void fetchPayTo_3(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,Status__c='Pending Accounting');
        insert pay;
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        pay.HPN_Provider_Agreement__c=lstPA[0].id;
        update pay;
        
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='6789',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='',Country__c='USA',State__c='Houston',Tax_ID__c='56789',Zip_Code__c='10009'));
        insert lstPayTo;
        
        aggrement.CBR_PAY_TO__c=lstPayTo[1].id;
        update aggrement;
        pay.CBR_PAY_TO__c=lstPayTo[1].id;
        update pay;
        
        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        //system.assertEquals('Needs Attention',afterupdate.Status__c );
        system.assertEquals(ass[0].Opportunity__r.id,afterupdate.Opportunity__c);
        // updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
    }
    public static testmethod void fetchPayTo_4(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,Status__c='Pending Accounting');
        insert pay;
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        pay.HPN_Provider_Agreement__c=lstPA[0].id;
        update pay;
        
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='10009',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='',Country__c='USA',State__c='Houston',Tax_ID__c='',Zip_Code__c='10009'));
        insert lstPayTo;
        
        aggrement.CBR_PAY_TO__c=lstPayTo[1].id;
        update aggrement;
        pay.CBR_PAY_TO__c=lstPayTo[1].id;
        update pay;
        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        system.assertEquals('Needs Attention',afterupdate.Status__c );
        system.assertEquals(ass[0].Opportunity__r.id,afterupdate.Opportunity__c);
        // updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
    }
    public static testmethod void fetchPayTo_5(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,Status__c='Pending Accounting');
        insert pay;
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        pay.HPN_Provider_Agreement__c=lstPA[0].id;
        update pay;
        
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='6789',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='',Country__c='USA',State__c='Houston',Tax_ID__c='56789',Zip_Code__c='10009'));
        insert lstPayTo;
        
        aggrement.CBR_PAY_TO__c=lstPayTo[1].id;
        update aggrement;
        pay.CBR_PAY_TO__c=lstPayTo[1].id;
        update pay;
        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        system.assertEquals('Needs Attention',afterupdate.Status__c );
        system.assertEquals(ass[0].Opportunity__r.id,afterupdate.Opportunity__c);
        // updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
    }
    public static testmethod void fetchPayTo_6(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,Status__c='Pending Accounting');
        insert pay;
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        pay.HPN_Provider_Agreement__c=lstPA[0].id;
        update pay;
        
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='6789',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='',Zip_Code__c='10009'));
        insert lstPayTo;
        
        aggrement.CBR_PAY_TO__c=lstPayTo[1].id;
        update aggrement;
        pay.CBR_PAY_TO__c=lstPayTo[1].id;
        update pay;
        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        system.assertEquals('Needs Attention',afterupdate.Status__c );
        system.assertEquals(ass[0].Opportunity__r.id,afterupdate.Opportunity__c);
        // updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
    }
    public static testmethod void fetchPayTo_7(){
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=acc[0].id,Status__c='Pending Accounting');
        insert pay;
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=acc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=false, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        pay.HPN_Provider_Agreement__c=lstPA[0].id;
        update pay;
        
        test.startTest();
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipCBR_PaytoValidation__c = true;
        upsert byPassSetting;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=false,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='6789',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='',Zip_Code__c='10009'));
        insert lstPayTo;
        

        invokePayableStatusUpdateBatch.executeBatchJob();
        schedulePayableStatusUpdate newbatch = new schedulePayableStatusUpdate();
        String cronstr = '0 0 0 ? * *';
        id jobid = System.schedule('Payable Records status Update', cronStr, newbatch);
        Test.stopTest();
        Payable__c afterupdate=[select id,name,Status__c,Opportunity__c,Agreement__c,Provider_ID__c from Payable__c ];
        system.assertEquals('Needs Attention',afterupdate.Status__c );
        system.assertEquals(ass[0].Opportunity__r.id,afterupdate.Opportunity__c);
        // updatepayableStatus_Batch abc= new updatepayableStatus_Batch();
        //Id batchJobId = Database.executeBatch(abc, 200);
    }
    
}