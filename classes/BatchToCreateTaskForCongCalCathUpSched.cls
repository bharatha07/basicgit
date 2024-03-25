global class BatchToCreateTaskForCongCalCathUpSched implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToCreateTaskForCongratsCalCathUp b = new BatchToCreateTaskForCongratsCalCathUp(); 
      database.executebatch(b);
   }
}