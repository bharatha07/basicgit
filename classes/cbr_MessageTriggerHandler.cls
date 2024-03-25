public class cbr_MessageTriggerHandler {
    
    public static void publishEvent(List<Message__c> msgList){        
        List<CBR_Message_Event__e> platformEventList = new List<CBR_Message_Event__e>();
        
        for(Message__c msg : msgList ){            
            if( msg.Status__c == 'New' && msg.Direction__c == 'Outbound' && string.isNotBlank(msg.Event_Type__c) && msg.Event_Type__c !='Send Opportunity Stored ToAX Event' && msg.Event_Type__c !='QucikABO Enrolled Opty' ){               
                CBR_Message_Event__e msgEvent = new CBR_Message_Event__e();
                msgEvent.Direction__c = msg.Direction__c;
                msgEvent.EventData__c = msg.Payload__c;
                msgEvent.Message_Id__c = msg.Id;                
                msgEvent.EventType__c = msg.Event_Type__c;                                
                platformEventList.add(msgEvent);
            }            
            
        }                       
        if(!platformEventList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(platformEventList);
            system.debug('--------------platform Event---------'+results);    
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
                for (Database.SaveResult sr : results) {
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
                Database.insert(cbrErrorLog, false);
                system.debug('>>>>>>'+cbrErrorLog); 
        }
    }        
    
    
}