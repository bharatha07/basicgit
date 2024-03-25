global class batchTOUpdateFacilityOwnersScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchTOUpdateFacilityOwners batchable = new batchTOUpdateFacilityOwners();
        database.executeBatch(batchable);
   }
}