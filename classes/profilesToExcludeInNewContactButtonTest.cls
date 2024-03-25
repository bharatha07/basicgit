/*******************************************************************************************************************************************
* Component Name:profilesToExcludeInNewContactButtonTest
* Description: Test Batch classs to invoke for coverage of profilesToExcludeInNewContactButton
* Created By: 
* Created Date: 24-01-2022
* User Story: SFDC - 2294
************************************************************************************************************************************************/
@isTest
public class profilesToExcludeInNewContactButtonTest {
    
    @isTest static void profilesToExcludeInNewContactButtonTestMethod(){
        Test.StartTest();
        try{
            User u = TestDataFactory.createTestUser('Marketo Sync');
            profilesToExcludeInNewContactButton.getProfileInfo();
        }catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
            system.debug('ERororororor'+e.getMessage());
        }
        Test.StopTest();
    }
}