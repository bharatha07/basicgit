/*************************************************
*Component Name:OpportunityClose_batch
Description: Batch Job to change status of opportunity to close
Story : CBRSFDC8-246,1036,SFDC-1839,SFDC-1960,1948
Created By: Teksystems
**************************************************/

global class OpportunityClose_batch implements Database.Batchable<sObject>,Database.Stateful{
    
    global List<String> errors = new List<String>();
    global final Date DueCheck = system.today().addDays(-15);
    global final Date DueCheck1 = system.today().addDays(-22);
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT Id, Name, Status__c,Loss_Reason__c, Due_Date__c,Program_Enrolled_in__c, Enrollment_Date__c,StageName, Storage_Date__c FROM Opportunity Where LeadSource!=\'Lab\' AND ((Due_Date__c =: DueCheck AND Enrollment_Date__c = NULL AND Status__c=\'Open\' AND Stored_CB__c = NULL AND Stored_CT__c = NULL AND Type = NULL) OR (Due_Date__c =: DueCheck1 AND Storage_Date__c = NULL AND Status__c=\'Enrolled\' AND Enrollment_Date__c!= NULL AND Stored_CB__c = NULL AND Stored_CT__c = NULL AND Type = NULL ))'; 
        //system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        //system.debug('Inside execute method');
        //system.debug('scope=====>>>>>'+scope);
        List<Opportunity> opplist= new List<Opportunity>();
        List<Opportunity> opplisttoupdate= new List<Opportunity>();
        string ErrDetail;
        set<Id> enrolOptyId = new set<Id>();
        map<id,integer> mapCount = new Map<Id,integer>();
        //SFDC-1960 Start
        for(Opportunity opp:scope){
            if(opp.Storage_Date__c == NULL && opp.Status__c =='Enrolled'){
                enrolOptyId.add(opp.id);
            }
        }
        if(!enrolOptyId.isEmpty()){
            
            mapCount=campaignCodeCheck(enrolOptyId);
        }
        //ENd
        for(Opportunity opp:scope){ 
            if(opp.Enrollment_Date__c == NULL && opp.Status__c=='Open'){ 
                opp.Loss_Reason__c = 'Auto Closed';
                opp.Status__c = 'Closed_Lost';
                opp.StageName= 'Closed Lost';
                opp.Closed_Lost_Date__c=system.now();
            }
            
            else if(opp.Storage_Date__c == NULL && opp.Status__c =='Enrolled'){
                integer count = 0;
                if(mapCount.containskey(opp.id)){
                    count=mapCount.get(opp.id);
                }
                //SFDC-1960,1948 related change for NPP
                opp.Loss_Reason__c = opp.Program_Enrolled_in__c !='Family Banking'?'Non-collect': count > 0 ?'Non-collect':'Cancellation';
                opp.Status__c = 'Closed_Lost';
                opp.StageName= 'Closed Lost';
                opp.Closed_Lost_Date__c=system.now();
            }
            
            opplist.add(opp);
        }
        
        if(!opplist.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (opplist,false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                //system.debug('erromessgae'+ErrDetail);
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Auto Close Optys Which Due Dates Passed', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
                //system.debug('>>>>>>'+cbrErrorLog);
            }
        }
        
    }  
    
    global void finish(Database.BatchableContext BC){   
        
    }
    //SFDC-1960 related logic.
    public static map<id,integer> campaignCodeCheck(set<id> optyIds){
        map<id,integer> campiagnInfluenceMap = new map<id,integer>();
        try{
            list<string> CampiagnCodeLst = label.CampiagnCode.split(',');
            for(AggregateResult campInflu :[select count(id) recordCount,OpportunityId optyId from CampaignInfluence where OpportunityId IN : OptyIds 
                                       and Campaign.Campaign_Code__c IN : CampiagnCodeLst group by opportunityId]){
                                           integer size = (Integer)campInflu.get('recordCount');
                                           id oppId =(Id)campInflu.get('optyId');
                                           campiagnInfluenceMap.put(oppId,size);
                                       }
        }
        catch(exception ex){
            
        }
        return campiagnInfluenceMap;
    }    
}