/*******************************************************************************************************************************************
*Component Name: batchToUpdateCBCTOnProviders_Test
*Description: Test class for batchToUpdateCBCTOnProviders.
*Created By: TEKsystems(Tejaswini)
*Created Date: 
************************************************************************************************************************************************/
@isTest
public class batchToUpdateCBCTOnProviders_Test{
    @testSetup static void testDatsetup(){
        list<Account> accPrv=new list<Account>();
        List<Account> providersToUpdate = new List<Account>();
        List<Database.saveResult> saveresults = new List<Database.saveResult>();
        List<Database.saveResult> saveresults1 = new List<Database.saveResult>();
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        Id consumerecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        for(Integer i=0;i<3;i++){
            accPrv.add(new Account(FirstName = 'Provider'+i,LastName = 'Test'+i,Master_Facility_Id__c = 'MasterProvider'+i,
                                   RecordtypeId =consumerecordTypeId ,Status__c = 'Active'));
            
        }
        accPrv[2].RecordtypeId =providerRecordTypeId;
        insert accPrv;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<3;i++){
            oppList.add(new Opportunity(Name= 'OppTest'+i,of_Babies__c='Twins',AccountId = accPrv[0].id,Lead_Role__c = 'Mother',StageName = 'Stored',Stored_CB__c=1,Stored_CT__c = 2,Status__c = 'Stored',CloseDate = system.today()+3));
        }  
        if(oppList.size()>0)
            insert oppList;
        saveresults = database.insert(oppList,false);
        system.debug('oppList===='+oppList);
        list<Opportunity_Provider__c> oppPrv=new list<Opportunity_Provider__c>();   
        for(Integer i=0;i<3;i++){
            oppPrv.add(new Opportunity_Provider__c(Provider__c =accPrv[2].id,Opportunity__c=oppList[i].id,Primary_Provider__c = true));
        }   if(oppPrv.size()>0)
            insert oppPrv;
        saveresults1=database.insert(oppPrv,false);
    }
    @istest
    public static void TestMethod1(){
        
       /* List<Opportunity> optyList = new List<Opportunity>();
        for(Integer i=0;i<3;i++){
            
            optyList.add(new Opportunity(Name= 'OppTest'+i,AccountId = accPrv[0].id,StageName = 'Stored',CloseDate = system.today(),CBCTCountUpdatedOnProvider__c=false));
            
        }  
        insert optyList; */
        List<Opportunity> oppList = [select id,Status__c, AccountId,of_CT__c,of_CB__c,Stored_CB__c,Stored_CT__c,CBCTCountUpdatedOnProvider__c from opportunity];
        system.debug('opty stored in testmethod1---'+oppList);
        Test.startTest();
        batchToUpdateCBCTOnProviders obj =new batchToUpdateCBCTOnProviders();
        Database.executeBatch(obj, 200);
        Test.stopTest();
        
       
        List<Account> providersList = [select id,of_CB_Collected__c,of_CT_Collected__c from Account where Recordtype.Name = 'Provider'];
       system.debug('providersList===='+providersList);
       
            system.assertEquals(3,providersList[0].of_CB_Collected__c);
            system.assertEquals(6,providersList[0].of_CT_Collected__c);
       
    }
    @isTest
    public static void testScheduler(){
         List<Opportunity> oppList = [select id,Status__c, AccountId,Stored_CT__c,Stored_CB__c,CBCTCountUpdatedOnProvider__c from opportunity];
        Test.startTest();
        batchToUpdateCBCTOnProvidersScheduler sch = new batchToUpdateCBCTOnProvidersScheduler();
        sch.execute(null);
        Test.stopTest();
    }
}