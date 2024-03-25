@isTest
public class cbr_m_CustomLookupControllerTest {
    @isTest static void cbr_m_CustomLookupControllerTestMethod(){
        Test.startTest();
        List<Account> facilityAccountList = TestDataFactory.createFacilityAccounts();
        cbr_m_CustomLookupController.CustomLooup(facilityAccountList[4].Name, facilityAccountList[4].RecordtypeId);
        Test.stopTest();
    }
}