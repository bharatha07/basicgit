global class batchToUpdateOppPrimarySourceBatch2Schdr implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateOppPrimarySourceBatch2 b = new batchToUpdateOppPrimarySourceBatch2(); 
      database.executebatch(b);
   }
}