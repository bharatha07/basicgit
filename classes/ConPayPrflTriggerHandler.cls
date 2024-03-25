/**********************************************************************************************************************************************
*Component Name: ConPayPrflTriggerHandler
*Created Date : 05-OCT-2020 (Teksystems)
*Description : Class is created to handle varioud DML on contact payment profile object.
*Created By : TekSystems
***Version          UserStory           Date            ModifiedBy          Description
1.0                 SFDC-1200           05-OCT-2020     Jitendra            Publish platform event for new contcat payement profile creation

**************************************************************************************************************************************************/
public class ConPayPrflTriggerHandler {
    
    /*************************************************************************************************
* @description This method is used to publish platform event for new contcat payement profile creation
* @param - Trigger map
* @story - SFDC-1200
* @return Void
* @date - 05-OCT-2020 (Teksystems)
*/
    public static void newPayPrflPFevent(Map<Id,Contact_Payment_Profile__c> newMap){
        if(!recursiveClass.optyConPfevent){
            String consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            set<id> accids=new set<id>();
            list<MessageUtilityClass.wrapper> wrpaList = new list<MessageUtilityClass.wrapper>();
            List<Message__c> messageList = new List<Message__c>();
            List<OpportunityContact__c> oppConList = new List<OpportunityContact__c>();
            List<Account> accList = new List<Account>();
            for(Contact_Payment_Profile__c conPay:newMap.values()){
                if(userInfo.getFirstName()!='MulesoftUser'){
                    accids.add(conPay.Account__c );
                }
            }
            if(!accIds.isEmpty()){
                accList= [select id,AX_Customer_Id__pc,RecordTypeId,(select id,PersonAccount__c,Primary__c, Bill_To__c from Account_Opportunities__r where Primary__c=true or Bill_To__c =true)from Account where id IN :accIds AND AX_Customer_Id__pc!=null and RecordTypeId=:consumerRecordTypeId ];
            }
            if(!accList.isEmpty()){
                for(Account accVar:accList){
                    if(accVar.Account_Opportunities__r.size()>0){
                        PlatformEventWrapper.AxCustomerUpdateEvent accWrp=new PlatformEventWrapper.AxCustomerUpdateEvent();
                        MessageUtilityClass.wrapper wrap= new MessageUtilityClass.wrapper();
                        wrap.EventType='Ax Customer Update Event';
                        accWrp.AxConsumerId=accVar.id;
                        wrap.Payload=JSON.serialize(accWrp);
                        wrap.status='New';
                        wrap.Direction='outbound';
                        wrpaList.add(wrap);  
                    }  
                }
            }
            if(!wrpaList.isEmpty()){
                MessageUtilityClass.getPlatformMessage(wrpaList);
                
                /*if(!lstMsg.isEmpty()){
List<Database.SaveResult> saveResults = Database.insert(lstMsg,false);
string ErrDetail;
List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
for (Database.SaveResult sr : saveResults) {
if (sr.isSuccess()) {
System.debug('Successfully published event for conPayPrfl created.1200');

} else {
ErrDetail+='Error returned for for conPayPrfl created:1200';
for(Database.Error err : sr.getErrors()) {
ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
}  
}       
}
if(string.isNotBlank(ErrDetail)){
system.debug('erromessgae'+ErrDetail);
cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Ax Customer Update Event', 'Apex Event', ErrDetail, false, false);
system.debug('cbrutility'+cbr);
cbrErrorLog.add(cbr);
system.debug('cbrutilityList'+cbrErrorLog); 
}
if(!cbrErrorLog.isEmpty()){
Database.insert(cbrErrorLog, false);
system.debug('>>>>>>'+cbrErrorLog); 
}
}*/
            }
            recursiveClass.axCus2Pfevent = true;
        }
    }
}