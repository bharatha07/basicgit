@isTest
public class UtilityClassTest {
    
    public static testMethod void UtilityClassTestMethod(){
        List<Account> consumerAccs = TestDataFactory.createConsumerAccounts();
        List<Opportunity> oppList= TestDataFactory.createOpportunities(consumerAccs);
        try{
        oppList[0].StageName = 'Enrolled';
        Update oppList[0];
        }catch(exception ex){
            string errorDet = ex.getMessage()+ex.getStackTraceString();
            cbr_Error_Log__c cbr = UtilityClass.logErrors(string.valueOf(oppList[0].id), 'Stage Enroll', 'Apex', errorDet, false, true);
            cbr_Error_Log__c cbrErrorRec = [select id,cbr_Error_Detail__c from cbr_Error_Log__c where id =: cbr.id limit 1];
            system.assertEquals(cbrErrorRec.cbr_Error_Detail__c, errorDet);
        }
    }
}