/*************************************************
*Component Name:CountStoredOppBatchHistoricalDataTest
Description: Batch to Update Provider address with Facility address
Created By: Teksystems
**************************************************/
@istest
public class CountStoredOppBatchHistoricalDataTest {
 static testmethod void Prov_testbatch(){
        list<Account> accPrv=new list<Account>();
        List<Database.saveResult> saveresults = new List<Database.saveResult>();
   //  Id personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'].Id;
        Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
      Id consumerecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
     system.debug('value is'+providerRecordTypeId);  
     for(Integer i=0;i<3;i++){
            accPrv.add(new Account(FirstName = 'Provider'+i,LastName = 'Test'+i,Master_Facility_Id__c = 'MasterProvider'+i,
                                   RecordtypeId =consumerecordTypeId,Status__c = 'Active'));
            
        }
     accPrv[2].RecordtypeId =providerRecordTypeId;
        insert accPrv;
        system.debug('accPrv---'+accPrv);
     
        List<Opportunity> oppList = new List<Opportunity>();
       for(Integer i=0;i<3;i++){
           oppList.add(new Opportunity(Name= 'OppTest'+i,AccountId = accPrv[0].id,Lead_Role__c = 'Mother',StageName = 'Stored',Status__c = 'Stored',CloseDate = system.today()+3));
        }   if(oppList.size()>0)
        insert oppList;
      saveresults = database.insert(oppList,false);
     system.debug('saveresults----'+saveresults);
        list<Opportunity_Provider__c> oppPrv=new list<Opportunity_Provider__c>();
       
        for(Integer i=0;i<3;i++){
           oppPrv.add(new Opportunity_Provider__c(Provider__c =accPrv[2].id,Opportunity__c=oppList[i].id));
        }   if(oppPrv.size()>0)
        insert oppPrv;
        Test.startTest();
        CountStoredOppBatchHistoricalData obj =new CountStoredOppBatchHistoricalData();
        Database.executeBatch(obj, 200);
        Test.stopTest();
     Account accProvider= [SELECT Id,Stored_opportunities__c FROM Account WHERE ID =:accPrv[2].Id];
     System.assertEquals(3,accProvider.Stored_opportunities__c);
     
    }
}