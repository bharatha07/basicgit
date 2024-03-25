/*
Name : CountStoredOpportunitiesBatchTest 
Description : 1003 - Test class for CountStoredOpportunitiesBatch and it's scheduler
Created By: Nitish Bansal (TEK)
Created Date: 06/03/2019
*/
@isTest
public class CountStoredOpportunitiesBatchTest {

    @testSetup static void CreateData(){
        List<Account> facilityAccList = TestDataFactory.createFacilityAccounts();
        List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
        List<Account> providerAccList = TestDataFactory.createProviderAccounts();
        List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAccList,providerAccList);

        Account deliveringHospital = new Account();
        for(Account acc:facilityAccList){
            if(acc.Type == 'Hospital'){
                deliveringHospital = acc;
            }
        }
        providerAccList[2].Stored_opportunities__c = 1;
        update providerAccList;
        
        Contact con = new Contact();
        con.FirstName = 'Paul';
        con.LastName  = 'Test';
        con.AccountId = facilityAccList[0].id;
        con.MailingStreet = '298 S. Ringo Street';
        con.MailingCity = 'San Bruno';
        //con.MailingState = 'AR';
        con.MailingPostalCode = '94066';
        con.MailingCountry = 'United States';
        con.MQL_Score__c = 1224;
        insert con;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name='Sample test'; 
        opp1.AccountId = consumerAccList[0].id;
        opp1.Status__c = 'Stored';
        opp1.LeadSource = 'Internet';
        opp1.Primary_Contact__c = con.id;
        opp1.Enrollment_Date__c = NULL;
        opp1.Storage_Date__c = Null;
        opp1.StageName = 'Stored';
        opp1.Due_Date__c = system.today().addDays(21);
        opp1.Primary_Source__c='I\'m a Current Client';
        opp1.CloseDate = system.today().addDays(45);
        opp1.of_Babies__c = 'Single';
        opp1.Loss_Reason__c = 'Cancellation';
        //opp1.PickUp_or_Ship_Kit__c='Ship';
        opp1.Ship_To_Name__c ='test user';
        opp1.Ship_To_Street1__c='test Address';
        opp1.Requested_Shipping_Date__c  = system.today().addDays(1);
        opp1.Shipping_Method__c = 'Priority Overnight';
        opp1.Adoption_Type__c = 'N/A';
        opp1.Ship_To_Phone__c = '1234512345';
        opp1.Payment_Method__c = 'Credit Card';
        opp1.Care_Credit_Account__c = '1234567891234567';
        opp1.of_CB__c='1';
        opp1.of_CT__c='0';
        insert opp1;
        
        List<Opportunity_Provider__c> oppProviderlist = new List<Opportunity_Provider__c>();
        oppProviderlist.add(new Opportunity_Provider__c(Facility__c = facilityAccList[0].id ,Provider__c = providerAccList[0].id,Primary_Provider__c = false,Delivering_Provider__c = false,Opportunity__c = opp1.Id,Provider_Facility__c = providerFacilityList[0].id));
        oppProviderlist.add(new Opportunity_Provider__c(Facility__c = facilityAccList[1].id ,Provider__c = providerAccList[1].id,Primary_Provider__c = true,Delivering_Provider__c = true,Opportunity__c = opp1.Id,Provider_Facility__c = providerFacilityList[1].id));
        insert oppProviderlist;
        
        
    }
    
    public static testmethod void TestBatchMethod(){
        Test.startTest();
          CountStoredOpportunitiesBatch storedOppCount = new CountStoredOpportunitiesBatch (true); 
          database.executebatch(storedOppCount);
        Test.stopTest();
    }
    
    public static testmethod void TestSchedulerMethod(){
        String CRON_EXP = '0 0 0 15 3 ? *';
 
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new CountStoredOpportunitiesBatchScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}