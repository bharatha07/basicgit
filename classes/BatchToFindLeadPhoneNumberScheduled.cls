global class BatchToFindLeadPhoneNumberScheduled implements Schedulable {
    global void execute(SchedulableContext sc){
        BatchToFindLeadPhoneNumber Leadbatchable = new BatchToFindLeadPhoneNumber();
        database.executeBatch(Leadbatchable,50);
    }
    
}