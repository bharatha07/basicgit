/*************************************************
*Component Name:OpportunityCBCTUpdate_batchv2_Test
Description: Batch Job to update CB and CT count from Assets to Opportunity
Created By: Teksystems
**************************************************/
@istest
public class OpportunityCBCTUpdate_batchv2_Test {
    static testmethod void Oppo_testbatchv2(){
        opportunity opp=new opportunity();
        opp.Name='Testing';
        opp.Status__c='Stored';
        opp.Stored_CB__c=0;
        opp.StageName='Open';
        opp.Storage_Date__c=system.today();
        opp.CloseDate=system.today()+3;
        insert opp;
        
        List<Account> acclist=TestDataFactory.createConsumerAccounts();
        Asset ass=new Asset();
        ass.Name='Test2';
        ass.Status='Stored';
        ass.Type__c='Cord Blood';
        ass.DiscontinuedStorage__c=True;
        ass.Opportunity__c=opp.id;
        ass.AccountId=acclist[0].id;
        insert ass;
        
        Test.startTest();
         OpportunityCBCTUpdate_batchv2 obj =new  OpportunityCBCTUpdate_batchv2();
        Database.executeBatch(obj, 200);
        Test.stopTest();    
    }
        public static testmethod void Oppo_testbatchv3(){
        opportunity opp=new opportunity();
        opp.Name='Testing';
        opp.Status__c='Stored';
        opp.Stored_CT__c=0;
        opp.StageName='Open';
        opp.Storage_Date__c=system.today();
        opp.CloseDate=system.today()+3;
        insert opp;
            
        List<Account> acclist1=TestDataFactory.createConsumerAccounts();   
        Asset asse=new Asset();
        asse.Name='Test3';
        asse.Status='Stored';
        asse.Type__c='Cord Tissue';
        asse.DiscontinuedStorage__c=False;
        asse.Opportunity__c=opp.id;
        asse.AccountId=acclist1[0].id;
        insert asse;
            
        Test.startTest();
         OpportunityCBCTUpdate_batchv2 obj =new  OpportunityCBCTUpdate_batchv2();
        Database.executeBatch(obj, 200);
        Test.stopTest();
        
        Opportunity oppa=[select id ,Stored_CT__c,Stored_CB__c, name from opportunity where id=:opp.id limit 1];
         system.assertEquals(oppa.Stored_CT__c, 1);
             system.assertEquals(oppa.Stored_CB__c, 0);  
}

      @isTest
    public static void testScheduler(){
          String query = 'SELECT Id, Name, Status__c,Stored_CB__c,Stored_CT__c FROM Opportunity Where Status__c=\'Stored\'';
        Test.startTest();
        OpportunityCBCTUpdate_batchv2Scheduler sch = new OpportunityCBCTUpdate_batchv2Scheduler();
        sch.execute(null);
        Test.stopTest();
    }
}