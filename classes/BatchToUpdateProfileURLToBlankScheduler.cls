global class BatchToUpdateProfileURLToBlankScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToUpdateProfileURLToBlank batchable = new BatchToUpdateProfileURLToBlank();
        database.executeBatch(batchable);
   }
}