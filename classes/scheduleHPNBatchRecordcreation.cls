public class scheduleHPNBatchRecordcreation {
    
    public void execute(SchedulableContext sc){
        Map<Id,CBRChecks__c> ids= new Map<Id,CBRChecks__c>();
        BatchToCreateHPNBatchRecords hPNbatch = new BatchToCreateHPNBatchRecords(ids,0);
        database.executeBatch(hPNbatch);
    }

}