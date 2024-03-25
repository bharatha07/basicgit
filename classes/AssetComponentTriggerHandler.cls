/**********************************************************************************************************************************************
*Component Name: AssetComponentTriggerHandler
*Created Date : 25-AUG-2021 (Teksystems)
*Description : Handler class for AssetComponent Trigger.
*Created By : TekSystems
***Version          UserStory           Date            ModifiedBy          Description
1.0                 SFDC-1938           25-AUG-2021     Bharath Avaldar     Handler class for AssetComponent Trigger

**************************************************************************************************************************************************/

public class AssetComponentTriggerHandler {
    
    /* @description -  Method to publish the Platform Event when AssetComponet Status is set to RELEASED.
* @param - trigger newMap,oldMap
* @story -  SFDC-1938 
* @return Void
* @date - 25-AUG-2021 (Teksystems)*/
    
    public static void assetReleasePlatformEvent(Map<id,Asset_Component__c> newMap,Map<id,Asset_Component__c> oldMap){
        set<id> astCmpIds= new set<id>();
        list<MessageUtilityClass.wrapper> wrpaList = new list<MessageUtilityClass.wrapper>();
        List<Message__c> messageList = new List<Message__c>();
        for(Asset_Component__c eachAstCmp:newMap.values()){
            if(eachAstCmp.Component_Status__c!=null && eachAstCmp.Component_Status__c!=oldMap.get(eachAstCmp.id).Component_Status__c  && eachAstCmp.Component_Status__c=='Released' && (eachAstCmp.Component_Type__c=='Major Component' || eachAstCmp.Component_Type__c=='Minor Component' ||eachAstCmp.Component_Type__c=='Segment')){
                astCmpIds.add(eachAstCmp.id);
            }
        }
        if(!astCmpIds.isEmpty()){
            for(Id eachId:astCmpIds){
                Message__c msgRec = new Message__c();
                PlatformEventWrapper.sendAssetComponentID accWrp=new PlatformEventWrapper.sendAssetComponentID();
                MessageUtilityClass.wrapper wrap= new MessageUtilityClass.wrapper();
                wrap.EventType='Asset Component Status Update';
                accWrp.id=eachId;
                wrap.Payload=JSON.serialize(accWrp);
                wrap.status ='New';
                wrap.Direction ='outbound';
                wrpaList.add(wrap);
            }
        }
        if(!wrpaList.isEmpty()){
            MessageUtilityClass.getPlatformMessage(wrpaList);  
        }
        
    }
}