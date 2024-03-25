global class BatchToCreateTaskForCollectDeviceSched implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToCreateTaskForCollectionDevice b = new BatchToCreateTaskForCollectionDevice(); 
      database.executebatch(b);
   }
}