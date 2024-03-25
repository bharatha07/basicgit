/**
* @File Name          : casetriggerhelperTest.cls
* @Description        : 
* @Last Modified On   : 09/08/2021
**/
@isTest
public class casetriggerhelperTest {

    public static testMethod void sendClosedIDMCaseTestMethod(){
        Id testResultId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Test Results').getRecordTypeId();
        Test.startTest();
        Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email',RecordTypeId=testResultId,type='IDM - Test Results Letter'); 
        insert cas;
        
        cas.Case_Close_Confirmation__c=true;
        cas.Status='Closed';
        update cas;
        test.stopTest();
    }
public static testMethod void stopDeletingCaseTestMethod(){
        Id clientIssuId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Client Issues').getRecordTypeId();
        Test.startTest();
        Case cas1 = new Case(Status ='New', Priority = 'Medium', Origin = 'Email',RecordTypeId=clientIssuId,type='Follow Up',Reason='Existing problem'); 
        insert cas1;
        
        try{
            delete cas1;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('Case cannot be deleted'),'Case cannot be deleted');                       
        }
        test.stopTest();
    }
}