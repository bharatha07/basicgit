/**
* @File Name          : BatchToUpdateProfileURLToBlankTest .cls
* @Description        : Test class for Main class BatchToUpdateProfileURLToBlank.
* @Author             : Teksystems
* @story              : SFDC-1856
* @Created date       : 20/09/2021
**/
@isTest
public class BatchToUpdateProfileURLToBlankTest {
    
    public static testMethod void BatchToUpdateProfileURLToBlankTestMethod(){
        Id consumerRrdTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        ID facilityRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        ID provideryRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        
        List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAccountList,providerAccountList);
        
        Account Facilityaccount= new Account(Name = 'Facilitytype',Master_Facility_Id__c = 'MasterFac',RecordtypeId =facilityRecordTypeId1 ,Status__c = 'Active' ,type = 'Hospital');
        insert Facilityaccount;
        
        Account consumerAccountDOB = new Account(RecordtypeId = consumerRrdTypeId1,FirstName = 'TestFirst666',LastName = 'TestLas3t6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-999),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301',Kit_Location__c='Test');
        insert  consumerAccountDOB;
        
        //Account provideraccount= new Account(FirstName = 'Provider1this',LastName = 'Testtoday',Master_Facility_Id__c = 'MasterProvider1',RecordtypeId =provideryRecordTypeId1,Status__c = 'Active');
        //insert provideraccount;
        
        Opportunity opp1 = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccountDOB.id,Delivering_Hospital__c=Facilityaccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='Auto Enrolled',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 12 month',CT_Storage_Option__c='18 Years',CB_Storage_Option__c='Annual Storage',Profile_Complete__c=false,Profile_URL__c='Test');
        insert opp1;
        
        opp1.Status__c='Enrolled';
        opp1.Enrollment_Date__c=system.now();
        update opp1;
        system.debug('opp1.Status__c>>'+opp1.Status__c);
        system.debug('opp1.Enrollment_Date__c>>'+opp1.Enrollment_Date__c);
        
        Opportunity_Provider__c Oppyprovider= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=opp1.id,Primary_Provider__c =true,Provider_Facility__c = providerFacilityList[0].id);
        Insert Oppyprovider;
        
        Test.startTest();
        BatchToUpdateProfileURLToBlankScheduler oppbatch = new BatchToUpdateProfileURLToBlankScheduler();
        oppbatch.execute(null);  
        Test.stopTest();
        
        Opportunity opp2 = [select id,Profile_URL__c from opportunity WHERE id =:opp1.id limit 1];
        system.assertEquals(null, opp2.Profile_URL__c);
        
    }
}