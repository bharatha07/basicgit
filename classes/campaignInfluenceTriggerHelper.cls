/**
 * @File Name          : campaignInfluenceTriggerHelper.cls
 * @Description        : 
 * @Author             : Tejaswini
 * @user Story              : SFDC - 984
 * @Created Date   : 6/21/2020, 10:53:50 PM
 * Ver       Date            Author      		    Modification
 * 1.0    6/21/2020         Tejaswini     Initial Version
**/
public class campaignInfluenceTriggerHelper {
    public static void updateContact(List<CampaignInfluence> newCIList){
       // recursiveClass.conUpdateFromCI = true;
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Campaign> campaignsMap = new Map<Id,Campaign>();
        List<Account> accListToUpdate = new List<Account>();
        List<OpportunityContact__C> opptyContacts = new List<OpportunityContact__C>();
        Map<Id,id> OptyCampIdMap = new Map<Id,Id>();
        Map<Id,List<OpportunityContact__c>> accOptyConMap = new Map<Id,List<OpportunityContact__c>>();
		Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
		Set<id> accIds = new Set<Id>();
        for(CampaignInfluence ci:newCIList){
            OptyCampIdMap.put(ci.OpportunityId, ci.CampaignId);
        }
        System.debug('OptyCampIdMap==='+OptyCampIdMap);
        if(!OptyCampIdMap.isEmpty()){
            campaignsMap = new Map<Id,Campaign>([select id,Campaign_Code__c from campaign where Id IN:OptyCampIdMap.values()]);
			oppMap = new map<id,Opportunity>([select id,Accountid from Opportunity where status__c = 'Open' AND Id IN:OptyCampIdMap.keyset()]);
        }
		
		if(!oppMap.isEmpty()){
			for(Opportunity opp:oppMap.values()){
				accIds.add(opp.Accountid);
			}
		}
		if(!accIds.isEmpty()){
			accMap = new Map<Id,Account>([select id,Last_Touch_Code__pc from Account where Recordtype.Name = 'Consumer' AND Id IN:accIds]);
		}
		
		if(!oppMap.isEmpty()){
			for(Opportunity opp:oppMap.values()){
				Account acc = accMap.get(opp.AccountId);
				acc.Last_Touch_Code__pc = campaignsMap.get(OptyCampIdMap.get(opp.Id)).Campaign_Code__c;
				accListToUpdate.add(acc);
			}
		}
		if(!accListToUpdate.isEmpty()){
            recursiveClass.conUpdateFromCI = true;
            List<Database.SaveResult> saveresults = Database.update(accListToUpdate,false);
            System.debug('saveresults==='+saveresults);
		}
    } 
}