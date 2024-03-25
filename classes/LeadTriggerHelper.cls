/**
* @File Name          : LeadTriggerHelper.cls
* @Description        : 
* @Author             : Tejaswini
* @Created Date       : 
* @Comments           : Added in updateLeadFields Method(Marketo_Sync__c field) for SFDC-998
**/
public without sharing class LeadTriggerHelper {
    public static boolean isBatchtestLead = false;
    
    public static void afterInsert(Map<Id,Lead> mapOfNewLead, Map<Id,Lead> mapOfOldLead){
        String nonMQLRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        if(UserInfo.getProfileId() == System.Label.CSS_Profile_Id || System.Label.CSS_Profile_Id.contains(UserInfo.getProfileId())){
            autoConvertLeads(mapOfNewLead,null,false,true);
        }
        else{
            autoConvertLeads(mapOfNewLead,null,true,false);
        }
        
    }
    public static void afterUpdate(Map<Id,Lead> mapOfNewLead, Map<Id,Lead> mapOfOldLead){
        //    if(UserInfo.getProfileId() == System.Label.MarketoSyncProfileId || System.Label.MarketoSyncProfileId.contains(UserInfo.getProfileId())){
        if(isBatchtestLead == false){
            system.debug('isBatchtestLead>>>'+isBatchtestLead);
        autoConvertLeads(mapOfNewLead,mapOfOldLead,true,false);
        }
        //  }
    }
    public static void autoConvertLeads(Map<Id,Lead> mapOfNewLead, Map<Id,Lead> mapOfOldLead,Boolean nonMQL,Boolean cssRT){
        
        String nonMQLRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NonMQL').getRecordTypeId();
        //Auto Convert Non MQL Leads. 
        List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();
        LeadStatus cLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        Database.LeadConvert leadConvert;
        map<string,list<lead>>  phoneLeadMap = new map<string,list<lead>>();
        map<string,list<lead>>  mobileLeadMap = new map<string,list<lead>>();
        Map<Id,Id> leadAccIds = new Map<Id,Id>();//this map holds leadid as key and acountid if phone number matches
        List<Lead> convertLeads = new List<Lead>();
        Map<Id,String> leadPhone = new Map<Id,String>();
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        for(Lead leadRec:mapOfNewLead.values()){
            if( !leadRec.isConverted && leadRec.RecordTypeId == nonMQLRecordTypeId && nonMQL &&( (leadRec.Status == 'Qualified' && String.isNotBlank(leadRec.Lead_Assignment__c) && mapOfOldLead==null) || (mapOfOldLead!=null && leadRec.Status == 'Qualified' && String.isNotBlank(leadRec.Lead_Assignment__c) && (mapOfOldLead.get(leadRec.id).Status !=  'Qualified' || String.isBlank(mapOfOldLead.get(leadRec.id).Lead_Assignment__c))))){
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
                // phoneMobileNum.add(ld.MobilePhone);
                /*if(leadRec.MobilePhone != Null){
leadPhone.put(leadRec.id,leadRec.MobilePhone);
if(mobileLeadMap.containskey(leadRec.MobilePhone)){
mobileLeadMap.get(leadRec.MobilePhone).add(leadRec);
}
else {
mobileLeadMap.put(leadRec.MobilePhone,new list<lead>{leadRec});
system.debug('mobileLeadMap--'+mobileLeadMap);
}
}*/
            }
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
        /* if(!mobileLeadMap.isEmpty() && mobileLeadMap!=null && (phoneLeadMap==null || phoneLeadMap.isEmpty())){
mobileSet.addAll(mobileLeadMap.keyset());
system.debug('mobileLeadMap=='+mobileLeadMap);
query = 'PersonMobilePhone IN : mobileSet';
}
if(!phoneLeadMap.isEmpty() && phoneLeadMap!=null && (mobileLeadMap==null || mobileLeadMap.isEmpty() ) ){
phoneset.addAll(phoneLeadMap.keyset());
system.debug('phoneset=='+phoneset);
query = 'phone IN : phoneSet';
}*/
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
                    /* else if (mobileLeadMap.containskey(acc.PersonMobilePhone)){
accMap.put(acc.id,acc);
phoneAccId.put(acc.PersonMobilePhone,acc.id);
list<lead> ldLst = mobileLeadMap.get(acc.PersonMobilePhone); 
convertLeads.addAll(ldlst);
system.debug('ldLstelse---'+ldLst);

}*/
                }
            }
        }
        Set<Id> leadIds = new Set<Id>();
        for(Lead leadRec:mapOfNewLead.values()){
            if( !leadRec.isConverted && leadRec.RecordTypeId == nonMQLRecordTypeId && nonMQL &&( (leadRec.Status == 'Qualified' && String.isNotBlank(leadRec.Lead_Assignment__c) && mapOfOldLead==null) || (mapOfOldLead!=null && leadRec.Status == 'Qualified' && String.isNotBlank(leadRec.Lead_Assignment__c) && (mapOfOldLead.get(leadRec.id).Status !=  'Qualified' || String.isBlank(mapOfOldLead.get(leadRec.id).Lead_Assignment__c))))){
                
                leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(leadRec.Id);                
                leadConvert.setConvertedStatus(cLeadStatus.MasterLabel);
                leadConvert.setOwnerId(UserInfo.getUserId());
                if(convertLeads!=null && convertLeads.contains(leadRec)){
                    leadConvert.setDoNotCreateOpportunity(true);
                    leadIds.add(leadRec.id);
                }
                massLeadConvert.add(leadConvert);
                system.debug('massLeadConvert>>>>'+massLeadConvert);
            }
        }
        LIst<database.LeadConvertResult> leadResults = new LIst<database.LeadConvertResult>();
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
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
                    
                }
                else{
                    for(Database.Error error : lcr.getErrors()) {
                        message +=error.getMessage()+'\n';
                    }
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'MQL Lead Convert:'+lcr.getLeadId(), 'Apex Error', message, false, false);
                    cbrErrorLog.add(cbr); 
                    // mapOfNewLead.get(lcr.getLeadId()).addError(message);
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
    public static void beforeInsert(List<lead> newLeads){
        updateLeadFields(newLeads);
        timeZoneUpdate(newLeads);
    }
    public static void updateLeadFields(List<lead> newLeads){
        for(Lead leadRec:newLeads){
            if(leadRec.RecordType_Name__c == 'NonMQL'){
                leadRec.status = 'Qualified';
            }
            if(leadRec.RecordType_Name__c == 'CSS Referral' || leadRec.RecordType_Name__c =='Manual Lead'){
                leadRec.Last_Touch_Code__c = 'SFDC';
                leadRec.First_Touch_Code__c = 'SFDC';
                leadRec.utm_medium_LT__c =leadRec.LeadSource;
                leadRec.utm_medium_FT__c = leadRec.LeadSource;
                leadRec.utm_source_LT__c = 'SFDC';
                leadRec.utm_source_FT__c = 'SFDC';
                if(String.isNotBlank(leadRec.Email)){
                    leadRec.Marketo_Sync__c=TRUE;  // part of SFDC-998
                }
                if(leadRec.RecordType_Name__c == 'CSS Referral'){
                    leadRec.utm_campaign_LT__c = 'CSS-create';
                    leadRec.utm_campaign_FT__c = 'CSS-create';
                }else{
                    leadRec.utm_campaign_LT__c = 'NSCE-create';
                    leadRec.utm_campaign_FT__c = 'NSCE-create';
                }
            }
        }
    }
    public static void beforeUpdate(Map<Id,Lead> newMap, Map<Id,Lead> oldMap){
        List<Lead> befUpdateList = new List<Lead>();
        System.debug('In Method---beforeUpdate');
        System.debug('Old Map lead---'+oldMap);
        for(Lead leadRec:newMap.values()){
            System.debug('debug---1');
            befUpdateList.add(leadRec);
            if((leadRec.RecordType_Name__c == 'CSS Referral' || leadRec.RecordType_Name__c =='Manual Lead') && String.isNotBlank(leadRec.Email) && !leadRec.Marketo_Sync__c && String.isBlank(oldMap.get(leadRec.Id).Email)){
                leadRec.Marketo_Sync__c=true;
            }
        }
        if(!befUpdateList.isEmpty()){
            timeZoneUpdate(befUpdateList); 
        }
        
    }
    //For story SFDC-1621
    public static void campaignMemberStatusChange(Map<Id,Lead> newMap,Map<Id,Lead> oldMap){
        system.debug('InsideMycamp');
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        set<id> leadNonMQLids = new set<id>();
        List<CampaignMember> campMemLst = new List<CampaignMember>();
        for(Lead nonMQLleadRec:newMap.values()){
            if(trigger.isUpdate && nonMQLleadRec.RecordType_Name__c == 'NonMQL' && nonMQLleadRec.IsConverted == true && !oldMap.isEmpty() && oldMap.get(nonMQLleadRec.Id).IsConverted == false){
                leadNonMQLids.add(nonMQLleadRec.id);
                system.debug('leadNonMQLidslead'+leadNonMQLids);
            }
        }
        if(!leadNonMQLids.isEmpty()){
            for(CampaignMember eachCampMem :[select id,leadId,campaignId,Status from CampaignMember where LeadId IN :leadNonMQLids AND campaignId !=null AND Campaign.Type ='Outbound Dialer' and Campaign.IsActive =true AND Status IN ('Calling','Not Ready','Ready')] ){
                system.debug('eachCampMem---'+eachCampMem);
                if(eachCampMem.status =='Calling'){
                    eachCampMem.status='Remove Pending';
                    system.debug('MyIflead');
                }
                if(eachCampMem.status =='Not Ready' || eachCampMem.status =='Ready'){
                    eachCampMem.status='Removed'; 
                    system.debug('MyIfelselead');
                }
                campMemLst.add(eachCampMem);
            }
        }
        if(!campMemLst.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (campMemLst,false);
            string ErrDetail;
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Auto Dialer Campaign Member Status', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);  
            } 
        }
        if(!cbrErrorLog.isEmpty()){
            Database.insert(cbrErrorLog, false);
        }
    }
    //For story SFDC-1722   
    public static void timeZoneUpdate(List<Lead> leadList){ 
        Set<string> leadzipCode = new Set<string>();
        Map<string,US_Zipcode__c> zipCodeMap = new Map<string,US_Zipcode__c>();
        map<id,Lead> oldMapLead = (map<id,Lead>) trigger.oldMap;
        if(Userinfo.getProfileId() == [select profileid from user where profile.name ='Marketo Sync' limit 1].profileid){
            system.debug('Inseeeide method');
            for(Lead markeToLd:leadList){
                if(markeToLd.PostalCode != null && trigger.isInsert){
                    leadzipCode.add(markeToLd.PostalCode);
                    system.debug('leadzipCodeInsert--'+leadzipCode);
                }
                else if(trigger.isUpdate && oldMapLead.get(markeToLd.id).PostalCode != markeToLd.PostalCode && markeToLd.PostalCode !=null){
                    leadzipCode.add(markeToLd.PostalCode);
                    system.debug('leadzipCodeUpdate--'+leadzipCode);
                }
            }
            if(!leadzipCode.isEmpty()){
                for(US_Zipcode__c zipUs:[select id,Name,City__c,Country__c,State__c,Time_Zone__c from US_Zipcode__c where Name IN:leadzipCode]){
                    zipCodeMap.put(zipUs.Name,zipUs);
                    system.debug('zipCodeMap---'+zipCodeMap);
                }
            }
            if(!leadzipCode.isEmpty()){
                for(Lead postalCodeLead:leadList){
                    system.debug('postalCodeLead--'+postalCodeLead.PostalCode);
                    if(zipCodeMap.containskey(postalCodeLead.PostalCode) && string.isNotBlank(postalCodeLead.PostalCode)){
                        US_Zipcode__c zip = zipCodeMap.get(postalCodeLead.PostalCode);
                        system.debug('zip.Time_Zone__c---'+zip.Time_Zone__c);
                        postalCodeLead.Timezone__c = zip.Time_Zone__c;
                        if(postalCodeLead.Country ==null){
                            postalCodeLead.Country='United States';
                        }
                        if(postalCodeLead.City==null){
                            postalCodeLead.City=zip.City__c;
                        }
                        if(postalCodeLead.Street==null){
                            postalCodeLead.Street='Need Info';
                        }
                    }
                }
            }
        }
    } 
}