/*******************************************************************************************************************************************
*Component Name: batchToUpdateCBCTOnDelHospitalsTest
*Description: Test class for batchToUpdateCBCTOnDeliveringFacilities.
*Created By: TEKsystems(Tejaswini)
*Created Date: 
************************************************************************************************************************************************/
@isTest
public class batchToUpdateCBCTOnDelHospitalsTest{
    @testSetup 
    public static void testDatsetup(){
        list<Account> providers = TestDataFactory.createProviderAccounts();
        List<Database.saveResult> saveresults = new List<Database.saveResult>();
        List<Account> facilityAccounts = TestDataFactory.createFacilityAccounts();
        Account delHospital = new Account();
        for(Account facility:facilityAccounts){
            if(facility.Type__c=='Hospital'){
                delHospital = facility;
            }
        }
        
        List<Opportunity> optylist = new List<Opportunity>();
        for(Integer i=0;i<3;i++){
            optylist.add(new Opportunity(Name= 'OppTest'+i,of_Babies__c='Twins',Delivering_Hospital__c = delHospital.id,Lead_Role__c = 'Mother',StageName = 'Stored',Stored_CB__c=1,Stored_CT__c = 2,Status__c = 'Stored',CloseDate = system.today()+3,CB_CT_CountUpdatedOnDeliveringHospital__c =false));
        }  
        if(optylist.size()>0)
            insert optylist;
        saveresults = database.insert(optylist,false);
        system.debug('oppList===='+optylist);
       
    }
    @isTest static void testMethod1(){
        List<Opportunity> oppList = [select id,Status__c,Stored_CB__c,Stored_CT__c, Delivering_Hospital__c from opportunity];
        system.debug('oppList-----------'+oppList);
        Test.startTest();
        Date today = system.today();
        batchToUpdateCBCTOnDeliveringFacilities obj =new batchToUpdateCBCTOnDeliveringFacilities();
        Database.executeBatch(obj, 200);
        Test.stopTest();
         List<Account> facilitylist = [select id,of_CB_Collected__c,of_CT_Collected__c from Account where Recordtype.Name = 'Facility' AND Type__c='Hospital'];
       system.debug('facilitylist===='+facilitylist);
       
           system.assertEquals(3,facilitylist[0].of_CB_Collected__c);
           system.assertEquals(6,facilitylist[0].of_CT_Collected__c);
       
    }
    @isTest static void testMethod2(){
        List<Opportunity> oppList = [select id,Status__c,Stored_CB__c,Stored_CT__c, Delivering_Hospital__c from opportunity];
        Test.StartTest();
            batchToUpdateCBCTOnFacilitiesScheduler sch = new batchToUpdateCBCTOnFacilitiesScheduler();
            sch.execute(null);
        Test.Stoptest();
    }
}