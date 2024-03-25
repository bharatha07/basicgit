@isTest
public class AddCreditCardControllerTest {
    @isTest
    public static void unitTest(){
    Test.StartTest();
        Account acc = new Account();
        Id consumerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        acc.RecordtypeId = consumerRecordTypeId;
        acc.FirstName = 'TestFN';
        acc.LastName = 'TestLN';
        acc.Due_Date__pc = system.today();
        acc.PersonBirthDate = system.today().addDays(-2);
        
        
        insert acc;
        
        AddCreditCardController creditObj = New AddCreditCardController();
        Account accRecord = AddCreditCardController.getAccountDetail(acc.Id);
        system.assertNotEquals(accRecord,null);
    Test.StopTest();
    }

}