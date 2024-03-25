/*************************************************************************************************************************
* Component Name: leadAutoConvertOLETest
* Description: Test class for leadAutoConvertOLE
* DevelopedBy: TEKsystems
*****************************************************************************************************************************/
@isTest
public class leadAutoConvertOLETest{ 

@isTest
    public static void leadAutoConvertOLETestMethod(){
        
      List<Account> lstAcc = TestDataFactory.createConsumerAccounts();
        leadAutoConvertOLE.InputWrapper inpuWrap = new leadAutoConvertOLE.InputWrapper();
        inpuWrap.email=lstAcc[0].PersonEmail;
        system.assertEquals('TestPersonEmail1@test.com', lstAcc[0].PersonEmail);
        String body = json.serialize(inpuWrap);
        
        RestRequest req = new RestRequest();
        req.requestURI='https://cordbloodregistry--devteam1.my.salesforce.com/services/apexrest/OLESearch/';
        req.httpMethod='POST';
        req.requestBody=blob.valueOf(body);
        RestContext.request = req;
        
        Test.startTest();
        leadAutoConvertOLE.emailInforOLEdoPost();
        Test.stopTest();
    }
    
    @isTest
    public static void leadAutoConvertOLETestMethod2(){
        
      
         List<Lead> lstlead1 = new List<Lead>();
        lstlead1.add(new Lead(LastName='Test',FirstName='Lead9',Due_Date__c=system.today().adddays(2),Email='todaytest@test2311.com'));
        List<Account> aclistb=[select id ,PersonEmail from Account];
         system.debug('email before is '+aclistb);
        insert lstlead1;
        List<Account> aclist=[select id ,PersonEmail from Account];
        system.debug('email is '+aclist);
        Test.startTest();
        leadAutoConvertOLE.InputWrapper inpuWrap = new leadAutoConvertOLE.InputWrapper();
        inpuWrap.email=lstlead1[0].Email;
        inpuWrap.lastTouchCode='Touch Code';
        inpuWrap.utmSourLT='SourceLT';
        inpuWrap.utmMeduLT='MediumLT';
        inpuWrap.utmCampLT='CampLT';
        
        system.debug('email in lead is '+inpuWrap.email);
        String body1 = json.serialize(inpuWrap);
        
        RestRequest req1 = new RestRequest();
        req1.requestURI='https://cordbloodregistry--devteam1.my.salesforce.com/services/apexrest/OLESearch/';
        req1.httpMethod='POST';
        req1.requestBody=blob.valueOf(body1);
        RestContext.request = req1;
        Test.stopTest();
        leadAutoConvertOLE.emailInforOLEdoPost();
   }
}