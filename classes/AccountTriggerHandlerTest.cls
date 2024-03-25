/******************************************************************************************************************************
*Component Name: AccountTriggerHandlerTest
*Created Date :
*Description : Test Class for AccountTriggerHandler
*Created By : Tejaswini Janda(TekSystems)
*******************************************************************************************************************************/
@isTest
public class AccountTriggerHandlerTest{
@isTest static void unitTest(){

List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
consumerAccountList[4].ID_Information__pc = '1212122111';
update consumerAccountList;
Consumer_Update_Event__e consumerevent = new Consumer_Update_Event__e(Consumer_ID__c=consumerAccountList[4].id,ID_Information_IsChanged__c = true);
Test.StartTest();
 Database.SaveResult saveResult = EventBus.publish(consumerevent);

Test.StopTest();
//System.assertEquals(true, saveResult.isSuccess());

}
@isTest static void unitTest1(){
Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
List<Account> consumerAccountList = new List<Account>();
Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
insert  consumerAccount;
Consumer_Update_Event__e consumerevent = new Consumer_Update_Event__e(Consumer_ID__c=consumerAccount.id,ID_Information_IsChanged__c = false);
Test.StartTest();
consumerAccountList.add(consumerAccount);
Database.SaveResult saveResult = EventBus.publish(consumerevent);
AccountTriggerHandler.handleAfterInsert(consumerAccountList,null,null,false);
//System.assertEquals(true, saveResult.isSuccess());
Test.StopTest();
}
@istest static void createOppOnLeadAssignmentTest(){
    User u = TestDataFactory.createTestUser('Marketo Sync');
    Test.startTest();
    System.runAs(u){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        
        consumerAccountList[0].Lead_Assignment__pc = 'Test Record';
        update consumerAccountList;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [select id from opportunity];
        System.debug('oppList----'+oppList);
       // System.assertEquals(oppList.size(), 1);
    }
    Test.StopTest();
    

}
@istest static void createCIOnLastTouchCodeUpdateTest(){
    User u = TestDataFactory.createTestUser('Marketo Sync');
    Test.startTest();
    System.runAs(u){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        List<OpportunityContact__C> optyContacs = [Select id from OpportunityContact__c];
        Campaign c = new Campaign(Name ='TestCampaign',Campaign_Code__c='Test Record11');
        insert c;
        system.debug('Campaign--'+c);
        consumerAccountList[0].Last_Touch_Code__pc = 'Test Record11';
        update consumerAccountList;
        System.debug('consumerAccountList--'+consumerAccountList[0]);
        List<CampaignInfluence> cIList = [SELECT id FROM campaignInfluence];
        System.debug('cIList---'+cIList);
        //System.assertEquals(cIList.size(), 1);
    }
    Test.StopTest();
    

}
@istest static void updatemarketoSyncOnAccForoptyConTest(){
    User u = TestDataFactory.createTestUser('Marketo Sync');
    Test.startTest();
    System.runAs(u){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        consumerAccountList[0].PersonEmail='';
        
        update consumerAccountList;
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        
       /* optyconList.add(new OpportunityContact__c(Role__c='Father',Opportunity__c=optyList[0].id,
                     PersonAccount__c=consumerAccountList[0].id));
        
        
        
        Insert optyconList;*/
        optyconList = [select id,Role__c,Opportunity__c,PersonAccount__c from OpportunityContact__c where personAccount__c =:consumerAccountList[0].id];
        optyconList[0].role__c = 'Father';
        update optyconList;
        consumerAccountList[0].PersonEmail='test11kk@test.com';
        OpportunityContact__C opCon=[select id , Name,Role__c,PersonAccount__c from OpportunityContact__C where Role__c='Father' limit 1 ];
       
        update consumerAccountList;
       Account acc1=[select id , PersonEmail,Marketo_Sync__pc from Account where PersonEmail='test11kk@test.com' limit 1 ];
       
      
       // System.assertEquals(acc1.Marketo_Sync__pc,true);
    }
    Test.StopTest();
    

}
  /*************************************************************************************************
     * @description This test method is used to test platform event(AWS) for email changed on Contact
     * @param - None
     * @story - SFDC-1042
     * @return Void
     * @date - 28-JULY-2020 (Teksystems)
     */
@isTest static void emailUpdateToAwsPFeventTest(){
    Test.startTest();

   List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        String emailvar=consumerAccountList[0].PersonEmail;
        List<Opportunity> optyList = TestDataFactory.createOpportunities(consumerAccountList);
        consumerAccountList[0].PersonEmail='testnew123@test.com';
        
        update consumerAccountList[0];
        List<OpportunityContact__c> optyconList = new List<OpportunityContact__c>();
        
       /* optyconList.add(new OpportunityContact__c(Role__c='Father',Primary__c=true,Opportunity__c=optyList[0].id,
                     PersonAccount__c=consumerAccountList[0].id));
   
        Insert optyconList; */
        optyconList = [select id,opportunity__c,Role__c,Primary__c,PersonAccount__c from OpportunityContact__c];


  Consumer_Email_Update_Event__e  consumerevent = new Consumer_Email_Update_Event__e (Consumer_Id__c =consumerAccountList[0].id,AccountEmailNew__c = consumerAccountList[0].PersonEmail,AccountEmailOld__c=emailvar);

 Database.SaveResult saveResult = EventBus.publish(consumerevent);

Test.StopTest();
System.assertEquals(true, saveResult.isSuccess());

}
/*@istest static void dupEmailPreventTest(){
    
    Test.startTest();
       try{ 
       Id consumerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
           User u = TestDataFactory.createTestUser('Marketo Sync');
           User u1 = TestDataFactory.createTestUser('System Administrator');
           
        List<Account> accList = new List<Account>();
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,OwnerId=u.id,FirstName = 'TestFirst1a',LastName = 'TestLast1a',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-3),PersonEmail = 'Test12345@test.com',BillingStreet = 'Test12',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
        accList.add(new Account(RecordtypeId = consumerRecordTypeId,OwnerId=u.id,FirstName = 'TestFirst1b',LastName = 'TestLast1b',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-2),PersonEmail = 'Test67890@test.com',BillingStreet = 'Test12',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301'));
          insert accList;
        List<Account> acclistL= new List<Account>();
         acclistL=[select id ,FirstName ,PersonEmail,OwnerId from Account where PersonEmail= 'Test12345@test.com' and FirstName ='TestFirst1a' limit 1 ];
       if(acclistL.size() > 0 ){
        acclistL[0].PersonEmail='Test6789012@test.com';
        acclistl[0].OwnerId=u1.id;
        }
        update acclistL;
           
           Map<Id,Account> oldMapAcc = new Map<Id,Account>();
           oldMapAcc.put(acclist[0].id, acclist[0]);
           Map<Id,Account> NewMapAcc = new Map<Id,Account>();
           NewMapAcc.put(acclistL[0].id, acclistL[0]);
          // AccountTriggerHandler.updateOptyOwner(NewMapAcc, oldMapAcc);
        
        
           }catch(DMLException e){
           
            system.assertEquals(e.getMessage(), e.getMessage()); 
            
        }
    
    Test.StopTest();
    }*/
    /*************************************************************************************************
     * @description This test method is used to test platform event(AX) for Kit Stocking flag TRUE  on Facility
     * @param - None
     * @story - SFDC-1151
     * @return Void
     * @date - 17-AUG-2020 (Teksystems)
     */
  @isTest static void kitStkUpdateToAXPFeventTest(){
    Test.startTest();
    List<Account> facilityAccountList = TestDataFactory.createFacilityAccounts();  
        facilityAccountList[0].Kit_Stocking__c=true;
        update facilityAccountList;
        Facility_Kit_Update_Event__e facilityevent = new Facility_Kit_Update_Event__e(Facility_Id__c=facilityAccountList[0].id);
        Database.SaveResult saveResult = EventBus.publish(facilityevent);
    Test.StopTest();
    System.assertEquals(true, saveResult.isSuccess());
   }
   /*************************************************************************************************
     * @description This test method is used to test platform event(AX) for ax customer id update on consumer
     * @param - None
     * @story - SFDC-1088
     * @return Void
     * @date - 18-AUG-2020 (Teksystems)
     */
    @isTest static void aXCusUpdatePFeventTest(){
        Test.startTest();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts(); 
        consumerAccountList[0].AX_Customer_Id__pc='testAxCusId';
        update consumerAccountList;
        Ax_Customer_Update_Event__e consumerevent = new Ax_Customer_Update_Event__e (Ax_Consumer_Id__c =consumerAccountList[0].id);
        Database.SaveResult saveResult = EventBus.publish(consumerevent );
        Test.StopTest();
        System.assertEquals(true, saveResult.isSuccess());
    }
    
    /*************************************************************************************************
     * @description This method is used to update provider facility Id with Facility Name and Provider name on change of account last name or first name.
     * @param - None
     * @story - SFDC-1208
     * @return Void
     * @date - 18-SEP-2020 (Teksystems)
     */
  @isTest static void updateProviderFaciltyIdTest(){
    Test.startTest();
      List<Account> accLstFac = TestDataFactory.createFacilityAccounts();
      List<Account> accLstPro = TestDataFactory.createProviderAccounts();
      List<Provider_Facility__c> prvFacLst = TestDataFactory.providerFacilityRecords(accLstFac, accLstPro);
      test.stopTest();
      accLstFac[0].Name = 'Facility6';
      update accLstFac[0];
      system.assertEquals('Facility6', accLstFac[0].Name);
  }
}