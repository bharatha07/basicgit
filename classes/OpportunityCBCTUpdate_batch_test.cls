/*************************************************
*Component Name:OpportunityCBCTUpdate_batch_test
Description: Batch Job to update CB and CT count from Assets to Opportunity
Created By: Teksystems
**************************************************/
@istest
private class OpportunityCBCTUpdate_batch_test {
    static testmethod void Oppo_testbatch(){
        opportunity opp=new opportunity();
        opp.Name='Test1';
        opp.Status__c='Stored';
        opp.Stored_CB__c=0;
        opp.Stored_CT__c=0;
        opp.StageName='Open';
        opp.Storage_Date__c=system.today();
        opp.CloseDate=system.today()+3;
        insert opp;
        
        List<Account> acclist=TestDataFactory.createConsumerAccounts();
        Asset ass=new Asset();
        ass.Name='Test2';
        ass.Status='Stored';
        ass.Type__c='Cord Blood';
        ass.Opportunity__c=opp.id;
        ass.AccountId=acclist[0].id;
        insert ass;
        
        opp.Status__c='Stored';
        update opp;  
        
        Test.startTest();
        OpportunityCBCTUpdate_batch obj =new OpportunityCBCTUpdate_batch();
        Database.executeBatch(obj, 200);
        Test.stopTest();
        
        Opportunity oppa=[select id ,Stored_CB__c, name from opportunity where id=:opp.id limit 1];
        system.assertEquals(oppa.Stored_CB__c, 1);
       
        
    }
}