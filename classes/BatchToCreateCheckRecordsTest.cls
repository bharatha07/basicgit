/**
* @File Name          : BatchToCreateCheckRecordsTest .cls
* @Description        : Batch to create to create check records group by PAY TO.
* @Author             : Teksystems
* @story              : SFDC-1485
* @Created date       : 09-Feb-2020 (Teksystems)
**/
@istest
public class BatchToCreateCheckRecordsTest {
    
    @istest
    public static void BatchToCreateCheckRecordsTestMethod(){
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
        List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
        List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
        providerAcc[0].HPN_Flag__c=true;
        update providerAcc;
        
        OppList[0].Status__c = 'stored';
        OppList[0].Program_Enrolled_in__c  = 'Family Banking';
        update OppList[0];
        
        List<Asset> oppyAsset = new List<Asset>();
        List<Asset> oppyAsset1 = new List<Asset>();
        oppyAsset=TestDataFactory.assetInsert();
        oppyAsset[0].Opportunity__c=OppList[0].id;
        oppyAsset[0].AccountId=providerAcc[0].id;
        oppyAsset[0].Status='Stored';
        oppyAsset[0].FreezeDate__c=System.now().addDays(-7);
        oppyAsset[1].Opportunity__c=OppList[0].id;
        oppyAsset[1].AccountId=providerAcc[1].id;
        oppyAsset[1].Status='Stored';
        oppyAsset[1].FreezeDate__c=System.now().addDays(-7);
        oppyAsset1.add(oppyAsset[0]);
        oppyAsset1.add(oppyAsset[1]);
        insert oppyAsset1;
         US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset where Opportunity__c =:OppList[0].id];
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='Test123',Zip_Code__c='10009',Provider_Agreement__c=lstPA[0].id));
        insert lstPayTo;
        
        List<Payable__c> PayBleLst= new List<Payable__c>();
        PayBleLst.add(new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=providerAcc[0].id,HPN_Provider_Agreement__c=lstPA[0].id,Status__c='Pending Accounting',CBR_PAY_TO__c=lstPayTo[0].id));
        PayBleLst.add(new Payable__c(Asset__c=ass[1].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=providerAcc[0].id,HPN_Provider_Agreement__c=lstPA[0].id,Status__c='Pending Accounting',CBR_PAY_TO__c=lstPayTo[0].id));
        insert PayBleLst;
        
        Test.startTest();
        BatchToCreateCheckRecordsScheduled batchable = new BatchToCreateCheckRecordsScheduled();
        batchable.Execute(null);
        test.stopTest();
        
        List<CBRChecks__c> chequeList = [select id,CBR_PAY_TO__c from CBRChecks__c where CBR_PAY_TO__c =: PayBleLst[0].CBR_PAY_TO__c];
        system.assertEquals(1, chequeList.size());
        
        List<Payable__c> payBle = [select id,CBRChecks__c from Payable__c where CBR_PAY_TO__c =: PayBleLst[0].CBR_PAY_TO__c];
        system.assertEquals(payBle[0].CBRChecks__c, chequeList[0].id);
        system.assertEquals(payBle[1].CBRChecks__c, chequeList[0].id);
    }
    
}