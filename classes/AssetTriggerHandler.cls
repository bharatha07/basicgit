public class AssetTriggerHandler {
    
    /*************************************************************************************************
* @description This method is used to update opportunity status and Stored_CB__c,Stored_CT__c based on Asset stauts equals stored.
* @param - Trigger list,Map
* @story - SFDC-695
* @return Void
* @date - 24-SEP-2020 (Teksystems)
* Versions: Story #     Updated Date        UpdatedBy   Description
SFDc-702    13th-Sept-2020      Tejaswini   
*/
    
    //As a part of story -SFDC-1776 :Logic to update Asset PrimaryContactEmail
    public static void updateAssetPrimaryContactEmail(List<Asset> assetList){
        system.debug('inside updateAssetPrimaryContactEmail');
        set<id> optyId= new set<id>();
        map<id,string> getemail = new  map<id,string>();
        if(!assetList.isEmpty()){
            for(Asset ast  : assetList){
                if(ast.Status=='Arrived at Lab' && ast.opportunity__c!=null){
                    optyId.add(ast.opportunity__c);
                }
            }
        }
        //map<id,opportunity> optys=new map<id,opportunity>([select id,name,Account.PersonEmail from opportunity where id In:optyId]);
        if(!optyId.isEmpty()){
            for(opportunity ops: [select id,name,Account.PersonEmail from opportunity where id In:optyId]){
                getemail.put(ops.id,ops.Account.PersonEmail);
            }
        }
        
        for(Asset ast  : assetList){
            ast.Primary_Contact_Email__c=ast.Opportunity__c!=null?getemail.get(ast.Opportunity__c):null;
        }
    }
    
    public static void updateOptyStatus(list<Asset> assetList,map<id,asset> oldMapAsset){
        string ErrDetail;
        set<id> optyIds = new set<id>();
        Map<id,Map<String,List<Asset>>> optyAsstStrngMap = new Map<id,Map<String,List<Asset>>>();
        Map<id,opportunity> oppMap = new Map<id,opportunity>();
        list<Opportunity> optyUpdtList = new list<Opportunity>();
        list<Opportunity> optyUpdtList1 = new list<Opportunity>();
        set<id> optyAssetid = new set<id>();
        Map<id,datetime> storagDate = new Map<id,datetime>();
        Map<id,List<Asset>> optyAsset = new Map<id,List<Asset>>();
        for(Asset ass  : assetList){
            if((ass.Status=='Stored' || ass.Status=='Non-processed') && ass.Status != oldMapAsset.get(ass.id).status){
                optyIds.add(ass.Opportunity__c);
            }
        }
        
        if(!optyIds.isEmpty()){
            oppMap = new Map<Id,Opportunity>([select id,of_CB__c,of_CT__c,Stored_CB__c,Stored_CT__c,Status__c,Display_Quoted_of_CB__c,Display_Quoted_of_CT__c from opportunity where id IN :optyIds]);
            for(Asset assCordBlood : [select id,Opportunity__c,Type__c,Status,Freeze_Date__c,Associated_Sample__c  from Asset where Opportunity__c IN : oppMap.keyset() order by Freeze_Date__c asc]){
                //map<string,list<asset>> assStrngMap = new map<string,list<asset>>(); 
                if( optyAsset.containskey(assCordBlood.Opportunity__c)){
                    optyAsset.get(assCordBlood.Opportunity__c).add(assCordBlood);
                    system.debug('optyAssetif>>>>'+optyAsset);
                }else {
                    optyAsset.put(assCordBlood.Opportunity__c, new list<Asset>{assCordBlood});
                    system.debug('optyAsset>>>>'+optyAsset);
                }
                if( optyAsstStrngMap.containskey(assCordBlood.Opportunity__c)){
                    //system.debug('if asset----'+assStrngMap);
                    if((assCordBlood.Status=='Stored' || assCordBlood.Status=='Non-processed') && assCordBlood.Associated_Sample__c==false){
                        map<string,list<asset>> assStrngMap = optyAsstStrngMap.get(assCordBlood.Opportunity__c);
                        if(assStrngMap != null && assStrngMap.containskey(assCordBlood.Type__c)){
                            assStrngMap.get(assCordBlood.Type__c).add(assCordBlood);
                        }else{
                            assStrngMap.put(assCordBlood.Type__c,new list<Asset>{assCordBlood});
                        }
                        //assStrngMap.get(assCordBlood.Type__c).add(assCordBlood);
                        optyAsstStrngMap.put(assCordBlood.Opportunity__c, assStrngMap);
                        system.debug('optyAsstStrngMap>>>>>>>'+optyAsstStrngMap);
                    }
                    
                    
                }else{
                    list<asset> astLst = new list<asset>();
                    astLst.add(assCordBlood);
                    
                    if((assCordBlood.Status=='Stored' || assCordBlood.Status=='Non-processed') && assCordBlood.Associated_Sample__c==false){
                        optyAsstStrngMap.put(assCordBlood.Opportunity__c, new map<string,list<asset>>{assCordBlood.Type__c=>astLst});
                    }
                    
                    
                }
                // optyAsstStrngMap.put(assCordBlood.Opportunity__c, assStrngMap);
            }
        }
        if(assetList!=null && !assetList.isEmpty()){
            for(Asset assLst : assetList){
                if(oppMap.containsKey(assLst.Opportunity__c) ){
                    opportunity opty = oppMap.get(assLst.Opportunity__c);
                    system.debug('>>>opty'+opty);
                    map<string,list<asset>> asstMap = optyAsstStrngMap.get(assLst.Opportunity__c);
                    if(asstMap!=null && !asstMap.isEmpty()){
                        Integer cbStoredAssets = asstMap.get('Cord Blood') != null ? asstMap.get('Cord Blood').size() : 0;
                        system.debug('cbStoredAssets>>>>'+cbStoredAssets);
                        Integer ctStoredAssets = asstMap.get('Cord Tissue') != null ? asstMap.get('Cord Tissue').size() : 0;
                        system.debug('ctStoredAssets>>>'+ctStoredAssets);
                        Integer storedAssets = cbStoredAssets + ctStoredAssets ;
                        system.debug('storedAssets>>>>'+storedAssets);
                        system.debug('asstMap>>>>>'+asstMap);
                        system.debug('optyAsset.get(assLst.Opportunity__c).size()>>>'+optyAsset.get(assLst.Opportunity__c).size());
                        if((assLst.Status=='Stored' || assLst.Status=='Non-processed') && assLst.Status != oldMapAsset.get(assLst.id).status){
                            
                            
                            if((opty.Status__c=='Enrolled' || opty.Status__c=='Pending') && 
                               (opty.Display_Quoted_of_CB__c == cbStoredAssets || cbStoredAssets > opty.Display_Quoted_of_CB__c)  && 
                               (opty.Display_Quoted_of_CT__c == ctStoredAssets || ctStoredAssets > opty.Display_Quoted_of_CT__c) &&
                               optyAsset.get(assLst.Opportunity__c).size() == storedAssets && !optyAssetid.contains(assLst.Opportunity__c)
                              ){
                                  if(optyAsset.get(assLst.Opportunity__c).size() ==1 && assLst.Status =='Non-processed'){
                                      //Not processing anything.
                                  }else{
                                      system.debug('>>>>>Smpletest');
                                      opty.Status__c='Stored';
                                      if(asstMap.containsKey('Cord Blood')){
                                          list<Asset> cbAss = asstMap.get('Cord Blood');
                                          system.debug('size of assets----'+cbAss.size());
                                          opty.of_CB__c=string.valueOf(cbAss.size());
                                          system.debug('cb----'+opty.of_CB__c);
                                      }else{
                                          opty.of_CB__c='0';
                                      }
                                      if(asstMap.containsKey('Cord Tissue')){
                                          list<Asset> ctAss = asstMap.get('Cord Tissue');
                                          system.debug('size of ct assets---'+ctAss);
                                          opty.of_CT__c=string.valueOf(ctAss.size());
                                      }else{
                                          opty.of_CT__c='0';
                                      }
                                      optyUpdtList1.add(opty);
                                      optyAssetid.add(assLst.Opportunity__c);
                                  }
                                  
                              }  
                        }  
                    }
                }
                
            }
        }
        if(!optyUpdtList1.isEmpty()){
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for(Database.SaveResult sr : Database.update(optyUpdtList1,false)){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }  
            } 
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Storage Process Asset trigger', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
    }
    public static void UpdateOppToClosed(Map<Id,Asset> newMap, Map<Id,Asset> oldMap){
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Asset> assetMap = new Map<Id,Asset>();
        Map<Id,Integer> oppToAssetcount = new Map<Id,Integer>();
        Map<Id,Integer> oppToReleasedAssetcount = new Map<Id,Integer>();
        Set<Id> oppIdsToUpdate = new Set<Id>();
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        if(newMap!=null && oldMap == null){
            for(Asset a:newMap.values()){
                if(a.status == 'Released'){
                    oppIds.add(a.Opportunity__c);
                }
            }
        }
        else{
            for(Asset a:newMap.values()){
                if(a.status == 'Released' && a.status != oldMap.get(a.Id).status){
                    oppIds.add(a.Opportunity__c);
                }
            }
        }
        if(oppIds!=null && !oppIds.isEmpty()){
            assetMap = new Map<id,Asset>([select id,Opportunity__c, status from Asset where Opportunity__c IN:oppIds]);
        }
        if(assetMap!=null && !assetMap.isEmpty()){
            for(Asset a:assetMap.values()){
                if( !oppToAssetcount.isEmpty() && oppToAssetcount.containsKey(a.Opportunity__c)){
                    integer count = oppToAssetcount.get(a.Opportunity__c);
                    oppToAssetcount.put(a.Opportunity__c,count+1);
                    if(a.status == 'Released'){
                        if(oppToReleasedAssetcount!=null && oppToReleasedAssetcount.containsKey(a.opportunity__c)){
                            integer ReleasedAssets = oppToReleasedAssetcount.get(a.opportunity__c);
                            oppToReleasedAssetcount.put(a.opportunity__c,ReleasedAssets+1);
                        }
                        else{
                            oppToReleasedAssetcount.put(a.opportunity__c,1);
                        }
                    }
                    
                }
                else{
                    oppToAssetcount.put(a.Opportunity__c,1);
                    if(a.status == 'Released'){
                        if(oppToReleasedAssetcount!=null && oppToReleasedAssetcount.containsKey(a.opportunity__c)){
                            integer ReleasedAssets = oppToReleasedAssetcount.get(a.opportunity__c);
                            oppToReleasedAssetcount.put(a.opportunity__c,ReleasedAssets+1);
                        }
                        else{
                            oppToReleasedAssetcount.put(a.opportunity__c,1);
                        }
                    }
                }
                
                
            }
            
        }
        if(!oppToAssetcount.isEmpty() && !oppToReleasedAssetcount.isEmpty()){
            for(Id oppId:oppToAssetcount.keyset()){
                if(oppToAssetcount.get(oppId) == oppToReleasedAssetcount.get(oppId)){
                    oppIdsToUpdate.add(OppId);
                }
            }
        }
        if(!oppIdsToUpdate.isEmpty()){
            oppMap = new Map<Id,Opportunity>([select id,Status__c,StageName,Loss_Reason__c from Opportunity where Id IN:oppIdsToUpdate]);
        }
        if(oppMap!=null && !oppMap.isEmpty()){
            for(opportunity opp:oppMap.values()){
                opp.status__c = 'Closed';
                opp.StageName = 'Closed Lost';
                opp.Loss_Reason__c='Sample release';
            }
            database.update(oppMap.values(),false);
        }
        
        
    }
    //To create Congrats Call for Asset which got stored. SFDC-1724.
    public static void congratCall(list<Asset> assetLst,map<id,asset> oldMapAssetLst){
        List<Task> taskList= new List<Task>();
        set<string> taskSubject = new set<string>();
        Set<Id> oppIds = new Set<Id>();
        for(Asset ass  : assetLst){
            if(ass.Status=='Stored' && ass.Status != oldMapAssetLst.get(ass.id).status){
                oppIds.add(ass.Opportunity__c);
                string astSub =ass.Type__c+' Stored - Collection Device:'+ass.SerialNumber;
                taskSubject.add(astSub);
            }
        }
        Map<id,task> taskMap = new Map<id,task>();
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        if(oppIds!=null && !oppIds.isEmpty()){
            taskMap = new Map<id,task>([Select id,Subject,WhatId from Task where WhatId IN:oppIds AND Subject IN : taskSubject]);
            for(opportunity opp1 :[select id,ownerid from opportunity where id IN:oppIds] ){
                oppMap.put(opp1.id,opp1);
            }
        }
        Map<id,id> OppIdsToTaskId = new Map<Id,Id>();
        if(taskMap!=null && !taskMap.isEmpty()){
            for(Task t:taskMap.values()){
                OppIdsToTaskId.put(t.whatId,t.id);
            }
        }
        //Loop through the opportunities that are inscope and create a task
        for(Asset eachAss:assetLst){
            if(!OppIdsToTaskId.containsKey(eachAss.Opportunity__c) && oppMap.containsKey(eachAss.Opportunity__c)){
                opportunity opp = oppMap.get(eachAss.Opportunity__c);
                Task congratsTask = new Task();
                congratsTask.Subject=eachAss.Type__c+' Stored - Collection Device:'+eachAss.SerialNumber;
                congratsTask.Status='Open';
                congratsTask.WhatId=eachAss.Opportunity__c;
                congratsTask.ActivityDate=system.today().addDays(7);
                congratsTask.OwnerId=opp.OwnerId;
                congratsTask.Task_Type__c='To Do';
                congratsTask.Task_Sub_Type__c='Congrats Call';
                taskList.add(congratsTask);
            }
        }
        
        if(!taskList.isEmpty()){
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            string ErrDetail;
            for(Database.SaveResult sr : Database.insert(taskList,false)){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }  
            } 
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Collection device Congrats Call', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }
    
    //As a part of story -SFDC-1776 
    public static void sendEmailForSampleArrival(map<id,asset> newMapAssets){
        //set<id> optyWithAsset= new set<id>();
        //set<id> optyWithoutAsset= new set<id>();
        set<id> optyAll= new set<id>();
        List<Task> sampleArrivalTaskList= new List<Task>();
        List<Asset> updateAsset= new  List<Asset>();
        List<Asset> checkAsset= new  List<Asset>();
        Map<Id,Opportunity> oppyList = new Map<Id,Opportunity>();
        Map<Id,Asset> assetMap = new Map<Id,Asset>();
        Map<Id,List<Asset>> optyAssetMap = new Map<Id,List<Asset>>();
        map<id,Asset> testassets  = new map<id,Asset>();
        set<id> optysid=new set<id>();
        Map<Id,List<Id>> optyIdsMulAssets = new Map<Id,List<Id>>();
        Map<Id,List<Id>> oppToAssetIds = new Map<Id,List<Id>>();
        
        for(asset eachast:newMapAssets.values()){
            if(eachast.Opportunity__c!=null)
                optysid.add(eachast.Opportunity__c);  
        }
        if(!optysid.isEmpty()){
            for(Asset eachast:[select id,name,Opportunity__c,Opportunity_PrimaryContact_FirstName__c,Primary_Contact_Email__c,Opportunity__r.OwnerId from Asset where Opportunity__c IN: optysid AND status ='Arrived At Lab' AND Primary_Contact_Email__c!=null]){
                if(optyAssetMap.containskey(eachast.Opportunity__c)) { 
                    optyAssetMap.get(eachast.Opportunity__c).add(eachast);
                    oppToAssetIds.get(eachast.Opportunity__c).add(eachast.id);
                }
                else{
                    optyAssetMap.put(eachast.Opportunity__c, new List<Asset>{eachast});
                    oppToAssetIds.put(eachast.Opportunity__c, new List<Id>{eachast.id});
                } 
            }
        }
        system.debug('the optyAssetMap--->'+optyAssetMap);    
        if(!optyAssetMap.isEmpty()){
            for(Id oppId:optyAssetMap.keyset()){
                if(optyAssetMap.get(oppId).size()==1){
                    updateAsset.addAll(optyAssetMap.get(oppId));
                }
                else{
                    if(!oppToAssetIds.isEmpty()){
                        optyIdsMulAssets.put(oppId,oppToAssetIds.get(oppId));
                    }
                }
            }
        }
        Set<Id> checkAsssettasks = new Set<Id>();
        if(!optyIdsMulAssets.isEmpty()){
            for(LIst<Id> assets:optyIdsMulAssets.values()){
                checkAsssettasks.addAll(assets);
            }
        }
        system.debug('the check assets are---->'+checkAsssettasks);
        Map<Id,Boolean> assetWithTask = new Map<Id,Boolean>();
        if(!checkAsssettasks.isEmpty() || checkAsssettasks!=null){
            for(Asset assetRec:[select id, (select id,whatId,subject,task_type__c,Task_Sub_Type__c from tasks where whatId IN :checkAsssettasks AND subject ='Email: Sample Arrived At Lab' AND task_type__c ='Email' AND Task_Sub_Type__c ='Outbound') from asset where id IN:checkAsssettasks]){
                if(assetRec.tasks.size()==0){
                    assetWithTask.put(assetRec.id,false);
                }
                else{
                    assetWithTask.put(assetRec.id,true);
                }
            }
        }
        if(!optyIdsMulAssets.isEmpty()){
            for(id oppId:optyIdsMulAssets.keyset()){
                Boolean checkTask = false;
                for(Id assetId:optyIdsMulAssets.get(oppId)){
                    if(assetWithTask.get(assetId)== true){
                        checkTask = true;
                    }
                }
                if(checkTask ==false){
                    updateAsset.add(optyAssetMap.get(oppId)[0]);
                }
            }
        }
        
        system.debug('The updateAsset-->'+updateAsset);
        
        if(!updateAsset.isEmpty()){
            string finalasset= json.serialize(updateAsset);
            if(String.isNotEmpty(finalasset)){
                system.debug('calling future');
                FutureClassToSendSampleArrivalEmails.sendSampleArrivalEmails(finalasset); 
            }
            for(Asset eachAss:updateAsset){
                Task sampleArrivalTask = new Task();
                sampleArrivalTask.Subject='CBR Newborn Stem Cell Collection Kit Received at Laboratory';
                sampleArrivalTask.Status='Completed';
                sampleArrivalTask.WhatId=eachAss.Opportunity__c;
                sampleArrivalTask.ActivityDate=system.today();
                sampleArrivalTask.OwnerId=eachAss.Opportunity__r.OwnerId;
                sampleArrivalTask.Task_Type__c='Email';
                sampleArrivalTask.Task_Sub_Type__c='Outbound';
                sampleArrivalTaskList.add(sampleArrivalTask);
            }
        }  
        system.debug('The sampleArrivalTaskList-->'+sampleArrivalTaskList);
        if(!sampleArrivalTaskList.isEmpty()){
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            string ErrDetail;
            for(Database.SaveResult sr : Database.insert(sampleArrivalTaskList,false)){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }  
            } 
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Sample Arrival Task Creation from Asset trigger', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
    }
    
    //As a part of story SFDC-1938
    
    public static void assetReleasePlfEvent(Map<id,Asset> newMap,Map<id,Asset> oldMap){
        set<id> astIds= new set<id>();
        List<Message__c> messageList = new List<Message__c>();
        list<MessageUtilityClass.wrapper> wrpaList = new list<MessageUtilityClass.wrapper>();
        for(Asset eachAst:newMap.values()){
            if(eachAst.Status!=null && eachAst.Status!=oldMap.get(eachAst.id).Status  && eachAst.Status=='Released'){
                astIds.add(eachAst.id);
            }
        }
        if(!astIds.isEmpty()){
            for(Id eachId:astIds){
                Message__c msgRec = new Message__c();
                PlatformEventWrapper.sendAssetID accWrp=new PlatformEventWrapper.sendAssetID();
                MessageUtilityClass.wrapper wrap= new MessageUtilityClass.wrapper();
                wrap.EventType='Asset Release Status Update';
                accWrp.id=eachId;
                wrap.Payload=JSON.serialize(accWrp);
                wrap.status = 'New';
                wrap.Direction = 'outbound';
                wrpaList.add(wrap);
            }
        }
        if(!wrpaList.isEmpty()){
            MessageUtilityClass.getPlatformMessage(wrpaList);
            
            
        }
        
    }
}