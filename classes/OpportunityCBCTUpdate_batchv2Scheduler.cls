/*******************************************************************************************************************************************
*Component Name: OpportunityCBCTUpdate_batchv2Scheduler
*Description: schedular class for OpportunityCBCTUpdate_batchv2.
*Created By: TEKsystems()
*Created Date: 
************************************************************************************************************************************************/
global class OpportunityCBCTUpdate_batchv2Scheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
OpportunityCBCTUpdate_batchv2 b = new OpportunityCBCTUpdate_batchv2(); 
      database.executebatch(b);
   }
}