/**********************************************************************************************************************************************
*Component Name: sendBillToPlatformEvents
*Created Date : 30-DEC-2020 (Teksystems)
*Description : Class is created to delay platform event creation when bill to is updated 
*Created By : TekSystems
***Version          UserStory           Date            ModifiedBy          Description
1.0                           30-DEC-2020     Tejaswini            Publish platform event when bill to is updated
**************************************************************************************************************************************************/
public class sendBillToPlatformEvents{
    @InvocableMethod(label='bill To Change' description='Create message records to send AX platform events on bill to change' category='OpportunityContact__c')
    public static void billToChange(List<Id> optyConIds){
        List<Message__c> messageList = new List<Message__c>();
        Map<Id,OpportunityContact__c> oppconMap = new Map<Id,OpportunityContact__c>();
        if(!optyConIds.isEmpty()){
            oppconMap = new Map<Id,OpportunityContact__c>([select id,personAccount__c ,opportunity__c from opportunityContact__c where Id IN:optyConIds and Opportunity__r.AX_Order_Id__c!=null]);            
        }
        if(!oppconMap.isEmpty()){
            for(opportunityContact__c oppC:oppconMap.values()){
                Message__c msgRec = new Message__c();
                PlatformEventWrapper.AXOpportunityPrimaryEvent accWrp=new PlatformEventWrapper.AXOpportunityPrimaryEvent();
                msgRec.Event_Type__c='Opportunity Contact BillTo Update';
                accWrp.AxContactId=oppC.PersonAccount__c;
                accWrp.AxOpportunityId=oppC.Opportunity__C;
                    msgRec.Payload__c=JSON.serialize(accWrp);
                    msgRec.status__c = 'New';
                    msgRec.Direction__c = 'outbound';
                   messageList.add(msgRec); 
            }
        }
        if(messageList!=null && !messageList.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(messageList,false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for Fac contact created.1235');
                    recursiveClass.facConPfevent= true;
                } else {
                     string ErrDetail='Error returned for Fac contact created.1235';
                      for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';      
                     }
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Facility Kit Update Event', 'Apex Event', ErrDetail, false, false);
                    system.debug('cbrutility'+cbr);
                    cbrErrorLog.add(cbr);
                    system.debug('cbrutilityList'+cbrErrorLog);
                    
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
        }
        
    }
}