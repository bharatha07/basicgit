/*************************************************************************************************
* @description- Batch Job to assign NonMQL Leads to Campaigns as CampaignMember.
* @param - 
* @story - SFDC-1619
* @Author -Teksystems
* @date - 15-APR-2021 (Teksystems)
**************************************************************************************************/
public class BatchToAssignLeadsToCampaign implements Database.Batchable<sObject>,Database.Stateful{
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Integer futureDate= integer.valueOf(system.label.Lead_Due_Date_From);
        Integer PastDate = integer.valueOf(system.label.Lead_Due_Date_TO);
        date leadDueDatefuture= system.today().addDays(futureDate);
        date leadDueDatePast=system.today().addDays(PastDate);
        string query='select id,CreatedDate, Due_Date__c, RecordType.name,IsConverted,Phone, Status, Lead_Assignment__c from Lead where Status=\'Qualified\' and Due_Date__c!=null and Lead_Assignment__c=null and Phone!=null and IsConverted=false and RecordType.name=\'NonMQL\' and createddate <= LAST_N_DAYS:30 and Due_Date__c>=:leadDueDatefuture and Due_Date__c<:leadDueDatePast and ID NOT IN (select leadid from CampaignMember where leadid!=null)';
        return Database.getQueryLocator(query);
    }    
    public void Execute(Database.BatchableContext bc, list<Lead> Leadlst){
        system.debug('the scope varible--->'+Leadlst);
        List<Campaign> outbounddailercamp=[select id,Name, Type, IsActive  from Campaign where IsActive=true and Type='Outbound Dialer' limit 1];
        List<CampaignMember> newCampaignMembers= new List<CampaignMember>();
        system.debug('the Campaign varible--->'+outbounddailercamp);
        if(!Leadlst.isEmpty()){
            for(Lead eachlead:Leadlst){
                if(!outbounddailercamp.isEmpty()){
                    newCampaignMembers.add(new CampaignMember(CampaignId=outbounddailercamp[0].id,LeadId=eachlead.id,Status='Ready'));
                }
            }
        }
        
        if(!newCampaignMembers.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert (newCampaignMembers,false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            string ErrDetail;
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Batch For CampaignMember creation using Leads', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);  
            }
            
            if(!cbrErrorLog.isEmpty()){
                Database.insert(cbrErrorLog, false);
            }
            system.debug('>>>>>>'+cbrErrorLog);
        }
    }
    public void Finish(Database.BatchableContext bc){
        
    }
    
}