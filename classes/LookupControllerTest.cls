@isTest
public class LookupControllerTest{
    @isTest static void UnitTest1(){
    List<Account> accList = TestDataFactory.createConsumerAccounts();
    List<Account> FacilityAccList = TestDataFactory.createFacilityAccounts();
    Test.StartTest();
    List<String> searchableFields = new List<String>{'Name','PersonEmail'};
    String recordTypeName = 'Consumer';
   LookupController.fetchLookUpValues('Test','Account',null,'isPersonAccount = true',searchableFields,searchableFields,'Name DESC NULLS LAST','3',null);
     LookupController.fetchLookUpValues('','Account',FacilityAccList,'isPersonAccount = true',searchableFields,searchableFields,'Name DESC NULLS LAST','3',null);
        
    Test.Stoptest();
    
    }
}