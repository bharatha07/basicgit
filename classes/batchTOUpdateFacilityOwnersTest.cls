/*******************************************************************************************************************************************
* Component Name:batchToUpdate Facility OwnerId
* Description: Test Batch classs to update OwnerIds of the facilities.
* Created By: Rajakumar Anbarasan
* Created Date: 12-8-2021
* User Story: SFDC - 2123
************************************************************************************************************************************************/
@isTest
public class batchTOUpdateFacilityOwnersTest {
    
    @isTest static void batchTOUpdateFacilityOwnersTestMethod(){
        
        User u = TestDataFactory.createTestUser('System Administrator');
        u.Territory__c='Testzip13';
        update u;
        
        US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
        
        List<Account> facilityAccountList = TestDataFactory.createFacilityAccounts();
        facilityAccountList[0].Kit_Location__c='Test';
        facilityAccountList[0].BillingPostalCode='10009';
        update facilityAccountList[0];
        
        Test.startTest();
        batchTOUpdateFacilityOwnersScheduler oppbatch = new batchTOUpdateFacilityOwnersScheduler();
        oppbatch.execute(null);
        Test.stopTest();
    }
    
}