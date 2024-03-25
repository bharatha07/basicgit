@isTest
public class ConsumerTimezoneUpdateBatch_Test{
    @isTest
    public static void unitTest1(){
        TestDataFactory.CustomSettingRecords();
        List<Account> ConsumerAccounts = TestDataFactory.createConsumerAccounts();
        Test.StartTest();
        ConsumerTimezoneUpdateBatch batchEx = new ConsumerTimezoneUpdateBatch();
        Database.executeBatch(batchEx);
        Test.StopTest();
    }
}