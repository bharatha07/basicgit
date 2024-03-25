@isTest
public class createPayableController_Test {
    
    @testSetup static void datasetup() {
        
        String prgmBank ='Newborn Possibilities Program - Low Apgar Protocol';
        //Consumer Accounts
        List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
        //Provider Accounts
        // List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
        // providerAcc[0].HPN_Flag__c=false;
        //providerAcc[1].HPN_Flag__c=true;
        //update providerAcc;
        
        List<Account> providerAcc = new List<Account>();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        providerAcc.add(new Account(FirstName = 'Provider1',LastName = 'Test1',Master_Facility_Id__c = 'MasterProvider1',RecordtypeId =providerRecordTypeId,Status__c = 'Active',HPN_Flag__c=false));
        providerAcc.add(new Account(FirstName = 'Provider2',LastName = 'Test2',Master_Facility_Id__c = 'MasterProvider2',RecordtypeId =providerRecordTypeId,Status__c = 'Active',HPN_Flag__c=false));
        insert providerAcc;
        //system.debug('The provideraccount are-->'+providerAcc);
        //opportunity as Stored
        List<Opportunity> optyList=new list<Opportunity>();
        List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
        //optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAcc[0].id,Referral_Name__c='Test1',StageName = 'Pending',status__c = 'Stored',Program_Enrolled_in__c='Newborn Possibilities Program - Low Apgar Protocol'));
        //insert optyList;
        //OppList[0].Storage_Date__c = system.today();
        OppList[0].Status__c = 'Stored';
        OppList[0].Program_Enrolled_in__c  = 'Family Banking';
        //OppList[1].Storage_Date__c =system.today();
        OppList[1].Status__c = 'Stored';
        OppList[1].Program_Enrolled_in__c  = prgmBank; 
        //system.debug('OppList[1].Program_Enrolled_in__c>>>'+OppList[1].Program_Enrolled_in__c);
        update OppList;
        //system.debug('The opportunity are-->'+OppList[1]);
        //Assets with different freeze dates
        List<Asset> oppyAsset = new List<Asset>();
         List<Asset> oppyAsset1 = new List<Asset>();
        oppyAsset=TestDataFactory.assetInsert();
        oppyAsset[0].Opportunity__c=OppList[0].id;
        oppyAsset[0].AccountId=providerAcc[1].id;
        oppyAsset[0].ContactID=providerAcc[1].PersonContactId;
        oppyAsset[0].Status='Arrived At Lab';
        oppyAsset[0].FreezeDate__c=system.today();
        oppyAsset[1].Opportunity__c=OppList[1].id;
        oppyAsset[1].AccountId=providerAcc[1].id;
        oppyAsset[1].Status='Stored';
        oppyAsset[1].FreezeDate__c=system.today();
        oppyAsset[1].ContactID=providerAcc[1].PersonContactId;
        oppyAsset[2].Opportunity__c=OppList[1].id;
        oppyAsset[2].AccountId=providerAcc[1].id;
        oppyAsset[2].Status='Stored';
        oppyAsset[2].FreezeDate__c=system.today();
        oppyAsset[2].ContactID=providerAcc[1].PersonContactId;
        oppyAsset1.add(oppyAsset[0]);
        oppyAsset1.add(oppyAsset[1]);
        oppyAsset1.add(oppyAsset[2]);
        insert oppyAsset1;
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        //system.debug('The Asset are111-->'+oppyAsset[1].Status);
        //Opportunity Provider
        List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
        oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true));
        oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[1].id,Opportunity__c =OppList[1].id,Delivering_Provider__c=true));
        insert oppyProviderList;
        system.debug('The Opportunity_Provider__c are-->'+oppyProviderList);
    }
    
    public static testmethod void checkpayable(){
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        
        Payable__c pay =new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=oppyProvider[0].Provider__r.id,Status__c='Special Handling');
        insert pay;
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
        Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=oppyProvider[0].Provider__r.id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
        provideragrrements.add(provideraggr1);
        insert provideragrrements;
        
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Provider_Agreement__c=provideragrrements[0].id,Active__c=true,Address__c='121',Address_2__c='Kilimanjaro',City__c='MY CITY',Country__c='United States',State__c='NEW YORK',Tax_ID__c='4567456765',Zip_Code__c='10009');
        activePayTo.add(payto1);
        system.debug('The Pay To\'s are-->'+activePayTo);
        insert activePayTo;
        
        createPayableController.validationWrapper wrap =new createPayableController.validationWrapper();
        wrap=createPayableController.validateRecord(ass[0].Id);
        system.debug('The Wrap is:'+wrap);
        system.assertEquals(true, wrap.errorCheck);
        system.assertEquals('Payable record exist for this Asset', wrap.message);
        
    }
    public static testmethod void checkAssetStatus(){
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
        Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=oppyProvider[0].Provider__r.id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
        provideragrrements.add(provideraggr1);
        insert provideragrrements;
        
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Provider_Agreement__c=provideragrrements[0].id,Active__c=true,Address__c='121',Address_2__c='Kilimanjaro',City__c='MY CITY',Country__c='United States',State__c='NEW YORK',Tax_ID__c='4567456765',Zip_Code__c='10009');
        activePayTo.add(payto1);
        system.debug('The Pay To\'s are-->'+activePayTo);
        insert activePayTo;
        
        createPayableController.validationWrapper wrap =new createPayableController.validationWrapper();
        wrap=createPayableController.validateRecord(ass[0].Id);
        system.debug('The Wrap is:'+wrap);
        system.assertEquals(true, wrap.errorCheck);
        system.assertEquals('Asset is not Stored', wrap.message);
        
    }
    public static testmethod void checkAllTrue(){
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        system.debug('The asst is:'+ass);
        system.debug('The asst is:'+ass[1]);
        system.debug('The asst is:'+ass[1].Opportunity__r.Status__c);
        ass[0].Status='Stored';
        update ass[0];
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
        Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=oppyProvider[0].Provider__r.id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
        provideragrrements.add(provideraggr1);
        insert provideragrrements;
        
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Provider_Agreement__c=provideragrrements[0].id,Active__c=true,Address__c='121',Address_2__c='Kilimanjaro',City__c='MY CITY',Country__c='United States',State__c='NEW YORK',Tax_ID__c='4567456765',Zip_Code__c='10009');
        activePayTo.add(payto1);
        system.debug('The Pay To\'s are-->'+activePayTo);
        insert activePayTo;
        
        createPayableController.validationWrapper wrap =new createPayableController.validationWrapper();
        wrap=createPayableController.validateRecord(ass[0].Id);
        system.debug('The Wrap is:'+wrap);
        system.assertEquals(false, wrap.errorCheck);
        system.assertEquals('Payable Record Created Successfully', wrap.message);
        
    }    
    public static testmethod void checkOpportunityStatus(){
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        system.debug('The asst is:'+ass);
        system.debug('The asst is:'+ass[0]);
        system.debug('The asst is:'+ass[0].Opportunity__r.Status__c);
        
        
        
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[1].Opportunity__r.id];
        System.debug('The Opyprovider is -->'+oppyProvider);
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        System.debug('The Program is -->'+program);
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
        Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=oppyProvider[0].Provider__r.id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
        provideragrrements.add(provideraggr1);
        insert provideragrrements;
        System.debug('The Provideragreements is -->'+provideragrrements);
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Provider_Agreement__c=provideragrrements[0].id,Active__c=true,Address__c='121',Address_2__c='Kilimanjaro',City__c='MY CITY',Country__c='United States',State__c='NEW YORK',Tax_ID__c='4567456765',Zip_Code__c='10009');
        activePayTo.add(payto1);
        system.debug('The Pay To\'s are-->'+activePayTo);
        insert activePayTo;
        createPayableController.validationWrapper wrap =new createPayableController.validationWrapper();
        wrap=createPayableController.validateRecord(ass[1].Id);
        system.debug('The Wrap is:'+wrap);
        system.assertEquals(true, wrap.errorCheck);
        system.assertEquals('Opportunity Program is NPP', wrap.message);
        
    }
    public static testmethod void checkpayable1(){
        String prgmBank ='Newborn Possibilities Program - Low Apgar Protocol';
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset];
        
        Asset ass1 = [select id,Opportunity__c,Opportunity__r.status__c,Opportunity__r.Program_Enrolled_in__c,status from asset where id =:ass[0].id];
        ass1.Status = 'Stored';
        ass1.Opportunity__r.Program_Enrolled_in__c=prgmBank;
        update ass1;
        
        Asset secAss = [select id,Opportunity__c,Opportunity__r.status__c from asset where id =:ass1.Id];
        
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:secAss.Opportunity__c];
        Test.startTest();
        createPayableController.validationWrapper wrap =new createPayableController.validationWrapper();
        wrap=createPayableController.validateRecord(secAss.Id);
        Test.stopTest();
    }
    
}