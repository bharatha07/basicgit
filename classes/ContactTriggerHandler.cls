/**********************************************************************************************************************************************
*Component Name: ConPayPrflTriggerHandler
*Created Date : 06-OCT-2020 (Teksystems)
*Description : Class is created to handle Fac contact creation on contact object.
*Created By : TekSystems
***Version          UserStory           Date            ModifiedBy          Description
1.0                 SFDC-1235           06-OCT-2020     Jitendra            Publish platform event for new Fac contact creation
**************************************************************************************************************************************************/
public class ContactTriggerHandler {
/*************************************************************************************************
     * @description This method is used to publish platform event for new contcat payement profile creation
     * @param - Trigger map
     * @story - SFDC-1235
     * @return Void
     * @date - 06-OCT-2020 (Teksystems)
     */
    public static void newFacConPFevent(Map<Id,Contact> newMap){
        if(!recursiveClass.facConPfevent){
            String facilityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
            set<id> accids=new set<id>();
           List<Message__c> messageList = new List<Message__c>();
            List<OpportunityContact__c> oppConList = new List<OpportunityContact__c>();
            List<Account> accList = new List<Account>();
            for(Contact conVar:newMap.values()){
                accids.add(conVar.AccountId );
            }
            if(!accIds.isEmpty()){
                accList= [select id,Kit_Stocking__c,RecordTypeId from Account where id IN :accids AND Kit_Stocking__c=true  and RecordTypeId=:facilityRecordTypeId ];
            }
            if(!accList.isEmpty()){
                for(Account accVar:accList){
                    PlatformEventWrapper.FacilityKitUpdateEvent facWrp=new PlatformEventWrapper.FacilityKitUpdateEvent();
                   Message__c msgRec=new Message__c();
                    msgRec.Event_Type__c='Facility Kit Update Event';
                    facWrp.FacilityId=accVar.id;
                    msgRec.Payload__c=JSON.serialize(facWrp);
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
   
}