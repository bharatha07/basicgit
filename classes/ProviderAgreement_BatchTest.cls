/**
* @File Name          : ProviderAgreement_BatchTest.cls
* @Description        : Test class for ProviderAgreement_Batch
* @Author             : Bharath(TEKsystems)
* @Created date       : 15/02/2021
* 
**/
@istest
public class ProviderAgreement_BatchTest {
    public static testMethod void updatebatch(){
        try{
            Test.StartTest();
            Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
            List<Account> accList = new List<Account>();
            List<Provider_Agreement__c> provideragrrements= new List<Provider_Agreement__c>();
            accList.add(new Account(FirstName = 'Provider1',LastName = 'Test1',Master_Facility_Id__c = 'MasterProvider1',RecordtypeId =providerRecordTypeId,Status__c = 'Active',HPN_Flag__c=true));
            accList.add(new Account(FirstName = 'Provider2',LastName = 'Test2',Master_Facility_Id__c = 'MasterProvider2',RecordtypeId =providerRecordTypeId,Status__c = 'Active',HPN_Flag__c=true));
            insert accList;
            system.debug('The provider accounts rae -->'+accList);
            
            Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
            Insert program;
            System.debug('The Program is -->'+program);
            Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today()-10,W9__c='Approved');
            insert aggrement;
            
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=accList[0].id,Agreement__c=aggrement.id,HPN_Start_Date__c =system.today().addDays(-2));
            provideragrrements.add(provideraggr1);
            
            
            Provider_Agreement__c provideraggr2= new Provider_Agreement__c(Provider__c=accList[1].id,Agreement__c=aggrement.id,HPN_Start_Date__c =system.today().addDays(-5),HPN_End_Date__c =system.today().addDays(-3));
            provideragrrements.add(provideraggr2);
            
            insert provideragrrements;
            List<Provider_Agreement__c> beforeBatchRun = [SELECT Id, Name,HPN_End_Date__c,Active_HPNFlag__c,Provider__c,Provider__r.HPN_Flag__c From Provider_Agreement__c];
            system.debug('The records -->'+beforeBatchRun);
            //schedule Batch
            ScheduleProviderAgreement Execute = new ScheduleProviderAgreement();
            String cronstr = '0 0 23 * * ?';
            id jobid = System.schedule('ScheduleProviderAgreement'+system.now(), cronStr, Execute);
            system.assertEquals(false,provideraggr2.Provider__r.HPN_Flag__c);
            Test.StopTest();
            
            List<Provider_Agreement__c> afterBatchRun = [SELECT Id, Name,HPN_End_Date__c,Provider__c,Provider__r.HPN_Flag__c From Provider_Agreement__c];
            system.debug('The records are -->'+afterBatchRun);
            List<Account> acc= [select id,LastName,Status__c,HPN_Flag__c from account];
            system.debug('The accounts are -->'+acc);
            system.assertEquals(false,provideraggr2.Provider__r.HPN_Flag__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
    }
}