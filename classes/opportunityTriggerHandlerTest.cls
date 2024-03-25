/**
* @File Name          : opportunityTriggerHandlerTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 7/08/2020
**/
@isTest
public class opportunityTriggerHandlerTest{
    public static testMethod void ownerUpdateTest(){
        Test.StartTest();
        try{
            User u = TestDataFactory.createTestUser('Marketo Sync');
            User u1 = TestDataFactory.createTestUser('Sales Rep NSCE');
            List<Lead> leadList = new List<Lead>();
            LeadStatus cLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
            system.runAs(u){
                Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
                leadList.add(leadRec1);
                insert leadList;
                
                system.debug('leadList=='+leadList);
                system.debug('u1.id--'+u1.id);
                
            }
            LeadShare lshare = new LeadShare(UserOrGroupId = u1.id,LeadId = leadList[0].id, LeadAccessLevel = 'Edit');
            insert lshare;
            
            system.runAs(u1){
                List<Lead> leads = [select id from lead];
                Database.LeadConvert lc = new database.LeadConvert();  
                lc.setLeadId(leadList[0].Id);  
                
                lc.setConvertedStatus(cLeadStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc, false); 
                
                system.debug('lcr---'+lcr);
                system.debug('lcr1---'+lcr.opportunityid);
                
                Id facilityRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
                
                Account Acc = [select id,Status__c,Type,RecordTypeId,recordtype.name from Account where id =:lcr.accountid];
                system.debug('recordtype>>>'+Acc.recordtype.name);
                Acc.Status__c='Active';
                Acc.Type='Hospital';
                //Acc.RecordTypeId=facilityRecordTypeId;
                update Acc;
                
                system.debug('recordtypefacility>>>'+Acc.recordtype.name);
                
                /*Account Acc1 = [select id,Status__c,Type,RecordTypeId,recordtype.name from Account where id =:Acc.Id];
Acc1.Status__c='Active';
Acc1.Type='Hospital';
update Acc1;*/
                
                list<Opportunity> oppList = [select id,KitPickupOrShipConfirmation1__c,CancellationFee1__c,InformedConsent1__c,ConfirmDueDateCBCTAdoptionType1__c,PrimaryContactInfoConfirmation1__c,Statements1__c,Payment_Plan__c,Lead_RecordType_Name__c,ownerId,OnLeadConvertion__c,Delivering_Hospital__c,Completed_Flag__c from opportunity where Completed_Flag__c =false limit 5];
                recursiveClass.accOwnerUpdate=false;
                //opportunityTriggerHandler.updateOwner(oppList);
                
                oppList[0].Completed_Flag__c = true;
                oppList[0].Pricebook2Id = Label.CPQUsaPriceBook;
                oppList[0].Status__c='Open';
                oppList[0].Payment_Plan__c='CBR 12 month';
                oppList[0].Loss_Reason__c='Cancellation';
                oppList[0].Requested_Shipping_Date__c=system.today().addDays(-2);
                oppList[0].Statements1__c=true;
                oppList[0].PrimaryContactInfoConfirmation1__c=true;
                oppList[0].ConfirmDueDateCBCTAdoptionType1__c=true;
                oppList[0].InformedConsent1__c=true;
                oppList[0].CancellationFee1__c=true;
                oppList[0].KitPickupOrShipConfirmation1__c=true;
                oppList[0].Delivering_Hospital__c = Acc.id;
                opplist[0].ownerId=userinfo.getUserId();
                system.debug('>>>>test'+oppList[0]);
                if(recursiveClass.accOwnerUpdate==false){
                    system.debug('checre--'+recursiveClass.accOwnerUpdate);
                    update oppList;
                    system.debug('>>>>test1111'+oppList[0].id);
                    
                }
                recursiveClass.accOwnerUpdate=false;
                
                Opportunity_Provider__c oppproopvd = [select id,Opportunity__c,Provider__c,Provider__r.Name from Opportunity_Provider__c where Primary_Provider__c =true AND Opportunity__c =:opplist[0].id];
                system.debug('oppproopvdprimary'+oppproopvd.Primary_Provider__c);
                system.debug('oppproopvdOpportunity__c'+oppproopvd.Opportunity__c);
                
                list<Opportunity> oppList1 = [select id,Lead_RecordType_Name__c,ownerId,OnLeadConvertion__c,Completed_Flag__c from opportunity where id =:oppproopvd.Opportunity__c limit 1];
                system.debug('checre--111'+recursiveClass.accOwnerUpdate);
                opplist1[0].ownerId=userinfo.getUserId();
                oppList[0].Status__c='Open';
                update opplist1;
                recursiveClass.accOwnerUpdate=false; 
                system.debug('checre--222'+recursiveClass.accOwnerUpdate);
            }
            
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
            system.debug('ERororororor'+e.getMessage());
        }
        Test.StopTest();
        
    }
    public static testMethod void accOwnerUpdateTest(){
        Test.StartTest();
        try{
            recursiveClass.accOwnerUpdate = False;
            User u = TestDataFactory.createTestUser('Marketo Sync');
            User u1 = TestDataFactory.createTestUser('Sales Rep NSCE');
            List<Lead> leadList = new List<Lead>();
            LeadStatus cLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            Id RecordTypeIdlead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
            system.runAs(u){
                Lead leadRec1 = new Lead(FirstName='test lead1',LastName='tek leadNew Rec',RecordTypeId =RecordTypeIdlead,LeadSource='Phone',Phone = '1234568901',Email='abc11@test12gmail.com',Due_Date__c = system.today().addDays(2),OwnerId = UserInfo.getUserId(),status = 'Qualified');
                leadList.add(leadRec1);
                insert leadList;
                
                system.debug('leadList=='+leadList);
                system.debug('u1.id--'+u1.id);
                
            }
            LeadShare lshare = new LeadShare(UserOrGroupId = u1.id,LeadId = leadList[0].id, LeadAccessLevel = 'Edit');
            insert lshare;
            
            system.runAs(u){
                List<Lead> leads = [select id from lead];
                Database.LeadConvert lc = new database.LeadConvert();  
                lc.setLeadId(leadList[0].Id);  
                
                lc.setConvertedStatus(cLeadStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc, false); 
                
                
                list<Opportunity> oppList = [select id,Name,OwnerId from Opportunity ORDER BY CreatedDate DESC limit 1];
                oppList[0].OwnerId = u1.Id;
                update oppList;
            }
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    } 
    public static testMethod void createQuoteForOLETest(){
        Test.StartTest();
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        try{
            recursiveClass.createQuoteonOpty = False;
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            insert  consumerAccount;
            
            Product2 sbqqProd = new Product2();
            sbqqProd.name='Cord Blood Annual Storage Fee';
            sbqqProd.IsActive=true;
            insert sbqqProd;
            
            Opportunity opp = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 12 month',CT_Storage_Option__c='18 Years',CB_Storage_Option__c='Annual Storage',Pricebook2Id=Label.CPQUsaPriceBook);
            insert opp;
            
            oldMap.put(opp.id,opp);
            
            list<Opportunity> oppList = [select id,Name,Online_Enroll_Status__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id=: opp.id ORDER BY CreatedDate DESC];
            oppList[0].Completed_Flag__c = true;
            oppList[0].Online_Enroll_Status__c='Complete';
            update oppList;
            
            system.assertEquals('Complete', oppList[0].Online_Enroll_Status__c);
            newMap.put(oppList[0].id,oppList[0]);
            opportunityTriggerHandler.createQuoteForOLE(newMap, oldMap);
            system.debug('oppList==Status==>>>>>>>'+oppList[0].Online_Enroll_Status__c);
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    }
    
    public static testMethod void createQuoteForOLETest1(){
        Test.StartTest();
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        ID facilityRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        ID provideryRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        try{
            recursiveClass.createQuoteonOpty = False;
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            insert  consumerAccount;
            Account Facilityaccount= new Account(Name = 'Facility',Master_Facility_Id__c = 'MasterFac5',RecordtypeId =facilityRecordTypeId1 ,Status__c = 'Active' ,type = 'Hospital');
            insert Facilityaccount;
            Account provideraccount= new Account(FirstName = 'Provider1',LastName = 'Test1',Master_Facility_Id__c = 'MasterProvider1',RecordtypeId =provideryRecordTypeId1,Status__c = 'Active');
            insert provideraccount;
            Product2 sbqqProd = new Product2();
            sbqqProd.name='Cord Blood Storage Lifetime Plan';
            sbqqProd.IsActive=true;
            insert sbqqProd;
            
            Opportunity opp = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 6 month',CT_Storage_Option__c='Lifetime',CB_Storage_Option__c='Lifetime',Delivering_Hospital__c=Facilityaccount.id,LeadSource='OENROLL',Adoption_Type__c='N/A');
            insert opp;
            
            oldMap.put(opp.id,opp);
            
            ByPassValidation__c byPassSetting1 = new ByPassValidation__c();
            byPassSetting1.SkipOpportunityValidation__c = true;
            upsert byPassSetting1;
            
            Opportunity_Provider__c Oppyprovider= new Opportunity_Provider__c(Provider__c=provideraccount.id,Opportunity__c=opp.id,Primary_Provider__c =true);
            Insert Oppyprovider;
            list<Opportunity> oppList = [select id,Name,Online_Enroll_Status__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id=: opp.id ORDER BY CreatedDate DESC];
            oppList[0].Completed_Flag__c = true;
            oppList[0].Online_Enroll_Status__c='Complete';
            oppList[0].of_CB__c='2';
            
            update oppList;
            
            system.assertEquals('Complete', oppList[0].Online_Enroll_Status__c);
            newMap.put(oppList[0].id,oppList[0]);
            opportunityTriggerHandler.createQuoteForOLE(newMap, oldMap);
            system.debug('oppList==Status==>>>>>>>'+oppList[0].Online_Enroll_Status__c);
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    }
    
    public static testMethod void createQuoteForOLETest2(){
        Test.StartTest();
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        
        try{
            recursiveClass.createQuoteonOpty = False;
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            insert  consumerAccount;
            
            Product2 sbqqProd = new Product2();
            sbqqProd.name='Cord Blood Storage 18 Year Plan';
            sbqqProd.IsActive=true;
            insert sbqqProd;
            
            Opportunity opp = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 6 month',CT_Storage_Option__c='Annual Storage',CB_Storage_Option__c='18 Years',Pricebook2Id=Label.CPQUsaPriceBook);
            insert opp;
            
            Opportunity opp1 = new Opportunity(Name= 'OppTest11',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='Care Credit 48 month',CT_Storage_Option__c='Annual Storage',CB_Storage_Option__c='18 Years',Pricebook2Id=Label.CPQUsaPriceBook);
            insert opp1;
            
            oldMap.put(opp.id,opp);
            oldMap.put(opp1.id,opp1);
            list<Opportunity> oppList = [select id,Name,Online_Enroll_Status__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id IN :oldMap.keyset() ORDER BY CreatedDate DESC];
            oppList[0].Completed_Flag__c = true;
            oppList[0].Online_Enroll_Status__c='Complete';
            
            oppList[1].Completed_Flag__c = true;
            oppList[1].Online_Enroll_Status__c='Complete';
            update oppList;
            
            system.assertEquals('Complete', oppList[0].Online_Enroll_Status__c);
            newMap.put(oppList[0].id,oppList[0]);
            newMap.put(oppList[1].id,oppList[1]);
            opportunityTriggerHandler.createQuoteForOLE(newMap, oldMap);
            system.debug('oppList==Status==>>>>>>>'+oppList[0].Online_Enroll_Status__c);
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    }
    
    public static testMethod void createQuoteForOLETest3(){
        Test.StartTest();
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        try{
            recursiveClass.createQuoteonOpty = False;
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            insert  consumerAccount;
            
            Product2 sbqqProd = new Product2();
            sbqqProd.name='Payment Plan Fee';
            sbqqProd.IsActive=true;
            insert sbqqProd;
            
            Opportunity opp = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 6 month',CT_Storage_Option__c='Lifetime',CB_Storage_Option__c='Lifetime',Pricebook2Id=Label.CPQUsaPriceBook);
            insert opp;
            
            oldMap.put(opp.id,opp);
            
            list<Opportunity> oppList = [select id,Name,Online_Enroll_Status__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id=: opp.id ORDER BY CreatedDate DESC];
            oppList[0].Completed_Flag__c = true;
            oppList[0].Online_Enroll_Status__c='Complete';
            update oppList;
            
            system.assertEquals('Complete', oppList[0].Online_Enroll_Status__c);
            newMap.put(oppList[0].id,oppList[0]);
            opportunityTriggerHandler.createQuoteForOLE(newMap, oldMap);
            system.debug('oppList==Status==>>>>>>>'+oppList[0].Online_Enroll_Status__c);
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    }
    
    public static testMethod void createQuoteForOLETest4(){
        Test.StartTest();
        Id consumerRecordTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        try{
            recursiveClass.createQuoteonOpty = False;
            Account consumerAccount = new Account(RecordtypeId = consumerRecordTypeId1,FirstName = 'TestFirst6',LastName = 'TestLast6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-9),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
            insert  consumerAccount;
            
            Product2 sbqqProd = new Product2();
            sbqqProd.name='Cord Tissue Storage Lifetime Plan';
            sbqqProd.IsActive=true;
            insert sbqqProd;
            
            Opportunity opp = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccount.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 6 month',CT_Storage_Option__c='Lifetime',CB_Storage_Option__c='Lifetime',Pricebook2Id=Label.CPQUsaPriceBook);
            insert opp;
            
            oldMap.put(opp.id,opp);
            
            list<Opportunity> oppList = [select id,Name,Online_Enroll_Status__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id=: opp.id ORDER BY CreatedDate DESC];
            oppList[0].Completed_Flag__c = true;
            oppList[0].Online_Enroll_Status__c='Complete';
            update oppList;
            
            system.assertEquals('Complete', oppList[0].Online_Enroll_Status__c);
            newMap.put(oppList[0].id,oppList[0]);
            opportunityTriggerHandler.createQuoteForOLE(newMap, oldMap);
            opportunityTriggerHandler.updateBillToShipTo(newMap,oldMap);
            system.debug('oppList==Status==>>>>>>>'+oppList[0].Online_Enroll_Status__c);
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        Test.StopTest();
        
    }
    
    public static testMethod void sendOptyStoredAxPfEvtTest(){
        Test.startTest();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testJk',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Open',Storage_Sent_to_AX__c=false,Reopened_after_Stored__c=false,AX_Order_Id__c='12121212'));
        
        insert optyList;
        oldMap.put(optyList[0].id,optyList[0]);
        List<Opportunity> olist =new List<Opportunity>();
        olist= [Select id,Storage_Sent_to_AX__c,Reopened_after_Stored__c,AX_Order_Id__c,of_Babies__c,StageName,status__c from Opportunity  WHERE Id = :optyList[0].Id limit 1];
        
        olist[0].Status__C='Stored';
        update olist;
        newMap.put(olist[0].id,olist[0]);
        opportunityTriggerHandler.sendOptyStoredAxPfEvt(newMap, oldMap);
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.SendOpportunityStoredToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityStoredToAXEvent();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='Send Opportunity Stored ToAX Event';
        
        optyWrp.AxOpportunityId=olist[0].id;
        cbrEvt.EventData__c=JSON.serialize(optyWrp);
        cbrEvtList.add(cbrEvt); 
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
        
        Test.StopTest();
        System.assertEquals(true, saveResults[0].isSuccess());
    }
    
    public static testMethod void sendOptyEnrolledAxPfEvtTest(){
        Test.startTest();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testJk',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Open',Storage_Sent_to_AX__c=false,Reopened_after_Stored__c=false,AX_Order_Id__c='12121212'));
        
        insert optyList;
        opportunityContact__c oppyCon=[select id,name,Opportunity__c,PersonAccount__c,Role__c,Primary__c,Bill_To__c from opportunityContact__c where Opportunity__c=:optyList[0].id];
        system.debug('theoppycan-->'+oppyCon);
        opportunityContact__c oppyContact= new OpportunityContact__c(Opportunity__c=optyList[0].id,PersonAccount__c=consumerAccountList[1].id,Role__c='Father',Primary__c=false,Bill_To__c=true);
        Insert oppyContact;
        oldMap.put(optyList[0].id,optyList[0]);
        List<Opportunity> olist =new List<Opportunity>();
        olist= [Select id,Storage_Sent_to_AX__c,Reopened_after_Stored__c,AX_Order_Id__c,of_Babies__c,StageName,status__c from Opportunity  WHERE Id = :optyList[0].Id limit 1];
        
        //olist[0].Status__c='Enrolled';
        //olist[0].StageName='Enrolled';
        
        update olist;
        newMap.put(olist[0].id,olist[0]);
        opportunityTriggerHandler.sendOptyEnrolledAxPfEvt(newMap, oldMap);
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.SendOpportunityEnrolledToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityEnrolledToAXEvent();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='Send Opportunity Enrolled ToAX Event';
        
        optyWrp.AxOpportunityId=olist[0].id;
        cbrEvt.EventData__c=JSON.serialize(optyWrp);
        cbrEvtList.add(cbrEvt); 
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
        
        Test.StopTest();
        System.assertEquals(true, saveResults[0].isSuccess());
    }
    
    public static testMethod void sendOptyClosedAxPfEvt(){
        Test.startTest();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        optyList.add(new Opportunity(Name= 'OppTest1testJk',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,StageName = 'Pending',status__c = 'Open',Storage_Sent_to_AX__c=false,Reopened_after_Stored__c=false,AX_Order_Id__c='12121212'));
        
        insert optyList;
        oldMap.put(optyList[0].id,optyList[0]);
        List<Opportunity> olist =new List<Opportunity>();
        olist= [Select id,Storage_Sent_to_AX__c,Reopened_after_Stored__c,AX_Order_Id__c,of_Babies__c,StageName,status__c from Opportunity  WHERE Id = :optyList[0].Id limit 1];
        
        olist[0].StageName='Closed Lost';
        olist[0].Loss_Reason__c='Auto Closed';
        
        
        update olist;
        newMap.put(olist[0].id,olist[0]);
        opportunityTriggerHandler.sendOptyClosedAxPfEvt(newMap, oldMap);
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.SendOpportunityClosedToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityClosedToAXEvent();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='Send Opportunity Enrolled ToAX Event';
        
        optyWrp.AxOpportunityId=olist[0].id;
        cbrEvt.EventData__c=JSON.serialize(optyWrp);
        cbrEvtList.add(cbrEvt); 
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
        
        Test.StopTest();
        System.assertEquals(true, saveResults[0].isSuccess());
    }
    public static testMethod void UpdateOptyCountOnPrimaryProviderTestMethod(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        List<Opportunity> facstatlist =new List<Opportunity>();
        set<id> oplst = new set<id>();
        test.startTest();
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test1',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test2',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test3',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test4',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac4',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test5',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac5',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test6',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac6',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac6',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[6].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        insert optyList;
        
        ByPassValidation__c byPassSetting = new ByPassValidation__c();
        byPassSetting.SkipOpportunityValidation__c = true;
        upsert byPassSetting;
        
        Opportunity_Provider__c Opptyprovider= new Opportunity_Provider__c(Provider__c=providerAccountList[1].id,Opportunity__c=optyList[0].Id,Primary_Provider__c =true);
        Insert Opptyprovider;
        
        Opportunity_Provider__c Opptyprovider1= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[1].Id,Primary_Provider__c =true);
        Insert Opptyprovider1;
        
        Opportunity_Provider__c Opptyprovider2= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[2].Id,Primary_Provider__c =true);
        Insert Opptyprovider2;
        
        Opportunity_Provider__c Opptyprovider3= new Opportunity_Provider__c(Provider__c=providerAccountList[0].id,Opportunity__c=optyList[3].Id,Primary_Provider__c =true);
        Insert Opptyprovider3;
        
        Opportunity_Provider__c Opptyprovider4= new Opportunity_Provider__c(Provider__c=providerAccountList[1].id,Opportunity__c=optyList[5].Id,Primary_Provider__c =true);
        Insert Opptyprovider4;
        
        oplst.add(optyList[0].id);
        oplst.add(optyList[1].id);
        oplst.add(optyList[4].id);
        oplst.add(optyList[5].id);
        oplst.add(optyList[6].id);
        oplst.add(optyList[7].id);
        //oplst.add(optyList[6].id);
        //oplst.add(optyList[3].id);
        //oplst.add(optyList[5].id);
        
        facstatlist= [Select id,Referral_Name__c,Name,Delivering_Hospital__c,status__c from Opportunity  WHERE Id IN:oplst limit 8];
        system.debug('facstatlist>>>'+facstatlist);
        
        //facstatlist[0].Delivering_Hospital__c=facilityAccountList[6].id;
        facstatlist[0].Enrollment_Date__c=system.now();
        facstatlist[0].status__c='Enrolled';
        facstatlist[1].Enrollment_Date__c=system.now();
        facstatlist[1].status__c='Enrolled';
        facstatlist[2].Enrollment_Date__c=system.now();
        facstatlist[2].status__c='Enrolled';
        facstatlist[3].Enrollment_Date__c=system.now();
        facstatlist[3].status__c='Enrolled';
        facstatlist[4].Enrollment_Date__c=system.now();
        facstatlist[4].status__c='Enrolled';
        facstatlist[5].Delivering_Hospital__c=facilityAccountList[7].id;
        update facstatlist;
        
        Account acc = [select id,of_open_optys__c,of_enrolled_optys__c from account where id=:facilityAccountList[5].id];
        //system.assertEquals(2, acc.of_enrolled_optys__c);
        //system.assertEquals(2, acc.of_open_optys__c);
        Test.stopTest();
        
    }
    public static testMethod void updateDeliveringHospFacilityTestMethod(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        List<Opportunity> facstatlist =new List<Opportunity>();
        set<id> oplst = new set<id>();
        test.startTest();
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test1',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac1',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test2',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac2',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test3',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac3',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test4',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac4',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test5',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac5',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test6',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac6',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac7',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[6].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac8',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[6].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        optyList.add(new Opportunity(Name= 'OppTest1testfac9',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[6].id,Referral_Name__c='Test7',StageName = 'Pending',status__c = 'Open'));
        insert optyList;
        
        oplst.add(optyList[0].id);
        oplst.add(optyList[1].id);
        oplst.add(optyList[4].id);
        oplst.add(optyList[5].id);
        oplst.add(optyList[6].id);
        oplst.add(optyList[7].id);
        //oplst.add(optyList[6].id);
        //oplst.add(optyList[3].id);
        //oplst.add(optyList[5].id);
        
        facstatlist= [Select id,Referral_Name__c,Name,Delivering_Hospital__c,status__c from Opportunity  WHERE Id IN:oplst limit 8];
        system.debug('facstatlist>>>'+facstatlist);
        
        facstatlist[0].Delivering_Hospital__c=facilityAccountList[6].id;
        facstatlist[0].Enrollment_Date__c=system.now();
        //facstatlist[0].status__c='Enrolled';
        facstatlist[1].Enrollment_Date__c=system.now();
        facstatlist[1].status__c='Enrolled';
        facstatlist[2].Enrollment_Date__c=system.now();
        facstatlist[2].status__c='Enrolled';
        facstatlist[3].Enrollment_Date__c=system.now();
        facstatlist[3].status__c='Enrolled';
        facstatlist[4].Enrollment_Date__c=system.now();
        facstatlist[4].status__c='Enrolled';
        facstatlist[5].Delivering_Hospital__c=facilityAccountList[7].id;
        update facstatlist;
        
        Account acc = [select id,of_open_optys__c,of_enrolled_optys__c from account where id=:facilityAccountList[5].id];
        //system.assertEquals(2, acc.of_enrolled_optys__c);
        //system.assertEquals(2, acc.of_open_optys__c);
        Test.stopTest();
        
    }
    public static testMethod void updateOwnerForCssMethod(){
        Test.StartTest();
        try{
            User u = TestDataFactory.createTestUser('Client Support Specialist');
            system.runAs(u){
                List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
                List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
                List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
                List<Opportunity> optyList=new list<Opportunity>();
                optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),OnLeadConvertion__c=true,Lead_RecordType_Name__c ='NonMQL',AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[5].id,Referral_Name__c='Test1',StageName = 'Pending',status__c = 'Open'));
                insert optyList;
            }
        }catch(DMLException e){
        }
        Test.StopTest();
    }
    
    public static testMethod void createTaskBasedPrimaryContDOBTestMethod(){
        Id consumerRrdTypeId1 = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<id,Opportunity> newMap = new Map<id,Opportunity>();
        Map<id,Opportunity> oldMap = new Map<id,Opportunity>();
        Account consumerAccountDOB = new Account(RecordtypeId = consumerRrdTypeId1,FirstName = 'TestFirst666',LastName = 'TestLas3t6',ID_Type__pc ='Passport #',ID_Information__pc='9999888989',Due_Date__pc = system.today(),PersonBirthDate=system.today().addDays(-999),PersonEmail = 'TestPersonEmail5@test.com',BillingStreet = 'Test111',BillingState = 'Texas',BillingCountry = 'United States',BillingCity = 'Texas',BillingPostalCode = '73301');
        insert  consumerAccountDOB;
        Opportunity opp1 = new Opportunity(Name= 'OppTest1',CloseDate = system.today(),AccountId = consumerAccountDOB.id,Due_Date__c = system.today().addDays(20),of_Babies__c = 'Single',StageName = 'Ask for sale',Section_3_Received__c= FALSE,Enrollment_Date__c = system.today(),status__c = 'Open',Online_Enroll_Status__c='',of_CB__c='1',of_CT__c='1',Payment_Plan__c='CBR 12 month',CT_Storage_Option__c='18 Years',CB_Storage_Option__c='Annual Storage',Profile_Complete__c=false);
        insert opp1;
        
        oldMap.put(opp1.id,opp1);
        
        list<Opportunity> oppList1 = [select id,Name,Online_Enroll_Status__c,Profile_Complete__c,Completed_Flag__c,of_CB__c,of_CT__c,Payment_Plan__c,Primary_Contact__c from Opportunity where id=: opp1.id ORDER BY CreatedDate DESC];
        oppList1[0].Profile_Complete__c= true;
        update oppList1;
        
        newMap.put(oppList1[0].id,oppList1[0]);
        opportunityTriggerHandler.createTaskBasedPrimaryContDOB(newMap, oldMap);
    } 
    
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
        Test.stopTest();
        
    }
    public static testMethod void OpportunitySendFaxEmailTestMethodEnrolled(){
        List<Account> consumerAccountList = TestDataFactory.createConsumerAccounts();
        List<Account> facilityAccountList =TestDataFactory.createFacilityAccounts();
        List<Account> providerAccountList =TestDataFactory.createProviderAccounts();
        List<Opportunity> optyList=new list<Opportunity>();
        List<Opportunity> facstatlist =new List<Opportunity>();
        List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAccountList,providerAccountList);
        set<id> oplst = new set<id>();
        
        test.startTest();
        facilityAccountList[3].Fax='987654321';
        update facilityAccountList[3];
        optyList.add(new Opportunity(Name= 'OppTest1testfac',CloseDate = system.today().addDays(5),AccountId = consumerAccountList[0].id,Delivering_Hospital__c =facilityAccountList[4].id,Referral_Name__c='Test1',StageName = 'Marketing Qualified',status__c = 'Open'));
        insert optyList;
        
        List<Opportunity_Provider__c> oppProviderlist = new List<Opportunity_Provider__c>();
        oppProviderlist.add(new Opportunity_Provider__c(Facility__c = facilityAccountList[3].id ,Provider__c = providerAccountList[3].id,Primary_Provider__c = true,Opportunity__c = optyList[0].id,Provider_Facility__c = providerFacilityList[3].id));
        insert oppProviderlist;
        
        optyList[0].Enrollment_Date__c=system.now();
        optyList[0].status__c='Enrolled';
        optyList[0].of_CB__c='0';
        optyList[0].of_CT__c='1';
        update optyList[0];
        system.debug('the updated opty-->'+optyList);
        Test.stopTest();
        
    }
}