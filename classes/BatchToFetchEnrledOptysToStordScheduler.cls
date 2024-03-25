global class BatchToFetchEnrledOptysToStordScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToFetchEnrolledOptysToStored b = new BatchToFetchEnrolledOptysToStored(); 
      database.executebatch(b);
   }
}