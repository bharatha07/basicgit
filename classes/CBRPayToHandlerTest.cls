/******************************************************************************************************************************
*Component Name: CBRPayToHandlerTest
*Created Date :
*Description : Test Class for CBRPayToHandler
*Created By : TekSystems
*******************************************************************************************************************************/
@isTest
public class CBRPayToHandlerTest {
    
    @isTest static void updateCityStateCountryTestMethod(){
        
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        usZipCode.State__c='ton';
        update usZipCode;
        
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',Zip_Code__c='10009',Tax_ID__c='4567456765'));
        insert lstPayTo;
        
        CBR_PAY_TO__c payTo = [select id,Zip_Code__c,State__c,Country__c,City__c from CBR_PAY_TO__c where id =:lstPayTo[0].id];
        system.assertEquals(payTo.City__c, usZipCode.City__c);
        system.assertEquals(payTo.State__c, usZipCode.State__c);
        system.assertEquals(payTo.Country__c, usZipCode.Country__c);
    }
    public static testmethod void updatePayableStatusTest(){
        
        // Insert Zip codes
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        //usZipCode.State__c='ton';
        //update usZipCode;
        
        //Insert payto
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Active__c=true,Address__c='121',Address_2__c='Kilimanjaro',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='4567456765',Zip_Code__c='10009');
        activePayTo.add(payto1);
        insert activePayTo;
        
        // Insert Payable
        Payable__c payables= new Payable__c();
        payables.CBR_PAY_TO__c=activePayTo[0].id;
        payables.Status__c='Needs Attention';
        insert payables;
        
        
        activePayTo[0].Address__c='mgroad';
        update activePayTo[0];
        activePayTo.add(activePayTo[0]);
        
        CBRPayToHandler.updatePayableStatus(activePayTo);
        
        Payable__c updatedpayable=[select id,name,Status__c from Payable__c ];
        
        system.assertEquals('Pending Accounting',updatedpayable.Status__c);
        
    }
    public static testmethod void updatePayableStatusTest1(){
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
        List<CBR_PAY_TO__c> activePayTo = new List<CBR_PAY_TO__c>();
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
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
        Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5), Pay_to_Group__c=false);
        provideragrrements.add(provideraggr1);
        insert provideragrrements;
        
        CBR_PAY_TO__c payto1= new CBR_PAY_TO__c(Name='Test Payto',Active__c=false,Address__c='121',Address_2__c='Kilimanjaro',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='4567456765',Zip_Code__c='10009',Provider_Agreement__c=provideragrrements[0].id);
        activePayTo.add(payto1);
        insert activePayTo;
        
        test.StartTest();
        payableRecordsCreation_Batch abc= new payableRecordsCreation_Batch(2);
        Id batchJobId = Database.executeBatch(abc, 200);
        Test.Stoptest();
        
        List<Payable__c> allpayable=[select id,name,Asset__c,Status__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c IN:oppyAsset];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
        allpayable[0].Status__c='Needs Attention';
        allpayable[0].Declined_Reason__c='No Active PayTo For ProviderAgreement';
        update allpayable[0];
        activePayTo[0].Active__c=true;
        update activePayTo[0];
    }
}