global class batchToUpdateOppPrimarySourceScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateOppPrimarySource b = new batchToUpdateOppPrimarySource(); 
      database.executebatch(b);
   }
}