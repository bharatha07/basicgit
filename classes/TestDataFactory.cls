/**
 * @File Name          : TestDataFactory.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/19/2020, 1:19:03 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/19/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class TestDataFactory {
    //Create User Record
    public static User createTestUser(String profileName){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        User usr = new User(FirstName='Test'+profileName,LastName='User',Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName,UserPermissionsMarketingUser = true);
        insert usr;
        return usr;

    }
    //Create Facility Accounts
    public static List<Account> createFacilityAccounts(){
        Id facilityRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        List<Account> accList = new List<Account>();
       accList.add(new Account(Name = 'Facility1',Master_Facility_Id__c = 'MasterFac1',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active',Type__c = 'Office',type = 'Office'));
        accList.add(new Account(Name = 'Facility2',Master_Facility_Id__c = 'MasterFac2',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active',Type__c = 'Office' ,type = 'Office'));
        accList.add(new Account(Name = 'Facility3',Master_Facility_Id__c = 'MasterFac3',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active',Type__c = 'Office',type = 'Office'));
        accList.add(new Account(Name = 'Facility4',Master_Facility_Id__c = 'MasterFac4',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Office',type = 'Office'));
        accList.add(new Account(Name = 'Facility5',Master_Facility_Id__c = 'MasterFac5',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Hospital',type = 'Hospital'));
        accList.add(new Account(Name = 'Facility6',Master_Facility_Id__c = 'MasterFac6',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Hospital',type = 'Hospital'));
        accList.add(new Account(Name = 'Facility7',Master_Facility_Id__c = 'MasterFac7',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Hospital',type = 'Hospital'));
        accList.add(new Account(Name = 'Facility8',Master_Facility_Id__c = 'MasterFac8',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Hospital',type = 'Hospital'));
        accList.add(new Account(Name = 'Facility9',Master_Facility_Id__c = 'MasterFac9',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active' ,Type__c = 'Hospital',type = 'Hospital'));
        insert accList;

        return accList;
    }
    //Create provider Accounts
    public static LIst<Account> createProviderAccounts(){
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> accList = new List<Account>();
        accList.add(new Account(FirstName = 'Provider1',Provider_Status__c='Active',LastName = 'Test1',Master_Facility_Id__c = 'MasterProvider1',RecordtypeId =providerRecordTypeId,Status__c = 'Active'));
        accList.add(new Account(FirstName = 'Provider2',Provider_Status__c='Active',LastName = 'Test2',Master_Facility_Id__c = 'MasterProvider2',RecordtypeId =providerRecordTypeId,Status__c = 'Active'));
         accList.add(new Account(FirstName = 'Provider3',Provider_Status__c='Active',LastName = 'Test3',Master_Facility_Id__c = 'MasterProvider3',RecordtypeId =providerRecordTypeId,Status__c = 'Active'));
        accList.add(new Account(FirstName = 'Provider4',Provider_Status__c='Active',LastName = 'Test4',Master_Facility_Id__c = 'MasterProvider4',RecordtypeId =providerRecordTypeId,Status__c = 'Active'));

        insert accList;

        return accList;
    }

    //Create Person Accounts
    public static List<Account> createConsumerAccounts(){
        Id consumerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst1',LastName = 'TestLast1',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-2),PersonEmail = 'TestPersonEmail1@test.com',BillingStreet = 'Test12',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst2',LastName = 'TestLast2',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-4),PersonEmail = 'TestPersonEmail2@test.com',BillingStreet = 'Test',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst3',LastName = 'TestLast3',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-3),PersonEmail = 'TestPersonEmail3@test.com',BillingStreet = 'Test123',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst4',LastName = 'TestLast4',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail4@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,FirstName = 'TestFirst5',LastName = 'TestLast5',SCSS_Contact_Id__c='MS-1019',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        
        insert accList;

        return accList;
    }

    //create Opportunities.
    public static List<Opportunity> createOpportunities(List<Account> consumerAccList){
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccList[0].id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Twins',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',AX_Order_Id__c = '126232'));
        oppList.add(new Opportunity(Name= 'OppTest2',CloseDate = system.today().addDays(25),AccountId = consumerAccList[1].id,Due_Date__c = system.today().addDays(14),of_Babies__c = 'Twins',StageName = 'Ask for sale',Section_1_Received__c = false,Enrollment_Date__c = system.today().addDays(-2),status__c='Stored'));
        insert oppList;

        return oppList;
    }
    //Create custom setting records
    public static void CustomSettingRecords(){
        List<US_Zipcode__c> zipCodeList = new List<US_Zipcode__c>();
        zipCodeList.add(new US_Zipcode__c(City__c = 'New York',Country__c = 'US',Name = '10001'));
        zipCodeList.add(new US_Zipcode__c(City__c = 'New York',Country__c = 'US',Name = '94066'));
        zipCodeList.add(new US_Zipcode__c(City__c = 'Austin',Country__c = 'US',Name = '73301',State__c = 'TX'));
        insert zipCodeList;
       
    }
    //Create Provider Facility Records
    public static List<Provider_Facility__c> providerFacilityRecords(List<Account> facilityAccounts, List<Account> providerAccounts){
        
        List<Provider_Facility__c> providerFacilityList = new List<Provider_Facility__c>();
        providerFacilityList.add(new Provider_Facility__c(Provider__c =providerAccounts[0].id ,Facility__c = facilityAccounts[0].id,PF_Status__c = 'Active'));
        providerFacilityList.add(new Provider_Facility__c(Provider__c = providerAccounts[1].id,Facility__c = facilityAccounts[1].id,PF_Status__c = 'Active'));
        providerFacilityList.add(new Provider_Facility__c(Provider__c =providerAccounts[2].id ,Facility__c = facilityAccounts[2].id,PF_Status__c = 'Active'));
        providerFacilityList.add(new Provider_Facility__c(Provider__c = providerAccounts[3].id,Facility__c = facilityAccounts[3].id,PF_Status__c = 'Active'));

        insert providerFacilityList;
        return providerFacilityList;
    }
        //Create usZipCode record
    public static  US_Zipcode__c usZipCodeInsert(){
        US_Zipcode__c zipCodeList = new US_Zipcode__c(City__c = 'New York',Country__c = 'USA',Name = '10009',Territoryname__c='Testzip13',State__c='NEW YORK');
        insert zipCodeList;
        return zipCodeList;
       
    }
    
        //Create Lead record 
    public static  List<Lead> leadInsert(){
        List<Lead> lstlead = new List<Lead>();
        lstlead.add(new Lead(LastName='Test',FirstName='Lead',Due_Date__c=system.today(),Status='Manually Qualified',LeadSource='CSS Referral',Email='todaytest@test.com'));
        lstlead.add(new Lead(LastName='Test',FirstName='Lead1',Due_Date__c=system.today(),Status='Manually Qualified',LeadSource='CSS Referral',Email='todaytest1@test.com'));
        insert lstlead;
        return lstlead;
       
    }
     //Create Asset record 
        public static  List<Asset> assetInsert(){
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(new Asset(Name='Test Asset',Type__c='Cord Blood',Status='Arrived At Lab'));
        lstAsset.add(new Asset(Name='Test Asset1',Type__c='Cord Tissue',Status='Arrived At Lab'));
        lstAsset.add(new Asset(Name='Test Asset2',Type__c='Cord Tissue',Status='Released'));
        //lstAsset.add(new Asset(Name='Test Asset3',Type__c='Cord Tissue',Status='Stored'));
        return lstAsset;
       
    }
}