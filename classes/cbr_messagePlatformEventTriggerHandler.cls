public class cbr_messagePlatformEventTriggerHandler {
    public static void evaluateEvents(List<CBR_Message_Event__e> evntList){
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();

            List<Message__c> existingMessages = new List<Message__c>();
            List<Message__c> msgsToUpdate = new List<Message__c>();
            
            Set<Id> setMessageIds = new Set<Id>();
            for(CBR_Message_Event__e evnt: evntList){
                if(evnt.Message_Id__c!=null){
                    setMessageIds.add(evnt.Message_Id__c);
                }
            }
            
            existingMessages = [select Id, Status__c, Event_Type__c, Direction__c, Payload__c from Message__c where id in :setMessageIds];                        
            
            if(existingMessages.size()>0){
                system.debug('---------Existing Messages---------------'+existingMessages);
                for(Message__c msg: existingMessages){                    
                    if(msg.Direction__c == 'Outbound' && msg.Status__c == 'New'){
                        msg.Status__c = 'Published'; //Updating the status once the event is published.
                        msgsToUpdate.add(msg);
                    }
                }
            }
            
            if(!msgsToUpdate.isEmpty()){
                List<Database.SaveResult> saveResults = database.update(msgsToUpdate, false);                
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully Updated Message Status');                    
                        
                    } else {
                        string ErrDetail='Error Updating Message Status';
                        for(Database.Error err : sr.getErrors()) {
                            ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                        }
                        
                        system.debug('erromessgae'+ErrDetail);
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Message Status', 'Apex Event', ErrDetail, false, false);                       
                        cbrErrorLog.add(cbr);                                                
                    }       
                }
                
            }
            
        
        if(!cbrErrorLog.isEmpty())
            Database.insert(cbrErrorLog, false);
        system.debug('>>>>>>'+cbrErrorLog);
    }
}