/**********************************************************************************************************************************************
*Component Name: MessageUtilityClass
*Created Date : 25-AUG-2021 (Teksystems)
*Description : Utility class for publishing the platform Event Using Message Object.
*Created By : TekSystems
***Version          UserStory           Date            ModifiedBy          Description
1.0                 SFDC-1416           25-AUG-2021     AmeenShaik             Utility class for publishing the platform Event Using Message Object.

**************************************************************************************************************************************************/
public class MessageUtilityClass {
    
    
    /* @description -  Method to insert the Message Object and there by publishing the Platform Event using Message Trigger.
* @param - Wrapper Class Object
* @story - SFDC-1416
* @return Void
* @date - 11-AUG-2021 (Teksystems)
*/
        public static void getPlatformMessage(list<wrapper>  wrap){
        list<Message__c> msgList = new list<Message__c>();
        set<string> allEventType= new  set<string>();
        List<string> allEventTypelst= new  List<string>();
        //map<id,String> eventType= new map<id,String>();
        for(wrapper wrp : wrap){
            Message__c msgRec=new Message__c();
            msgRec.Event_Type__c=wrp.EventType;
            msgRec.Payload__c=wrp.Payload;
            msgRec.status__c = wrp.status;
            msgRec.Direction__c =wrp.Direction ; 
            msgList.add(msgRec);
            allEventType.add(wrp.EventType);
        }
        //logic to Track eventtype
        allEventTypelst.addAll(allEventType);
        string eventType=String.join(allEventTypelst, ',');
        
        if(!msgList.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert(msgList,false);
            system.debug('messageList ::'+msgList);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published Platform Event:'+sr.getId());
                    
                } else {
                    string ErrDetail='Error returned for'+eventType;
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    if(string.isNotBlank(ErrDetail)){
                        system.debug('erromessgae'+ErrDetail);
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(null, eventType, 'Apex Event', ErrDetail, false, false);
                        cbrErrorLog.add(cbr);
                        system.debug('cbrutilityList'+cbrErrorLog);
                    }
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
            
        }   
    }
    public class wrapper{
        public string EventType;
        public string Payload;
        public string status;
        public string Direction;
    }
    
}