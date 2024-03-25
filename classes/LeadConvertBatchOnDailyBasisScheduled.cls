global class LeadConvertBatchOnDailyBasisScheduled implements Schedulable {
    global void execute(SchedulableContext sc){
        LeadConvertBatchOnDailyBasis Leadbatchable = new LeadConvertBatchOnDailyBasis();
        database.executeBatch(Leadbatchable,5);
    }
    
}