/*******************************************************************************************************************************************
*Component Name: batchToUpdateCBCTOnProviders_Test
*Description: Test class for batchToUpdateCBCTOnDeliveringProviders.
*Created By: TEKsystems(Tejaswini)
*Created Date: 
************************************************************************************************************************************************/
global class batchToUpdateCBCTOnProvidersScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateCBCTOnDeliveringProviders b = new batchToUpdateCBCTOnDeliveringProviders(); 
      database.executebatch(b);
   }
}