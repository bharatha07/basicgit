/*************************************************
*Component Name:ProviderFacility_batch_Test
Description: Batch to Update Provider address with Facility address
Created By: Teksystems
**************************************************/
@istest
public class ProviderFacility_batch_Test {
    static testmethod void Prov_testbatch(){
        list<Account> accPrv=new list<Account>();
        list<Account> accFac=new list<Account>();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        Id facilityRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        for(Integer i=0;i<25;i++){
            accPrv.add(new Account(FirstName = 'Provider'+i,LastName = 'Test'+i,Master_Facility_Id__c = 'MasterProvider'+i,
                                   RecordtypeId =providerRecordTypeId,Status__c = 'Active'));
            accFac.add(new Account(
                Name = 'Facility' + i,
                Master_Facility_Id__c = 'MasterFac'+i,
                RecordtypeId = facilityRecordTypeId, 
                Status__c = 'Active',
                Type = 'Office',
                BillingCity = 'Nanuet',
                BillingStreet = '55 Old Nyack Turnpike,Ste 405',
                BillingState = 'New York',
                BillingStateCode = 'NY',
                BillingPostalCode = '123456',
                BillingCountry = 'United States',
                BillingCountryCode = 'US'));
        }
        insert accPrv;
        insert accFac;
        list<Provider_Facility__c> provfac=new list<Provider_Facility__c>();
        Integer r;
        boolean pfPri=false;
        for(Integer i=0;i<25;i++){
            r = System.Math.mod(i, 2);
            pfPri= (r == 0 ? true : false);
            provfac.add(new Provider_Facility__c(Provider__c =accPrv[i].id ,Facility__c = accFac[i].id,PF_Status__c = 'Active', Primary__c = pfPri));
        }   if(provfac.size()>0)
        insert provfac;
        Test.startTest();
        ProviderFacility_batch obj =new ProviderFacility_batch();
        Database.executeBatch(obj, 200);
        Test.stopTest();
        Account acca=[select id ,BillingCity, name from Account where id=:accPrv[0].id limit 1];
        Account acca4=[select id ,BillingCity, name from Account where id=:accPrv[4].id limit 1];
        system.assertEquals('Nanuet',acca.BillingCity);
    }
    
}