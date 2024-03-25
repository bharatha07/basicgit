/*****************************************************************************************************************
* Component Name: oppContactRoleCreatebatch
* Created Date: 2nd June 2020
* Created By: Tejaswini(TEKsystems)
* Description: SFDC - 963/961. To create opportunitycontactRoles for primary contacts or for the roles - 
  'Father/Mother/ Grandparent/ Adoptive Father/ Adoptive mother/ Partner'
********************************************************************************************************************/
global class oppContactRoleCreatebatch implements Database.Batchable<sObject> {
    global Boolean isHistorical = false;
    global Boolean isTestExec = false;
    global static List<String> roles = new List<String>{'Mother','Father','Grandparent','Adoptive Mother','Adoptive Father','Partner','Unkown','Other'};
    global oppContactRoleCreatebatch(Boolean historicalData,Boolean testRun){
        isHistorical = historicalData;
        isTestExec = testRun;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('roles==='+roles);
    system.debug('Start method');
       String query;
       if(isHistorical){
           query = 'Select Id,PersonAccount__c, Opportunity__c,Role__c, Primary__C,PersonAccount__r.PersonContactId from opportunitycontact__c Where Primary__C = true OR Role__c IN:roles';
       }
       else{
           system.debug('Daily batch');
           if(isTestExec){
               system.debug('Daily batch Test');
            query = 'Select Id,PersonAccount__c, Opportunity__c,Role__c, Primary__C,PersonAccount__r.PersonContactId from opportunitycontact__c where LastModifiedDate = TODAY AND Role__c IN:roles';
           }
           else{
               system.debug('Daily batch Not Test');
            query = 'Select Id,PersonAccount__c, Opportunity__c,Role__c, Primary__C,PersonAccount__r.PersonContactId from opportunitycontact__c where LastModifiedDate = YESTERDAY AND Role__c IN:roles';
           }
           
       }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<OpportunityContact__C> scope){
        system.debug('scope--'+scope);
        List<OpportunityContactRole> optyConRoleListToInsert = new List<OpportunityContactRole>();
        List<OpportunityContactRole> optyConRoleListToUpdate = new List<OpportunityContactRole>();
        List<opportunitycontactRole> optyConRolesToDelete = new List<OpportunityContactRole>();
        Map<Id,opportunitycontactRole> optyContRoles = new Map<Id,OpportunityContactRole>();
        if(isHistorical){
            for(OpportunityContact__C optyCon:scope){
                OpportunityContactRole conRole = new OpportunityContactRole();
                conRole.ContactId = optyCon.PersonAccount__r.PersonContactId;
                conRole.OpportunityId = optyCon.Opportunity__c;
                conRole.role = optyCon.Role__c;
                if(optyCon.Primary__C == true){
                    conRole.IsPrimary = true;
                }
                optyConRoleListToInsert.add(conRole);
            }
        }
        else{
            Map<Id,opportunitycontactRole> conOppConRole = new Map<Id,opportunitycontactRole>();
            Map<Id,Map<Id,OpportunityContactRole>> oppToOCR = new Map<Id,Map<Id,OpportunityContactRole>>();
            Map<Id,Map<Id,OpportunityContact__C>> oppToOppCons = new Map<Id,Map<Id,OpportunityContact__C>>();
            for(OpportunityContact__C oppCon:scope){
                if(oppToOppCons!=null && !oppToOppCons.isEmpty() && oppToOppCons.containskey(oppCon.Opportunity__C)){
                    Map<Id,OpportunityContact__C> tempMap = oppToOppCons.get(oppCon.Opportunity__C);
                    tempMap.put(oppCon.id,oppCon);
                    oppToOppCons.put(oppCon.Opportunity__C,tempMap);
                }
                else{
                    oppToOppCons.put(oppCon.Opportunity__C,new Map<Id,OpportunityContact__C>{oppCon.id=>oppCon});
                }
            }
            system.debug('oppToOppCons==='+oppToOppCons);
            if(!oppToOppCons.isEmpty()){
                optyContRoles = new Map<Id,opportunitycontactRole>([select id,Role,IsPrimary,opportunityId,ContactId from opportunitycontactRole where opportunityId IN:oppToOppCons.keyset() AND (Role IN:roles OR Role =null)]);
            }
            
            system.debug('optyContRoles===='+optyContRoles);
            if(optyContRoles!=null && !optyContRoles.isEmpty()){
                for(OpportunityContactRole ocr:optyContRoles.values()){
                    if(oppToOCR!=null && !oppToOCR.isEmpty() && oppToOCR.containskey(ocr.opportunityId)){
                        Map<Id,opportunityContactRole> tempMap = oppToOCR.get(ocr.opportunityId);
                        tempMap.put(ocr.ContactId,ocr);
                        oppToOCR.put(ocr.opportunityId,tempMap);
                    } 
                    else{
                        oppToOCR.put(ocr.opportunityId,new Map<Id,opportunitycontactRole>{ocr.contactId=>ocr});
                    }
                }
            }
            system.debug('oppToOCR++='+oppToOCR);
            if(oppToOppCons!=null && !oppToOppCons.isEmpty()){
                for(Id oppId:oppToOppCons.keyset()){
                    system.debug('in side for looo');
                    Map<id,opportunityContactRole> tempOCRMap = oppToOCR.get(oppId);
                    for(opportunityContact__C oppC:oppToOppCons.get(oppId).values()){
                        if(tempOCRMap!=null && !tempOCRMap.isEmpty() && tempOCRMap.containskey(oppC.PersonAccount__r.PersonContactId)){
                            system.debug('tempOCRMap==='+tempOCRMap);
                            system.debug('oppCprim----'+oppC.primary__c);
                            
                            OpportunityContactRole ocr = tempOCRMap.get(oppC.PersonAccount__r.PersonContactId);
                            system.debug('ocrsprim----'+ocr.isPrimary);
                            Boolean ifChanged = false;
                            if(oppC.primary__c == true && ocr.isPrimary !=true){
                                system.debug('primary---');
                                ocr.isPrimary = true;
                                ifChanged = true;
                            }
                            if(oppC.Role__c != ocr.Role && oppC.Role__c != 'Unknown' && oppC.Role__c !='Other'){
                                system.debug('oppcRole--'+oppC.Role__c);
                                ocr.Role = oppC.Role__c;
                                ifChanged = true;
                            }
                            if(ifChanged){
                                system.debug('optyConRoleListToUpdate>>>>>+++'+optyConRoleListToUpdate);
                                optyConRoleListToUpdate.add(ocr);
                            }
                        }
                        else{
                            system.debug('tempOCRMap=== if null'+tempOCRMap);
                            OpportunityContactRole conRole = new OpportunityContactRole();
                            conRole.ContactId = oppC.PersonAccount__r.PersonContactId;
                            conRole.OpportunityId = oppC.Opportunity__c;
                            conRole.role = oppC.Role__c;
                            if(oppC.Primary__C == true){
                                conRole.IsPrimary = true;
                            }
                            optyConRoleListToInsert.add(conRole);
                        }
                    }

                }
            }
        }
        system.debug('optyConRoleListToInsert==='+optyConRoleListToInsert);
        system.debug('optyConRoleListToUpdate===='+optyConRoleListToUpdate);

        if(!optyConRoleListToInsert.isEmpty()){
           List<database.saveResult> saveResultsInsert =  Database.insert(optyConRoleListToInsert,false);
           system.debug('saveResultsInsert---'+saveResultsInsert);
        }
        if(!optyConRoleListToUpdate.isEmpty()){
            List<database.saveResult> saveResultsUpdate = Database.update(optyConRoleListToUpdate,false);
             system.debug('saveResultsUpdatet---'+saveResultsUpdate);
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}