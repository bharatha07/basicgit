@isTest
public class FaxButtonControllerTest {
    public static testMethod void OpportunitySendFaxEmailTestMethod(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        List<Opportunity> facstatlist =new List<Opportunity>();
        List<Asset> asstList = new List<Asset>();
        List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAccountList,providerAccountList);
        set<id> oplst = new set<id>();
        
        test.startTest();
        facilityAccountList[3].Fax='987654321';
        update facilityAccountList[3];
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test1',StageName = 'Marketing Qualified',status__c = 'Open'));
        insert optyList;
        List<Asset> assetList  = TestDataFactory.assetInsert();
        assetList[0].AccountId=providerAccountList[3].id;
        assetList[0].Opportunity__c=optyList[0].id;
        asstList.add(assetList[0]);
        
        
        assetList[1].AccountId=providerAccountList[3].id;
        assetList[1].Opportunity__c=optyList[0].id;
        asstList.add(assetList[1]);
        
        insert asstList;
        List<Opportunity_Provider__c> oppProviderlist = new List<Opportunity_Provider__c>();
        oppProviderlist.add(new Opportunity_Provider__c(Facility__c = facilityAccountList[3].id ,Provider__c = providerAccountList[3].id,Primary_Provider__c = true,Opportunity__c = optyList[0].id,Provider_Facility__c = providerFacilityList[3].id));
        insert oppProviderlist;
        
        optyList[0].Enrollment_Date__c=system.now();
        optyList[0].status__c='Enrolled';
        optyList[0].of_CB__c='0';
        optyList[0].of_CT__c='1';
        update optyList[0];
        system.debug('the updated opty-->'+optyList);
        List<Asset> astListStrd = new List<Asset>();
        List<Asset> assList =[select id,status,type__c,opportunity__c from Asset where Opportunity__c =:assetList[0].Opportunity__c];
        assList[0].Status='Stored';
        assList[1].Status='Stored';
        astListStrd.add(assList[0]);
        astListStrd.add(assList[1]);
        update astListStrd;
        FaxButtonController.validationWrapper enrollmentFax= new FaxButtonController.validationWrapper();
        enrollmentFax=FaxButtonController.validateOpportunity(optyList[0].id,true,false);
        FaxButtonController.validationWrapper storageFax= new FaxButtonController.validationWrapper();
        storageFax=FaxButtonController.validateOpportunity(optyList[0].id,false,true);
        Test.stopTest();
        
    }
}