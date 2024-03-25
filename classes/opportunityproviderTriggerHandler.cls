/******************************************************************************************************************************
*Component Name: opportunityproviderTriggerHandler
*Created Date : 1-MAR-2021
*Description : Trigger logic for opportunityproviderTrigger events
*Created By : Teksystem
*******************************************************************************************************************************/
public class opportunityproviderTriggerHandler {
    
    public static void checkoppyProviders(Map<Id,Opportunity_Provider__c> newMap, Map<Id,Opportunity_Provider__c> oldMap){
        system.debug('inside handler');
        //Set<id> finalopyproviders= new Set<id>();
        system.debug('the newmap ---->'+newMap);
        system.debug('the oldmap ---->'+oldMap);
        set<Id> newSet = new set<Id>(); 
        set<Id> oldSet = new set<Id>();
        map<Id, Account> newproviderIDMap = new map<Id, Account>();
        map<Id, Account> oldproviderIDMap = new map<Id, Account>();
        Map<id,Opportunity_Provider__c> finalopyproviders = new Map<id,Opportunity_Provider__c>();
        
        if(!recursiveClass.optyProviderPayable){
            for(Opportunity_Provider__c eachoppyprvd:newMap.values()){
                if(eachoppyprvd.Delivering_Provider__c && eachoppyprvd.Opportunity_Program_Enrolled_In__c!=null && !eachoppyprvd.Opportunity_Program_Enrolled_In__c.contains('Newborn Possibilities Program') && (Trigger.operationType ==TriggerOperation.AFTER_INSERT || (!oldMap.isEmpty() && (eachoppyprvd.Delivering_Provider__c!= oldMap.get(eachoppyprvd.id).Delivering_Provider__c || eachoppyprvd.provider__c!= oldMap.get(eachoppyprvd.id).provider__c)))){
                    system.debug('inside handler if con');
                    //After Insert
                    if(Trigger.operationType ==TriggerOperation.AFTER_INSERT){
                        finalopyproviders.put(eachoppyprvd.id,eachoppyprvd);
                    }
                    newSet.add(eachoppyprvd.Provider__c);
                }
            }
            // After update logic
            if(Trigger.operationType ==TriggerOperation.AFTER_UPDATE){
                if(!oldMap.isEmpty()){
                    for(Opportunity_Provider__c op:oldMap.values())
                    {
                        oldSet.add(op.Provider__c);
                    } 
                }
                
                if(!newSet.isEmpty() && !oldSet.isEmpty()){
                    newproviderIDMap= new map<Id, Account>([select id,name,HPN_Flag__c from account where Recordtype.name='Provider' and ID =:newSet AND Name!='Available No Provider']);
                    oldproviderIDMap= new map<Id, Account>([select id,name,HPN_Flag__c from account where Recordtype.name='Provider' and ID =:oldSet]);
                    for(Opportunity_Provider__c eachoppyprvd:newMap.values()){
                        if((eachoppyprvd.Delivering_Provider__c!= oldMap.get(eachoppyprvd.id).Delivering_Provider__c && eachoppyprvd.Delivering_Provider__c)||(!newproviderIDMap.isEmpty() && newproviderIDMap.get(eachoppyprvd.Provider__c).HPN_Flag__c && ( (oldproviderIDMap==null && String.isBlank(oldMap.get(eachoppyprvd.id).Provider__c) && String.isNotBlank(eachoppyprvd.Provider__c)) || (oldproviderIDMap!=null && newproviderIDMap.get(eachoppyprvd.Provider__c).id!=oldproviderIDMap.get(oldMap.get(eachoppyprvd.id).Provider__c).id ))  )){
                            finalopyproviders.put(eachoppyprvd.id,eachoppyprvd);
                        }  
                    }
                    system.debug('the final--->'+finalopyproviders);
                }
            }
            if(!finalopyproviders.isEmpty()){
                string finalopyprvd= json.serialize(finalopyproviders.values());
                if(String.isNotEmpty(finalopyprvd)){
                    system.debug('calling future');
                    createPayablesFromFuture.createPayables(finalopyprvd);
                    recursiveClass.optyProviderPayable=true;
                }
            }
            
        }
    }
    //  sfdc-1519 and sfdc-1520
    public static void primaryProviderRelatedoptyCount(Map<Id,Opportunity_Provider__c> newMap,Map<Id,Opportunity_Provider__c> oldMap) {
        set<id> accid=new set<id>();
        map<id,Account> mapAcc=new map<id,Account>();
        //list<string> oppstatus=new list<string>{'Enrolled','Open'};
        for(Opportunity_Provider__c opprovider:newmap.values()){
            if(Trigger.isInsert &&(opprovider.Opportunity_Status__c=='Open' || opprovider.Enrollment_Date__c != null) && opprovider.Primary_Provider__c)
            {
                accid.add(opprovider.Provider__c);  
            }  
            else if(trigger.isUpdate && oldMap.get(opprovider.id).Provider__c != Null 
                    &&((opprovider.Provider__c != oldMap.get(opprovider.id).Provider__c) || (opprovider.Primary_Provider__c != oldMap.get(opprovider.id).Primary_Provider__c))){
                        accid.add(oldMap.get(opprovider.id).Provider__c);
                        accid.add(opprovider.Provider__c);
                    }
        }
        if(accid!=null && !accid.isEmpty() && !system.isBatch()){
            UpdateOptyCountOnPrimaryProvider.UpdateOptyCountOnPrimaryProviderMethod(accid,false);
        }
        
    }
    //As paert of SFDC-2134 send Fax Email
    public static void sendFaxEmail(Map<Id,Opportunity_Provider__c> newMap){
        set<id> optyIds=new set<id>();
        String invoke=system.label.SendFaxEmail;
        for(Opportunity_Provider__c eachOP:newmap.values()){
            if(test.isRunningTest() ||invoke=='True'){
                if(eachOP.Opportunity__c!=null && eachOP.Provider__c!=null && eachOP.Provider_Facility__c!=null && eachOP.Primary_Provider__c==true){
                    optyIds.add(eachOP.Opportunity__c);
                }
            }
        }
        if(!optyIds.isEmpty() && !recursiveClass.optyProviderSendFaxEmail){
            Map<id,opportunity> opts= new  Map<id,opportunity>([select id,name,Status__c from Opportunity where Status__c='Enrolled' and ID =:optyIds]);
            system.debug('the results are-->'+opts);
            if(!opts.isEmpty()){
                OpportunitySendFaxEmail.sendEmail(opts);
                recursiveClass.optyProviderSendFaxEmail=true;
            }
        }
    }
}