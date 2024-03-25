/*************************************************************************************************
* @description This Batch job is to campaign member status when below criteria is satisfied.
* @param - 
* @story - SFDC-1639
* @Author -Teksystems
* @date - 15-APR-2021 (Teksystems)
*/
public class BatchToUpdateCampaignMemberStatus implements Database.Batchable<sObject>,Database.Stateful{
    
    public date leadDueDt = System.today().adddays(13);
    public Database.QueryLocator Start(Database.BatchableContext bc){
        string query='select id,leadid,CampaignId,Status from CampaignMember '+ 
            'where leadid !=null and CampaignId !=null and lead.IsConverted =false and lead.Due_Date__c <=:leadDueDt and lead.RecordType.name=\'NonMQL\' and lead.Status =\'Qualified\' and Lead.Lead_Assignment__c =null and Campaign.Type =\'Outbound Dialer\' and Campaign.IsActive =true and (Status =\'Ready\' or Status =\'Calling\')';
        return Database.getQueryLocator(query);
    }    
    public void Execute(Database.BatchableContext bc, list<CampaignMember> campMemLst){
        for(CampaignMember eachCampMem : campMemLst){
            if(eachCampMem.Status !='Remove Pending'){
                eachCampMem.Status='Remove Pending';
            }
        }
        if(!campMemLst.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (campMemLst,false);
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
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Auto Dialer Campaign Member status update', 'Apex Error', ErrDetail, false, false);
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