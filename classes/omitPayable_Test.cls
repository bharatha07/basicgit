@isTest
public class omitPayable_Test {
    public static testmethod void testPayable(){
        
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
        oppyAsset[0].FreezeDate__c=system.today();
        oppyAsset[1].Opportunity__c=OppList[0].id;
        oppyAsset[1].AccountId=providerAcc[0].id;
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
        insert oppyProviderList;

        
        //List<Payable__c> pay = new List<Payable__c>();
        Payable__c pay =new Payable__c(Asset__c=oppyAsset[0].id,Opportunity__c=OppList[0].id,Provider_ID__c=providerAcc[0].id,Status__c='Special Handling');
        insert pay;
        system.assertEquals('Special Handling', pay.Status__c);
        Payable__c payresult=omitPayable.getPayable(string.valueOf(pay.id),true);
        system.assertEquals('Special Handling', payresult.Status__c);
        Payable__c payresult1=omitPayable.getPayable(string.valueOf(pay.id),false);
        system.assertEquals('Omit', payresult1.Status__c);
        
        
    }
}