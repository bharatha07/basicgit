/******************************************************************************************************************************
*Component Name: SendLastModifiedRecordReportTest
*Created Date : 07-DEC-2020
* @story - SFDC-1342
*Description : Test Class for SendLastModifiedRecordReport.
*Created By : 
*******************************************************************************************************************************/
@isTest
public class SendLastModifiedRecordReportTest {
    @isTest
    static void reportForSobjectsTest(){
        
        List_Of_Objects__c objList = new List_Of_Objects__c();
        objList.Objects__c='Account';
        objList.Name='Object List';
        insert objList;
               
        User_Email_Details__c useremail = new User_Email_Details__c();
        useremail.Emails__c='test@abc.com';
        useremail.Name='Email Address';
        insert useremail;
        
        test.startTest();
        SendLastModifiedRecordReport sched = new SendLastModifiedRecordReport();
        sched.execute(null);
        test.stopTest();
    }
}