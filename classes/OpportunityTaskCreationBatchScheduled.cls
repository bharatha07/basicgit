global class OpportunityTaskCreationBatchScheduled implements Schedulable
{  
    global void execute(SchedulableContext sc)
    {
        OpportunityTaskCreationBatch oppbatch =new OpportunityTaskCreationBatch();
        database.executebatch(oppbatch);
    }
}