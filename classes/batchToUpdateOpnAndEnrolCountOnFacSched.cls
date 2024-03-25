/*******************************************************************************************************************************************
*Component Name: batchToUpdateOpnAndEnrolCountOnFacSched
*Description: Test class for batchToUpdateOpnAndEnrolCountOnFacility.
*Created By: TEKsystems
*Created Date: 
************************************************************************************************************************************************/
global class batchToUpdateOpnAndEnrolCountOnFacSched implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchToUpdateOpnAndEnrolCountOnFacility b = new batchToUpdateOpnAndEnrolCountOnFacility(); 
      database.executebatch(b);
   }
}