@isTest
public class SyncFacilityBillingAddressTest {
    static testMethod void syncFacilityBillingAddress(){
        List<id> accounts= new List<id>();
        test.startTest();
        /*Id facilityRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        Account acc= new Account();
        acc.Name='TestAccount';
        acc.RecordTypeId=facilityRecordTypeId;
        acc.Master_Facility_Id__c='MasterFac1';
        acc.Status__c = 'Active';
        acc.Type__c = 'Hospital';
        acc.BillingCity='Orlando';
        insert acc;
        acc.BillingCity='tuscon';
        update acc;
        accounts.add(acc.id);*/
       
       
        // Lead leead = [Select id,LeadSource from Lead where LeadSource = 'CSS Refferal'];
        // AutoConvertLeads.LeadAssign(leead.Id);
        List<Account> Faciityrecords= TestDataFactory.createFacilityAccounts();
        //insert Faciityrecords;
        List<Account>  Providerrecords=TestDataFactory.createProviderAccounts(); 
         //insert Providerrecords;
        List<Provider_Facility__c> providerFacility=TestDataFactory.providerFacilityRecords(Faciityrecords,Providerrecords);
        providerFacility[0].Primary__c=true;
        update providerFacility[0];
        //Insert providerFacility;
        Faciityrecords[0].BillingCity='Orlando';
        update Faciityrecords[0];
        accounts.add(Faciityrecords[0].id);
        SyncFacilityBillingAddress.updateBillingAddress(accounts);
         test.stopTest();
    } 
}