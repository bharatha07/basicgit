public class sendStoredOptys{
    @InvocableMethod(label = 'send Stored opty' description='Create platform events for stored optys' category = 'Message__c')
    public static void sendStoredOpty(List<msgInfo> msgInfoList){
        List<CBR_Message_Event__e> platformEventList = new List<CBR_Message_Event__e>();
        
        for(msgInfo msg:msgInfoList){
            CBR_Message_Event__e msgEvent = new CBR_Message_Event__e();
                msgEvent.Direction__c = 'Outbound';
                msgEvent.EventData__c = msg.payload;
                msgEvent.Message_Id__c = msg.msgId;                
                msgEvent.EventType__c = msg.msgEventType;                                
                platformEventList.add(msgEvent);
        }
         if(!platformEventList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(platformEventList);
            system.debug('--------------platform Event---------'+results);    
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully Updated Message Status');                    
                        
                    } /*else {
                        string ErrDetail='Error Updating Message Status';
                        for(Database.Error err : sr.getErrors()) {
                            ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                        }
                        
                        system.debug('erromessgae'+ErrDetail);
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Message Status', 'Apex Event', ErrDetail, false, false);                       
                        cbrErrorLog.add(cbr);                                                
                    }  */     
                }
                Database.insert(cbrErrorLog, false);
                system.debug('>>>>>>'+cbrErrorLog); 
        }
    }
    public class msgInfo{
        @InvocableVariable
        public String msgEventType;
        
        @InvocableVariable
        public String payload;
        
        @InvocableVariable
        public String msgId;
        
        
    }
    }