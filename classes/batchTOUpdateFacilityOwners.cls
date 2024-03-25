/*******************************************************************************************************************************************
* Component Name:batchToUpdate Facility OwnerId
* Description: Batch to update OwnerIds of the facilities.
* Created By: Rajakumar Anbarasan
* Created Date: 11-19-2021
* User Story: SFDC - 2123
************************************************************************************************************************************************/

global class batchTOUpdateFacilityOwners implements database.batchable<sObject>{
  
  
    global Database.QueryLocator start(Database.BatchableContext bc) {
         String query = 'Select Id, BillingPostalCode, OwnerId from Account Where LastModifiedDate = Today AND RecordType.Name = \'Facility\'';
		 return database.getQueryLocator(query);
		 }
		 
    global void execute(Database.BatchableContext bc, List<Account> scope){
           Set<String> zipCodes = new Set<String>();
           Set<String> territoryName = new Set<String>();
		   List<Account> finalAccountList = new List<Account>();
		 //Map<String,US_Zipcode__c> uszipCodeMap = new Map<String,US_Zipcode__c>();
		 Map<String,String> uszipCodeMap = new Map<String,String>();
         Map<String,Id> territoryUserMap = new Map<String,Id>();
         for(Account facility:scope){
             zipCodes.add(facility.BillingPostalCode);
         }

		 if(zipCodes!=null && !zipCodes.isEmpty()){
         	for (US_Zipcode__c usZipcodes: [Select Name, Territoryname__c from US_Zipcode__c Where Name IN :zipCodes]){
				territoryName.add(usZipcodes.Territoryname__c);
                uszipCodeMap.put(usZipcodes.Name,usZipcodes.Territoryname__c);
			} 	 
		}
        if(territoryName!=null && !territoryName.isEmpty()){
		   for (User userObject: [Select Territory__c, Id  from User Where Territory__c IN :territoryName]){
		       territoryUserMap.put(userObject.Territory__c,userObject.Id);
		   }
		}
        for (account facilityIds:scope){
			if(uszipCodeMap.containsKey(facilityIds.BillingPostalCode)){
			  //String userTerr = uszipCodeMap.get(facilityIds.BillingPostalCode).Territoryname__c; 
			  String userTerr = uszipCodeMap.get(facilityIds.BillingPostalCode);
              if(territoryUserMap.containsKey(userTerr)){
			     //facilityIds.OwnerId = territoryUserMap.get(userTerr).Id;
			     facilityIds.OwnerId = territoryUserMap.get(userTerr);
				 finalAccountList.add(facilityIds);
              }			  
			}
		}
		List<Database.SaveResult> facilityUpdateSaveResults = Database.update(finalAccountList,false);
		for (Database.SaveResult saveResult : facilityUpdateSaveResults){
		    if (!saveResult.isSuccess()) {
                //failedProviders.add(saveResult.getId());
                for(Database.Error e:saveResult.getErrors()){
                    system.debug('Error...'+e.getMessage());
                    
                }
            }
        }	
		
	
    }
    global void finish(Database.BatchableContext bc){
	}
}