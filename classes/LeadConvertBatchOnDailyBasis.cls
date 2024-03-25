/*************************************************************************************************
* @description This Batch job is used to convert leads which are having lead assignment value.
* @param - 
* @story - SFDC-2083
* @Author -Teksystems
* @date - 09-SEP-2021 (Teksystems)
*/
global class LeadConvertBatchOnDailyBasis implements Database.Batchable<sObject>,Database.Stateful{
    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        string query='Select id,Lead_Assignment__c,LastModifiedDate,isConverted  from lead where Lead_Assignment__c !=null'+
            ' AND LastModifiedDate = TODAY'+
            ' AND isConverted = False ';
        return Database.getQueryLocator(query);
    }    
    global void Execute(Database.BatchableContext bc, list<lead> leadLst){
        List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();
        LeadStatus cLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Database.LeadConvert leadConvert;
        map<string,list<lead>>  phoneLeadMap = new map<string,list<lead>>();
        // map<string,list<lead>>  mobileLeadMap = new map<string,list<lead>>();
        Map<Id,Id> leadAccIds = new Map<Id,Id>();//this map holds leadid as key and acountid if phone number matches
        List<Lead> convertLeads = new List<Lead>();
        Map<Id,String> leadPhone = new Map<Id,String>();
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<Id,Lead> mapOfNewLead = new Map<Id,Lead>([select id,Phone from lead where Id IN :leadLst]);
        for(Lead leadRec:mapOfNewLead.values()){
            
            if(leadRec.Phone != Null){
                leadPhone.put(leadRec.id,leadRec.Phone);
                if(phoneLeadMap.containskey(leadRec.Phone)){
                    phoneLeadMap.get(leadRec.Phone).add(leadRec);
                    
                }
                else {
                    phoneLeadMap.put(leadRec.Phone,new list<lead>{leadRec});
                    system.debug('phoneLeadMap--'+phoneLeadMap);
                }
            }
            
            // }
        }
        Map<String,Id> phoneAccId = new Map<String,Id>();
        Map<Id,Account> accMap = new Map<Id,account>();
        List<Account> accList = new List<Account>();
        set<Id> dupAccids = new Set<Id>();
        Map<Id,OpportunityContact__c> oppConMap = new Map<Id,OpportunityContact__c>();
        Map<Id,List<OpportunityContact__c>> accConts = new Map<Id,List<OpportunityContact__c>>();
        String query = '';
        List<String> phoneset = new List<String>();
        List<String> mobileSet = new List<String>();
        // if((!mobileLeadMap.isEmpty() && mobileLeadMap!=null) || (!phoneLeadMap.isEmpty() && phoneLeadMap!=null)){
        if(!phoneLeadMap.isEmpty() && phoneLeadMap!=null){
            phoneset.addAll(phoneLeadMap.keyset());
            // mobileSet.addAll(mobileLeadMap.keyset());
            //system.debug('mobileLeadMap=='+mobileLeadMap);
            system.debug('phoneset=='+phoneset);
            query = 'phone IN : phoneSet';
        }
        system.debug(phoneSet.size());
        //system.debug(mobileSet.size());
        if(String.isNotBlank(query)){
            system.debug('phoneset==11'+phoneset);
            query = 'select id,phone,PersonMobilePhone from account where RecordTypeId =:consumerRecordTypeId AND '+query +' Limit 49999';
        }
        system.debug('query---'+query);
        if(String.isNotBlank(query)){
            accList = database.query(query);
        }
        system.debug('account size()'+accList.size());
        system.debug('account>>>'+accList);
        if(accList!=null && !accList.isEmpty()){
            oppConMap = new Map<Id,OpportunityContact__c>([select id,personAccount__c,opportunity__c,opportunity__r.status__c,opportunity__r.storage_date__c from opportunitycontact__c where personAccount__c IN:accList AND (opportunity__r.status__c = 'Enrolled' OR opportunity__r.status__c = 'Open' OR (opportunity__r.status__c = 'Stored' AND opportunity__r.storage_date__c =LAST_90_DAYS)) limit 49999]);
        }
        system.debug('oppConMap==='+oppConMap);
        if(oppConMap!=null){
            for(OpportunityContact__c opp:oppConMap.values()){
                if(accConts!=null && accConts.containskey(opp.personAccount__c)){
                    List<OpportunityContact__c> tempoppCons = accConts.get(opp.personAccount__c);
                    tempoppCons.add(opp);
                    accConts.put(opp.personAccount__c,tempoppCons);
                }
                else{
                    accConts.put(opp.personAccount__c,new List<OpportunityContact__c>{opp});
                }
            }
        }
        system.debug('accConts---'+accConts);
        if(accList!=null && !accList.isEmpty()){
            for(account acc : accList){
                if(accConts.containskey(acc.id)){
                    dupAccids.add(acc.id);
                    if(phoneLeadMap.containskey(acc.phone)){
                        accMap.put(acc.id,acc);
                        system.debug('accMap>>>'+accMap);
                        phoneAccId.put(acc.phone,acc.Id);
                        system.debug('phoneAccId>>>>'+phoneAccId);
                        list<lead> ldLst = phoneLeadMap.get(acc.Phone);
                        convertLeads.addAll(ldlst);  
                        
                        system.debug('ldLst---'+ldLst);
                    }
                    
                }
            }
        }
        Set<Id> leadIds = new Set<Id>();
        for(Lead leadRec:mapOfNewLead.values()){
            
            leadConvert = new Database.LeadConvert();
            leadConvert.setLeadId(leadRec.Id);                
            leadConvert.setConvertedStatus(cLeadStatus.MasterLabel);
            if(convertLeads!=null && convertLeads.contains(leadRec)){
                leadConvert.setDoNotCreateOpportunity(true);
                leadIds.add(leadRec.id);
            }
            massLeadConvert.add(leadConvert);
            system.debug('massLeadConvert>>>>'+massLeadConvert);
            
        }
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        LIst<database.LeadConvertResult> leadResults = new LIst<database.LeadConvertResult>();
        if (!massLeadConvert.isEmpty()) {
            leadResults = Database.convertLead(massLeadConvert, false);
        }
        if(leadResults!=null && !leadResults.isEmpty()){
            String message;
            for(Database.LeadConvertResult lcr : leadResults) {
                if(lcr.isSuccess()) {
                    if(leadIds.contains(lcr.getLeadId())){
                        leadAccIds.put(lcr.getLeadId(),lcr.getAccountId());
                        system.debug('leadAccIds>>>>'+leadAccIds);
                    }
                    message = '';
                    // mapOfNewLead.get(lcr.getLeadId()).addError(message);
                } 
                else{
                    String errMsg = null;
                    for(database.error err:lcr.getErrors()){
                        errMsg = lcr.getLeadId() +':'+err.getMessage()+'.';
                    }
                    cbr_Error_Log__c cbr = UtilityClass.logErrors(lcr.getLeadId(),'Converting Lead Manually for Non MQL Leads on'+' '+system.today(),'Apex event',errMsg,false,false);
                    cbrErrorLog.add(cbr);
                }
            }
        }
        if(cbrErrorLog!=null){
            database.insert(cbrErrorLog,false);
        }
        
        List<OpportunityContact__c> oppClistToinsert = new List<OpportunityContact__c>();
        set<lead> lds = new set<lead>();
        if(leadAccIds!=null && !leadAccIds.isEmpty()){
            for(Lead ldCon:convertLeads){
                lds.add(ldCon);
                
            }
            for(lead l : lds){
                if(leadAccIds.containskey(l.id)){
                    
                    List<OpportunityContact__c> oppConsList = accConts.get(phoneAccId.get(leadPhone.get(l.id)));
                    system.debug('oppConsList>>>'+oppConsList);
                    if(oppConsList.size()>0){
                        //List<OpportunityContact__c> oppCons = accRec.opportunitycontacts__r;
                        Id oppId = null;
                        Boolean isEnrolled = false;
                        Boolean isStored = false;
                        Boolean isOpen = false;
                        for(OpportunityContact__c oppCon:oppConsList){
                            if(oppCon.Opportunity__r.status__c =='open'){
                                oppId = oppCon.opportunity__c;
                                isOpen = true;
                                system.debug('oppIdOpen'+oppId);
                            }
                            else if(oppCon.Opportunity__r.status__c =='Enrolled' && !isOpen){
                                oppId = oppCon.Opportunity__c;
                                isEnrolled = true;
                                system.debug('oppIdEnrolled'+oppId);
                            }
                            else if(oppCon.Opportunity__r.status__c =='Stored' && !isOpen && !isEnrolled){
                                oppId = oppCon.Opportunity__c;
                                isStored = true;
                                break;
                                system.debug('oppIdStored'+oppId);
                            }
                        }
                        OpportunityContact__c oppC = new OpportunityContact__c();
                        oppc.Role__c = 'Other';
                        oppc.Opportunity__c = oppId;
                        Oppc.PersonAccount__c = leadAccIds.get(l.id);
                        oppClistToinsert.add(oppc);
                        system.debug('oppClistToinsert>>>'+oppClistToinsert);
                    }
                }
            }
        }
        if(oppClistToinsert!=null && oppClistToinsert.size()>0){
            database.insert(oppClistToinsert,false);
        } 
    }
    global void Finish(Database.BatchableContext bc){
        
    }
}