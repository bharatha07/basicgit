public class BatchToCreateCheckRecordsScheduled implements Schedulable {
    public void execute(SchedulableContext sc){
        BatchToCreateCheckRecords checkBatchable = new BatchToCreateCheckRecords();
        database.executeBatch(checkBatchable);
    }
    
}