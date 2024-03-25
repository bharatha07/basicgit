global class scheduleBatchToCreateCampaignMember  implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchToAssignLeadsToCampaign campaignbatch =new BatchToAssignLeadsToCampaign();
        database.executebatch(campaignbatch);
    }    
}