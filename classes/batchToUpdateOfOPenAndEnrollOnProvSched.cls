/*******************************************************************************************************************************************
*Component Name: batchToUpdateOfOPenAndEnrollOnProvSched
*Description: Test class for batchToUpdateOfOPenAndEnrollOnProviders.
*Created By: TEKsystems
*Created Date: 
************************************************************************************************************************************************/
global class batchToUpdateOfOPenAndEnrollOnProvSched implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateOfOPenAndEnrollOnProviders b = new batchToUpdateOfOPenAndEnrollOnProviders(); 
      database.executebatch(b);
   }
}