global class BatchToCreateTaskForUnexceptedCTSched implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToCreateTaskForUnexceptedCT b = new BatchToCreateTaskForUnexceptedCT(); 
      database.executebatch(b);
   }
}