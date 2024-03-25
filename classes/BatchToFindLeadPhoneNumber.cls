/*************************************************************************************************
* @description This Batch job is use to associate contact to an existing opportunity based on conditions.
* @param - 
* @story - SFDC-1413
* @Author -Teksystems
* @date - 28-JAN-2020 (Teksystems)
*/
global class BatchToFindLeadPhoneNumber implements Database.Batchable<sObject>,Database.Stateful{
    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        string query='select id,name,phone,MobilePhone, Lead_Assignment__c from lead where RecordType.Name =\'NonMQL\' '+
            ' AND Lead_Assignment__c = Null AND (Phone != Null OR MobilePhone != Null )'+
            ' AND isConverted = False ';
        return Database.getQueryLocator(query);
    }    
    global void Execute(Database.BatchableContext bc, list<lead> leadLst){
        set<string> phoneNum = new set<string>();
        map<string,list<lead>>  phoneLeadMap = new map<string,list<lead>>();
        map<string,list<lead>>  mobileLeadMap = new map<string,list<lead>>();
        Map<string,List<Opportunity>> OptyMap = new Map<string,List<Opportunity>>();
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        list<lead> convertLead  = new list<lead>();
        set<id> accIds = new set<id>();
        set<id> dupLeadIds = new set<id>();
        set<id> dupAccIds = new set<id>();
        Map<String,Opportunity> oppConOptyMap = new Map<String,Opportunity>();
        list<opportunityContact__c> lstOptyCon = new list<opportunityContact__c>();
        List<Database.LeadConvert> massLeadConvert = new List<Database.LeadConvert>();
        for(lead ld : leadLst){
            
            //phoneMobileNum.add(ld.Phone);
            if(ld.Phone != Null){
                if(phoneLeadMap.containskey(ld.Phone)){
                    phoneLeadMap.get(ld.Phone).add(ld);
                }
                else {
                    phoneLeadMap.put(ld.Phone,new list<lead>{ld});
                    system.debug('phoneLeadMap--'+phoneLeadMap);
                }
            }
            // phoneMobileNum.add(ld.MobilePhone);
            if(ld.MobilePhone != Null){
                if(mobileLeadMap.containskey(ld.MobilePhone)){
                    mobileLeadMap.get(ld.MobilePhone).add(ld);
                }
                else {
                    mobileLeadMap.put(ld.MobilePhone,new list<lead>{ld});
                    //system.debug('mobileLeadMap--'+mobileLeadMap);
                }
            }
            
        }
        if(!mobileLeadMap.isEmpty() || !phoneLeadMap.isEmpty()){
            
            for(account acc : [select id,phone,PersonMobilePhone from account where RecordTypeId =:consumerRecordTypeId
                              AND (phone IN :phoneLeadMap.keyset() or PersonMobilePhone IN : mobileLeadMap.keyset()) limit 49999]){
                                   dupAccids.add(acc.id);
                                   
                                   //system.debug('phoneNum--'+phoneNum);
                                   system.debug('dupAccids>>>'+dupAccids);
                                   if(phoneLeadMap.containskey(acc.phone)){
                                       phoneNum.add(acc.phone);
                                       //system.debug('phoneNum60--'+phoneNum);
                                       list<lead> ldLst = phoneLeadMap.get(acc.Phone); 
                                       convertLead.addAll(ldlst);
                                       //system.debug('ldLst---'+ldLst);
                                   }
                                   else if (mobileLeadMap.containskey(acc.PersonMobilePhone)){
                                       phoneNum.add(acc.PersonMobilePhone);
                                       //system.debug('phoneNum67--'+phoneNum);
                                       list<lead> ldLst = mobileLeadMap.get(acc.PersonMobilePhone); 
                                       convertLead.addAll(ldlst);
                                       //system.debug('ldLstelse---'+ldLst);
                                       
                                   }
                                   
                               }
            
        }
        if(!convertLead.isEmpty()){
            LeadStatus cLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
            for(lead lds : convertLead){
                if(!dupLeadIds.contains(lds.id)){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lds.id);
                lc.setDoNotCreateOpportunity(true);
                lc.setConvertedStatus(cLeadStatus.MasterLabel);
                massLeadConvert.add(lc);
                dupLeadIds.add(lds.id);
                }
               
            }
        }
        if (!massLeadConvert.isEmpty()) {
            for(Database.LeadConvertResult lcr : Database.convertLead(massLeadConvert, false)) {
                if(lcr.isSuccess()) {
                    accIds.add(lcr.accountid);
                    system.debug('accIds---'+accIds);
                }
                else{
                    for(Database.Error error : lcr.getErrors()) {
                        system.debug('error---'+error.getMessage());
                    }
                }
            }
        }
        
        if(!dupAccIds.isEmpty()){
            for(opportunity opty : [select id,accountid,Enrollment_Date__c,status__c,account.phone,account.PersonMobilePhone,CreatedDate
                                    from opportunity where  accountid IN : dupAccIds 
                                    and (status__c='Open' or status__c='Enrolled') order by Enrollment_Date__c desc limit 49999]){
                                        if(opty.account.phone != Null){
                                            if(OptyMap.containskey(opty.account.phone)){
                                                OptyMap.get(opty.account.phone).add(opty);
                                            } 
                                            else{
                                                OptyMap.put(opty.account.phone , new list<opportunity>{opty});
                                            }  
                                        }
                                        if(opty.account.PersonMobilePhone != Null){
                                            if(OptyMap.containskey(opty.account.PersonMobilePhone)){
                                                OptyMap.get(opty.account.PersonMobilePhone).add(opty);
                                            } 
                                            else{
                                                OptyMap.put(opty.account.PersonMobilePhone , new list<opportunity>{opty});
                                            } 
                                        }
                                        
                                        system.debug('OptyMap---'+OptyMap);
                                    }
        }
        
        if(!OptyMap.isEmpty()){
            list<opportunity> lstOpty = new list<opportunity>();
            for(string phn : phoneNum){
                if(OptyMap.get(phn) != Null && OptyMap.get(phn).size() > 0){
                    lstOpty.addAll(OptyMap.get(phn));
                }
                
                system.debug('lstOpty---'+lstOpty);
                
            }
            if(lstOpty.size() == 1 && !lstOpty.isEmpty()){
                for(opportunity opp : lstOpty){
                    if(opp.account.phone != Null){
                        oppConOptyMap.put(opp.account.phone , opp);  
                    }
                    if(opp.account.PersonMobilePhone != Null){
                        oppConOptyMap.put(opp.account.PersonMobilePhone , opp);  
                    }
                    
                } 
                system.debug('oppConOptyMapif--'+oppConOptyMap);
            }
            else if(lstOpty.size() > 1 && !lstOpty.isEmpty()){
                //system.debug('test---'+lstOpty);
                for(opportunity opp : lstOpty){
                    //system.debug('test145---');
                    if(oppConOptyMap.containskey(opp.account.phone)){
                        //system.debug('opp.Enrollment_Date__c ---'+opp.Enrollment_Date__c );
                        //system.debug('opty134--'+oppConOptyMap.get(opp.account.phone).Enrollment_Date__c);
                        if(opp.Enrollment_Date__c != Null){ 
                            if(oppConOptyMap.get(opp.account.phone).Enrollment_Date__c == Null){
                                oppConOptyMap.put(opp.account.phone , opp); 
                                //system.debug('oppConOptyMap----152--'+oppConOptyMap);
                            }
                            else if (opp.Enrollment_Date__c > oppConOptyMap.get(opp.account.phone).Enrollment_Date__c){
                                oppConOptyMap.put(opp.account.phone , opp);
                                //system.debug('oppConOptyMap>>>>>1'+oppConOptyMap);
                            }
                        }
                        else if(oppConOptyMap.get(opp.account.phone).Enrollment_Date__c == Null
                                && opp.CreatedDate > oppConOptyMap.get(opp.account.phone).CreatedDate ){
                            oppConOptyMap.put(opp.account.phone , opp);
                             //system.debug('oppConOptyMap>>>>>161'+oppConOptyMap);
                        }
                    }
                    else {
                        if(opp.account.phone != Null){
                            oppConOptyMap.put(opp.account.phone , opp); 
                            //system.debug('oppConOptyMap>>>>>3'+oppConOptyMap);
                        }
                    }
                    
                    if(oppConOptyMap.containskey(opp.account.PersonMobilePhone)){
                        //system.debug('opp.Enrollment_Date__c ---'+opp.Enrollment_Date__c );
                        //system.debug('opty134--'+oppConOptyMap.get(opp.account.PersonMobilePhone).Enrollment_Date__c);
                        if(opp.Enrollment_Date__c != Null){ 
                            if(oppConOptyMap.get(opp.account.PersonMobilePhone).Enrollment_Date__c == Null){
                                oppConOptyMap.put(opp.account.PersonMobilePhone , opp); 
                            }
                            else if (opp.Enrollment_Date__c > oppConOptyMap.get(opp.account.PersonMobilePhone).Enrollment_Date__c){
                                oppConOptyMap.put(opp.account.PersonMobilePhone , opp);
                                //system.debug('oppConOptyMap>>>>>2'+oppConOptyMap);
                            }
                        }
                        else if(oppConOptyMap.get(opp.account.phone).Enrollment_Date__c == Null
                            && opp.CreatedDate > oppConOptyMap.get(opp.account.PersonMobilePhone).CreatedDate ){
                            oppConOptyMap.put(opp.account.PersonMobilePhone , opp);
                        }
                    }
                    else {
                        if(opp.account.PersonMobilePhone != Null){
                            oppConOptyMap.put(opp.account.PersonMobilePhone , opp); 
                            //system.debug('oppConOptyMap>>>>>4'+oppConOptyMap);
                        }
                    }
                }
            }
        }
        
        if(!oppConOptyMap.isEmpty()){
            for(account acc : [select id,phone,PersonMobilePhone from account where id IN : accIds]){
                if(oppConOptyMap.containskey(acc.Phone)){
                    opportunity opty = oppConOptyMap.get(acc.Phone);
                    system.debug('opty152--'+opty);
                    opportunityContact__c oppCon = new opportunityContact__c();
                    oppCon.PersonAccount__c = acc.id;
                    oppCon.Opportunity__c =opty.id;
                    oppCon.Role__c ='Other';
                    lstOptyCon.add(oppCon);
                }
                else if(oppConOptyMap.containskey(acc.PersonMobilePhone)){
                    opportunity opty = oppConOptyMap.get(acc.PersonMobilePhone);
                    system.debug('opty161--'+opty);
                    opportunityContact__c oppCon = new opportunityContact__c();
                    oppCon.PersonAccount__c = acc.id;
                    oppCon.Opportunity__c =opty.id;
                    oppCon.Role__c ='Other';
                    lstOptyCon.add(oppCon);
                }
                
            }
        }
        if(!lstOptyCon.isEmpty()){
            insert lstOptyCon;
        }
    }
    global void Finish(Database.BatchableContext bc){
        
    }
}