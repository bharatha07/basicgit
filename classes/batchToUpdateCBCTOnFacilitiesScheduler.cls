/*******************************************************************************************************************************************
*Component Name: batchToUpdateCBCTOnFacilitiesScheduler
*Description: Test class for batchToUpdateCBCTOnDeliveringFacilities.
*Created By: TEKsystems(Tejaswini)
*Created Date: 
************************************************************************************************************************************************/
global class batchToUpdateCBCTOnFacilitiesScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateCBCTOnDeliveringFacilities b = new batchToUpdateCBCTOnDeliveringFacilities(); 
      database.executebatch(b);
   }
}