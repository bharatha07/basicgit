/***********************************************************************************************************************
*Component Name: CaseCreateCusBtnControllerTest 
*Description: Test Class to check new case button on opportunity.
*Developed By: Tek Systems
************************************************************************************************************************/
@isTest
public class CaseCreateCusBtnControllerTest {
    @isTest public static void createBtnTest(){
       Map<String,String> valueToLabel = new Map<String,String>();
      String sObjectName='Case';
      Test.startTest();
      valueToLabel=  CaseCreateCusBtnController.getCaseRecordType(sObjectName);
      Test.stopTest();
      System.assertNotEquals(valueToLabel.size(),0);
    }
}