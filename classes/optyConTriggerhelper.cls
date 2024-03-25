/**
* @File Name          : optyConTriggerhelper.cls
* @Description        : 
* @Author             : Tejaswini
* @Created On          : 6/29/2020
**/
public class optyConTriggerhelper {
    public static void afterInsert(Map<id,OpportunityContact__c> newMap){
        afterOptyConInsert(newMap.values());
        sendAboEvent(newMap,null);
        if(UserInfo.getName() == 'MulesoftUser MulesoftUser'){
        updateOppConsToNonPrimary(newMap,null);
        }
    }
    public static void afterUpdate(Map<Id,OpportunityContact__c> newMap,Map<Id,OpportunityContact__c> oldMap){
        axOptyConPriUpdateEvt(newMap,oldMap); 
        optyConBilltoUpdateEvt(newMap,oldMap);
        if(recursiveClass.oppPrimaryChangeABO == false){
            sendAboEvent(newMap,oldMap);}
        if(UserInfo.getName() == 'MulesoftUser MulesoftUser'){
        updateOppConsToNonPrimary(newMap,oldMap);
        }
    }
    public static void beforeInsert(List<OpportunityContact__c> newTrigger){
        duplicateAccountCheck(newTrigger);
        personAccountNameUpdate(newTrigger);
    }
    public static void beforeUpdate(Map<id,OpportunityContact__c> newMap,Map<id,OpportunityContact__c> oldMap){
        beforeUpdateTimeMap(newMap,oldMap);
    }
    public static void afterOptyConInsert(List<OpportunityContact__C> newTrigger){
        Set<id> oppIds = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>(); 
        Map<Id,String> oppSourceCodeMap = new Map<Id,String>();
        List<CampaignInfluence> campInfToInsert = new List<CampaignInfluence>();
        for(OpportunityContact__c oppCon:newTrigger){
            System.debug('For loop');
            if(oppCon.primary__C){
                oppIds.add(oppCon.Opportunity__c);
            }
        }
        if(!oppIds.isEmpty()){
            System.debug('oppIds==='+oppIds);
            if(recursiveClass.createCampaignInfluence){
                oppMap = new Map<Id,Opportunity>([Select id,AccountId,Lead_RecordType_Name__c,Account.PersonContactId,OnLeadConvertion__c,Opty_Source_Code__c from Opportunity where id IN:oppIds]);
            }
            else{
                oppMap = new Map<Id,Opportunity>([Select id,AccountId,Lead_RecordType_Name__c,Account.PersonContactId,OnLeadConvertion__c,Opty_Source_Code__c from Opportunity where id IN:oppIds AND OnLeadConvertion__c = true AND Lead_RecordType_Name__c ='NonMQL']);
            }
            System.debug('oppMap==='+oppMap);
        }
        if(!oppMap.isEmpty()){
            System.debug('Opp map===');
            List<Campaign> campgainRecords = new List<Campaign>();
            Map<String,Campaign> CampaignMap = new Map<String,Campaign>();
            for(Opportunity opp:oppMap.values()){
                System.debug('opp.Opty_Source_Code__c---'+opp.Opty_Source_Code__c);
                oppSourceCodeMap.put(opp.id,opp.Opty_Source_Code__c);
            }
            System.debug('oppSourceCodeMap==='+oppSourceCodeMap);
            if (!oppSourceCodeMap.isEmpty()) {
                campgainRecords = [select id,Campaign_Code__c from Campaign where Campaign_Code__c IN:oppSourceCodeMap.values()];
            }
            System.debug('campgainRecords===='+campgainRecords);
            for(Campaign c:campgainRecords){
                CampaignMap.put(c.Campaign_Code__c,c);
            }
            System.debug('CampaignMap---'+CampaignMap);
            if(!CampaignMap.isEmpty()){
                for(Opportunity opp:oppMap.values()){
                    if(String.isNotBlank(opp.Opty_Source_Code__c) &&CampaignMap.containsKey(opp.Opty_Source_Code__c)&& CampaignMap.get(opp.Opty_Source_Code__c)!=null){
                        campaignInfluence ci = new campaignInfluence();
                        ci.ContactId = opp.Account.PersonContactId;
                        ci.OpportunityId = opp.id;
                        ci.CampaignId = CampaignMap.get(opp.Opty_Source_Code__c).Id;
                        ci.Modelid =Label.Campaign_Model_Id;
                        campInfToInsert.add(ci);
                    } 
                }
            }
            System.debug('campInfToInsert==='+campInfToInsert);
        }
        if(!campInfToInsert.isEmpty()){
            System.debug('campInfToInsert insert');
            recursiveClass.conUpdateFromCI = true;
            List<Database.SaveResult> saveResults = Database.insert(campInfToInsert,false);
            System.debug('saveResults==='+saveResults);
        }
        
    }
    //SFDC - 2158. Update opp cons to non primary if multiple new primary con is present
    public static void updateOppConsToNonPrimary(Map<Id,OpportunityContact__c> newMap,Map<Id,OpportunityContact__c> oldMap){
        Set<Id> opConIds = new Set<Id>();
        Set<Id> primaryOppIds = new Set<Id>();
        Set<Id> billToOppIds = new Set<Id>();
        Set<Id> shipToOppIds = new Set<Id>();
        Map<Id,OpportunityContact__c> oppCons = new Map<Id,OpportunityContact__c>();
        for(OpportunityContact__c oppCon:newMap.values()){
            if(oppCon.Primary__c){
                if(oldMap!=null && !oldMap.isEmpty()){
                    if(oppCon.Primary__c != oldMap.get(oppCon.id).Primary__c){
                        opConIds.add(oppCon.Id);
                        primaryOppIds.add(oppCon.Opportunity__c);
                    }
                   
                }
                else{
                    opConIds.add(oppCon.Id);
                    primaryOppIds.add(oppCon.Opportunity__c);
                }
            }
            if(oppCon.Bill_To__c){
                if(oldMap!=null && !oldMap.isEmpty()){
                    if(oppCon.Bill_To__c != oldMap.get(oppCon.id).Bill_To__c){
                        opConIds.add(oppCon.Id);
                        billToOppIds.add(oppCon.Opportunity__c);
                    }
                   
                }
                else{
                    opConIds.add(oppCon.Id);
                    billToOppIds.add(oppCon.Opportunity__c);
                }
            }
            if(oppCon.Ship_To__c){
                if(oldMap!=null && !oldMap.isEmpty()){
                    if(oppCon.Ship_To__c != oldMap.get(oppCon.id).Ship_To__c){
                        opConIds.add(oppCon.Id);
                        shipToOppIds.add(oppCon.Opportunity__c);
                    }
                   
                }
                else{
                    opConIds.add(oppCon.Id);
                    shipToOppIds.add(oppCon.Opportunity__c);
                }
            }
        }
        if(primaryOppIds!=null && !primaryOppIds.isEmpty()){
            oppCons = new Map<Id,OpportunityContact__c>([select id,Primary__c,Opportunity__c,Ship_To__c,Bill_To__c from opportunitycontact__c where Id NOt IN:opConIds AND (Opportunity__c IN:primaryOppIds OR Opportunity__c IN:billToOppIds OR Opportunity__c IN:shipToOppIds) and (primary__c = true OR Ship_To__c = true OR Bill_To__c = true )]);
        }
        if(oppCons!=null && !oppCons.isEmpty()){
            for(OpportunityContact__c oppCon:oppCons.values()){
                if(shipToOppIds!=null && !shipToOppIds.isEmpty() &&  shipToOppIds.contains(oppCon.Opportunity__c)){
                    oppCon.Ship_To__c = false;
                }
                if(billToOppIds!=null && !billToOppIds.isEmpty() &&  billToOppIds.contains(oppCon.Opportunity__c)){
                    oppCon.Bill_To__c = false;
                }
                if(primaryOppIds!=null && !primaryOppIds.isEmpty() &&  primaryOppIds.contains(oppCon.Opportunity__c)){
                    oppCon.Primary__c = false;
                }
            }
            database.update(oppCons.values(),false);
        }
    }
    
    /*************************************************************************************************
* @description This method is used to publish platform event(AX) for primary flag on opty contact
* @param - Trigger map
* @story - SFDC-1165
* @return Void
* @date - 25-Sep-2020 (Teksystems)
*/
    public static void axOptyConPriUpdateEvt(Map<Id,OpportunityContact__C> newMap, Map<Id,OpportunityContact__C> oldMap){
        List<Message__c> messageList = new List<Message__c>();
        Set<Id> oppIds = new Set<Id>();
        //List<OpportunityContact__C> billToChangeList = new List<OpportunityContact__C>();
        for(Opportunitycontact__c acc:newMap.values()){
            if((acc.Primary__c && acc.Primary__c <> oldMap.get(acc.Id).Primary__c) || (acc.Bill_To__c && acc.Bill_To__c <> oldMap.get(acc.Id).Bill_To__c)){
                oppIds.add(acc.opportunity__c);
            }
        }
        Map<Id,Opportunity> oppMap = new Map<Id,opportunity>();
        if(oppIds!=null){
            oppMap = new Map<Id,opportunity>([select id,AX_Order_Id__c from opportunity where AX_Order_Id__c!=null AND Id IN:oppIds]); 
        }
        for(OpportunityContact__C acc:newMap.values()){
            if((acc.Primary__c && acc.Primary__c <> oldMap.get(acc.Id).Primary__c)&& oppMap!=null && oppMap.containsKey(acc.Opportunity__c)){
                
                // if(acc.Primary__c && acc.Primary__c <> oldMap.get(acc.Id).Primary__c){
                PlatformEventWrapper.AXOpportunityPrimaryEvent accWrp=new PlatformEventWrapper.AXOpportunityPrimaryEvent();
                Message__c msgRec = new Message__c();
                msgRec.Event_Type__c='AX Opportunity Primary Event';
                accWrp.AxContactId=acc.PersonAccount__c;
                accWrp.AxOpportunityId=acc.Opportunity__C;
                msgRec.Payload__c=JSON.serialize(accWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'Outbound';
                messageList.add(msgRec); 
                // }
            }
        }
        
        if(!messageList.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert(messageList,false);
            system.debug('punlish list ::'+messageList);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for Ax.1165');
                    
                } else {
                    string ErrDetail='Error returned for AX Update: 1165';
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'AX Opportunity Primary Event', 'Apex Event', ErrDetail, false, false);
                    system.debug('cbrutility'+cbr);
                    cbrErrorLog.add(cbr);
                    system.debug('cbrutilityList'+cbrErrorLog);
                    
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
            
        }
        
        
    } 
    /*************************************************************************************************
* @description This method is used to publish platform event for primary or bill to flag on opty contact
* @param - Trigger map
* @story - SFDC-1196 and 1236
* @return Void
* @date - 25-Sep-2020 (Teksystems)
* @modified date - 08-Oct-2020 (Teksystems)- Added opty id in event parameter ,
* @this method was moved from process builder(Opportunity Contact Role Update,V4) to apex method.
*/
    public static void optyConBilltoUpdateEvt(Map<Id,OpportunityContact__C> newMap, Map<Id,OpportunityContact__C> oldMap){
        if(!recursiveClass.optyConPfevent){
            List<Opportunity_Contact_BillTo_Update__e> billtoUpdateEventList = new List<Opportunity_Contact_BillTo_Update__e>();
            List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
            Set<Id> opconIds =newMap.keySet();
            Map<Id,OpportunityContact__c> opConMap = new Map<Id,OpportunityContact__c>(); 
            if(!opconIds.isEmpty()){
                opConMap =new Map<Id,OpportunityContact__c>([Select id,Primary__c,Bill_To__c,PersonAccount__C,Opportunity__c from OpportunityContact__c where id IN:opconIds AND (Opportunity__r.Status__C IN ('Enrolled', 'Stored', 'Pending')) AND opportunity__r.AX_Order_Id__c=null ]);
            }
            for(OpportunityContact__C optyCon:opConMap.values()){
                if((optyCon.Primary__c && optyCon.Primary__c <> oldMap.get(optyCon.Id).Primary__c) || (optyCon.Bill_To__c && optyCon.Bill_To__c <> oldMap.get(optyCon.Id).Bill_To__c)){
                    PlatformEventWrapper.OpportunityContactBillToUpdate optyConWrp=new PlatformEventWrapper.OpportunityContactBillToUpdate();
                    CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
                    cbrEvt.EventType__c='Opportunity Contact BillTo Update';
                    optyConWrp.AccountID=optyCon.PersonAccount__c;
                    optyConWrp.OpportunityID=optyCon.Opportunity__C;
                    cbrEvt.EventData__c=JSON.serialize(optyConWrp);
                    cbrEvtList.add(cbrEvt); 
                    
                }
            }
            if(!cbrEvtList.isEmpty()){
                List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
                system.debug('punlish list ::'+cbrEvtList);
                List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event for opty con-Primary or bill to.1196 and 1236');
                        
                    } else {
                        string ErrDetail='Error returned for opty con-Primary or bill to.1196 and 1236';
                        for(Database.Error err : sr.getErrors()) {
                            ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                        }
                        
                        system.debug('erromessgae'+ErrDetail);
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Opportunity Contact BillTo Update', 'Apex Event', ErrDetail, false, false);
                        system.debug('cbrutility'+cbr);
                        cbrErrorLog.add(cbr);
                        system.debug('cbrutilityList'+cbrErrorLog);
                        
                    }       
                }
                Database.insert(cbrErrorLog, false);
                system.debug('>>>>>>'+cbrErrorLog);    
            }
            recursiveClass.optyConPfevent = true;
        }  
    } 
    public static void beforeUpdateTimeMap(Map<id,opportunitycontact__c> newMap, Map<id,opportunitycontact__c> oldMap){
        for(OpportunityContact__C acc:newMap.values()){
            if(acc.Bill_To__c  && acc.Bill_To__c <> oldMap.get(acc.Id).Bill_To__c){
                acc.timeToPublish__c = system.now().addMinutes(1);
                
            } 
        }
    }
    /********************************************************************************
* Story: SFDC - 1410
**********************************************************************************************/
    public static void sendAboEvent(Map<Id,OpportunityContact__C> newMap, Map<Id,OpportunityContact__C> oldMap){
        Set<Id> optyIds = new Set<Id>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Set<String> axOrderIds = new Set<String>();
        List<Message__c> msgListinsert = new List<Message__c>();
        for(OpportunityContact__C optyCon:newMap.values()){
            if(userInfo.getFirstName() !='MulesoftUser' && optyCon.Role__c =='Mother' && optyCon.Opportunity_Status__c =='Enrolled'){
                if(oldMap==null || (oldMap!=null && optyCon.Role__c <> oldMap.get(optyCon.id).Role__c ) )
                    optyIds.add(optyCon.Opportunity__c);
            }
            
        }
        if(optyIds!=null && !optyIds.isEmpty()){
            oppMap = new Map<Id,Opportunity>([select id,StageName, Ax_Order_Id__c from opportunity where Id IN:optyIds AND StageName = 'Enrolled' AND Ax_Order_Id__c!=null]);
        }
        if(oppMap !=null && !oppMap.isEmpty()){
            for(Opportunity opp:oppMap.values()){
                axOrderIds.add(opp.Ax_Order_Id__c);
            }
        }
        if(axOrderIds!=null && !axOrderIds.isEmpty()){
            List<Message__c> msglist = new List<Message__c>();
            msglist = [select id,TimeStamp__c,Ax_order_id__c from Message__c where Ax_order_id__c in:axOrderIds];
            Map<String,Message__c> msgMap = new Map<String,Message__c>();
            
            if(msglist!=null && !msglist.isEmpty()){
                for(Message__c msg:msglist){
                    msgMap.put(msg.Ax_order_id__c,msg);
                }
            }
            for(Opportunity opty:oppMap.values()){
                if(String.isNotBlank(opty.Ax_order_id__c) && ((!msgMap.containsKey(opty.Ax_order_id__c) && msgMap!=null) || msgMap ==null)){
                    Message__c msgRec = new Message__c();
                    msgRec.Event_Type__c = 'QucikABO Enrolled Opty';
                    msgrec.TimeStamp__c = system.now().addMinutes(35);
                    PlatformEventWrapper.sencABOEvent ordrIdMap = new PlatformEventWrapper.sencABOEvent();
                    ordrIdMap.axOrderId = opty.Ax_order_id__c;
                    msgRec.Payload__c=JSON.serialize(ordrIdMap);
                    msgRec.status__c = 'New';
                    msgRec.Direction__c = 'outbound';
                    msgRec.Ax_order_id__c = opty.Ax_order_id__c;
                    msgListinsert.add(msgRec); 
                }
            }
        }
        if(msgListinsert!=null){
            database.insert(msgListinsert,false);
        }
    }
    
    /*************************************************************************************************
* @description This method is used to do duplicate check of opportunity contact before insert.
* @param - Trigger New
* @story - SFDC-1277
* @return Void
* @date - 08-Jan-2020 (Teksystems)
*/
    
    public static void duplicateAccountCheck(List<OpportunityContact__c> optyConLst){
        set<Id> optyIds = new set<Id>();
        set<Id> personActIds = new set<Id>();
        map<id,id> optyConAccountMap = new map<id,id>();
        for(OpportunityContact__c oppCon:optyConLst){
            if(oppCon.Opportunity__c != Null && oppCon.PersonAccount__c != Null){
                optyIds.add(oppCon.Opportunity__c);
                personActIds.add(oppCon.PersonAccount__c);
            }
            
        }
        if(!optyIds.isEmpty() && !personActIds.isEmpty()){
            for(OpportunityContact__c optyCon : [select id,Opportunity__c,PersonAccount__c from OpportunityContact__c
                                                 where Opportunity__c IN : optyIds and PersonAccount__c IN : personActIds]){
                                                     optyConAccountMap.put(optyCon.Opportunity__c,optyCon.PersonAccount__c);
                                                 }
        }
        if(!optyConAccountMap.isEmpty()){
            for(OpportunityContact__c oppContact : optyConLst){
                if(optyConAccountMap.get(oppContact.Opportunity__c) == oppContact.PersonAccount__c){
                    oppContact.addError('Selected contact name is already exists on this opportunity Contact.');
                }
            }
        }
    }
    /*************************************************************************************************
* @description This method is used to do update person account name field with person account name.
* @param - Trigger New
* @story - SFDC-1762
* @return Void
* @date - 11-Jun-2021 (Teksystems)
*/
    
    public static void personAccountNameUpdate(List<OpportunityContact__c> optyCons){
        set<Id> personAcctIds = new set<Id>();
        Map<id,String> oppConMap = new Map<id,String>();
        if(!optyCons.isEmpty()){
            for(OpportunityContact__c oppCont:optyCons){
                if(oppCont.Opportunity__c != Null && oppCont.PersonAccount__c != Null){
                    personAcctIds.add(oppCont.PersonAccount__c);
                }
                
            }
        }
        if(!personAcctIds.isEmpty()){
            for(Account accName:[select id,Name from Account where Id IN:personAcctIds]){
                oppConMap.put(accName.id,accName.Name); 
            }
        }
        if(!oppConMap.isEmpty()){
            for(OpportunityContact__c oppContEac:optyCons){
                if(oppConMap.containskey(oppContEac.PersonAccount__c)){
                    oppContEac.Person_Account_Name__c=oppConMap.get(oppContEac.PersonAccount__c);  
                }
                
            }
        }
    }      
}