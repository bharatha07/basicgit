/************************************************************************************************************************************
* Component Name: lwc_OpportunityContactsController
* Created Date:
* CreatedBy: TEKsystems
* Desscription:
*************************************************************************************************************************************/
public class lwc_OpportunityContactsController {
    
    public class ResultantWrapper{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<String> lstOfMessages;
        @AuraEnabled
        public List<Integer> lstOfPositions;

        public ResultantWrapper(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }

        public ResultantWrapper(Boolean isSuccess, List<String> lstOfMessages, List<Integer> lstOfPositions){
            this.isSuccess = isSuccess;
            this.lstOfMessages = lstOfMessages;
            this.lstOfPositions = lstOfPositions;
        }
    }

    @AuraEnabled
    public static List<OpportunityContact__c> getOpportunityContacts(Id opportunityId){
        system.debug(OpportunityId);
        return [Select Id,Name,Opportunity__c,PersonAccount__c,PersonAccount__r.Name,Primary__c,Bill_To__c,Ship_To__c, Role__c 
               from OpportunityContact__c
               where Opportunity__c = :opportunityId];        
    }

    @AuraEnabled
    public static ResultantWrapper upsertOpportunityContacts(List<OpportunityContact__c> recordsToBeUpserted){
        system.debug('recordsToBeUpserted----'+recordsToBeUpserted);
        ResultantWrapper result;
        List<String> lstOfErrorMessages = new List<String>();
        List<Integer> lstOfErrorPositions = new List<Integer>();
        String error;
        /*system.debug(recordsToBeDeleted);
        for(OpportunityContact__c oppContact: recordsToBeUpserted){
            system.debug(oppContact.Primary__c);
            system.debug(oppContact.PersonAccount__c);
            system.debug(oppContact.PersonAccount__r.Name);
        }*/
                
        if(recordsToBeUpserted != NULL && !recordsToBeUpserted.isEmpty()){
            System.debug('>>>>>>>>>>>>>' + recordsToBeUpserted);
            Savepoint sp = Database.setSavepoint();
            List<Database.UpsertResult> urList = Database.upsert(recordsToBeUpserted, false);
            for(Integer i = 0; i < urList.size(); i++){
                error = '';
                if(!urList[i].isSuccess()){
                    lstOfErrorPositions.add(i);
                    for(Database.Error err : urList[i].getErrors()){
                        error = err.getMessage();
                    }
                    lstOfErrorMessages.add('Record ' + (i + 1) + ' has error : ' + error);
                }
            }
            if(lstOfErrorMessages.isEmpty() && lstOfErrorPositions.isEmpty()){
                result = new ResultantWrapper(true, 'Your operation was successfull');
            }
            else{
                result = new ResultantWrapper(false, lstOfErrorMessages, lstOfErrorPositions);
                Database.rollback(sp);
            }
        }
        else{
            result = new ResultantWrapper(false, 'Please provide the Opportunity Contact details for upsering them');
        }
        
        /*if(!recordsToBeDeleted.isEmpty()){
            List<Database.DeleteResult> drList = Database.delete(recordsToBeDeleted, false);
            for(Database.DeleteResult dr: drList){
                if(!dr.isSuccess()){
                    system.debug(dr.getErrors());
                }
            }
        }*/
        return result;
    }

    @AuraEnabled
    public static ResultantWrapper deleteOppContact(OpportunityContact__c opportunityContact){
        ResultantWrapper result;
        String error = '';
        if(opportunityContact != NULL){
            if(String.isNotBlank(opportunityContact.Id)){
                Database.DeleteResult dbResult = Database.delete(opportunityContact, false);
                if(dbResult.isSuccess()){
                    result = new ResultantWrapper(true, 'Your operation was successfull');
                }
                else{
                    for(Database.Error err : dbResult.getErrors()){
                        error = err.getMessage();
                    }
                    result = new ResultantWrapper(false, error);    
                }
            }
            else{
                result = new ResultantWrapper(true, 'Your operation was successfull');
            }
        }
        else{
            result = new ResultantWrapper(false, 'Please provide the Opportunity Contact details for deletion');
        }
        return result;
    }
}