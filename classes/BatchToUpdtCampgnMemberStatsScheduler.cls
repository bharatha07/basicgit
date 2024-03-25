global class BatchToUpdtCampgnMemberStatsScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchToUpdateCampaignMemberStatus b = new BatchToUpdateCampaignMemberStatus(); 
      database.executebatch(b);
   }
}