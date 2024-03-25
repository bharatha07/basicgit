/*******************************************************************************************************************************************
* Component Name:batchToUpdateCBCTOnDeliveringFacilities
* Description: Batch to update CB/CT count on delivering facilities.
* Created By: TEKsystems(Tejaswini)
* Created Date: 
* User Story: SFDC - 21
************************************************************************************************************************************************/
global class batchToUpdateCBCTOnDeliveringFacilities implements Database.Batchable<sObject> {
    global String FACILITY = 'Facility';
      global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,of_CB_Collected__c,of_CT_Collected__c from Account where Recordtype.Name =: FACILITY AND Type__c  = \'Hospital\'';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        Set<Id> facilityIds = new Set<Id>();
        Map<Id,opportunity> oppMap = new Map<id,Opportunity>();
        Map<Id,opportunity> oppMapToUpdate = new Map<id,Opportunity>();
        List<Account> facilitiesToUpdate = new list<Account>();
        Map<Id,Set<id>> facilityToOppMap = new Map<Id,Set<Id>>();
        for(Account facility:scope){
            facilityIds.add(facility.id);
        }
        //query on opportunities whose delivering hospital is in scope
        if(facilityIds!=null && !facilityIds.isEmpty()){
            oppMap = new Map<Id,opportunity>([select id,Delivering_Hospital__c,Stored_CT__c,Stored_CB__c,CB_CT_CountUpdatedOnDeliveringHospital__c from opportunity where Delivering_Hospital__c IN:facilityIds AND Status__c = 'Stored' AND CB_CT_CountUpdatedOnDeliveringHospital__c= false]);
        }
        
        if(oppMap!=null && !oppMap.isEmpty()){
            for(Opportunity opp:oppMap.values()){
                if(facilityToOppMap.containsKey(opp.Delivering_Hospital__c)){
                    Set<Id> tempList = facilityToOppMap.get(opp.Delivering_Hospital__c);
                    tempList.add(opp.id);
                    facilityToOppMap.put(opp.Delivering_Hospital__c,tempList);
                }else{
                    facilityToOppMap.put(opp.Delivering_Hospital__c,new Set<id>{opp.id});
                }
            }
        }
        
        if(facilityToOppMap!=null && oppMap!=null){
            for(Account facility:scope){
                Integer cbCount = 0;
                Integer ctCount = 0;
                if(facilityToOppMap.containsKey(facility.id) && facilityToOppMap.get(facility.id)!=null){
                    for(Id oppId:facilityToOppMap.get(facility.id)){
                        Opportunity opp = oppMap.get(oppId);
                        if(opp.Stored_CB__c!=null && Integer.valueOf(opp.Stored_CB__c)>0){
                            cbCount += Integer.valueOf(opp.Stored_CB__c);
                            opp.CB_CT_CountUpdatedOnDeliveringHospital__c = true;
                            oppMapToUpdate.put(opp.id,opp);
                        }
                        if(opp.Stored_CT__c !=null && Integer.valueOf(opp.Stored_CT__c)>0){
                            ctCount += Integer.valueOf(opp.Stored_CT__c);
                            opp.CB_CT_CountUpdatedOnDeliveringHospital__c = true;
                            oppMapToUpdate.put(opp.id,opp);
                        }
                    }
                }
                if(facility.of_CB_Collected__c == null){
                    facility.of_CB_Collected__c =  cbCount;
                }else{
                    facility.of_CB_Collected__c +=  cbCount;
                }
                if(facility.of_CT_Collected__c == null){
                    facility.of_CT_Collected__c = ctCount;
                }else{
                    facility.of_CT_Collected__c += ctCount;
                }
                
                facilitiesToUpdate.add(facility);
            }
        }
         List<Database.SaveResult> facilitySaveResults = new List<Database.SaveResult>();
         set<id> failedFacilities = new Set<id>();
        if(facilitiesToUpdate!=null && !facilitiesToUpdate.isEmpty()){
            facilitySaveResults = Database.update(facilitiesToUpdate,false);
        }
        for (Database.SaveResult saveResult : facilitySaveResults) {
            if (!saveResult.isSuccess()) {
                failedFacilities.add(saveResult.getId());
                for(Database.Error e:saveResult.getErrors()){
                    system.debug('Error...'+e.getMessage());
                    
                }
            }
        }
        
        for(Account facility:scope){
            if(failedFacilities!=null && failedFacilities.contains(facility.id)){
                for(Opportunity opp:oppMapToUpdate.values()){
                    if(facilityToOppMap.get(facility.id).contains(opp.id)){
                        oppMapToUpdate.remove(opp.id); 
                    }
                }  
            }
        } 
        
        List<Database.SaveResult> oppSaveResults = Database.update(oppMapToUpdate.values(),false);
        
    }
     global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }   
}