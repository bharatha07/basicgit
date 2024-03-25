public class invokePayableStatusUpdateBatch {
    @AuraEnabled
    public static Id executeBatchJob(){
        Id batchJobId = Database.executeBatch(new updatepayableStatusButton_Batch(), 200);// updatepayableStatus_Batch
        return batchJobId;
    }

}