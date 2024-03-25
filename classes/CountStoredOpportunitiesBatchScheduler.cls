/*
Name : CountStoredOpportunitiesBatchScheduler  
Description : 1003 - Scheduler for CountStoredOpportunitiesBatch 
Created By: Nitish Bansal (TEK)
Created Date: 06/03/2019
*/
global class CountStoredOpportunitiesBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
       
      CountStoredOpportunitiesBatch storedOppCount = new CountStoredOpportunitiesBatch (false); 
      database.executebatch(storedOppCount);
   }
}