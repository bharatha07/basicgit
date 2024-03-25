/**********************************************************************************************************************************************
*Component Name: AccountTriggerHandler
*Created Date :
*Description : To publish platform events when a new account is created and id information field is not null and ScssId is null
               or when a account id information field is not updated by Integration User.
*Created By : Tejaswini Janda(TekSystems)
***Version          UserStory           Date            ModifiedBy          Description
2.0                 SFDC-981            19 June 2020    Tejaswini           Method to Create opportuntiy when lead assignment is
                                                                             updated by marketo sync user
2.1                 SFDC-984            19 June 2020    Tejaswini           Create Campaign Influence record when last touch code field is updated
**************************************************************************************************************************************************/
public class AccountTriggerHandler {
    public static void beforeInsert(List<Account> newMap){
        updateAccountOwner(trigger.new);
        /*  if(recursiveClass.accDupEmail==false){
         dupEmailPrevent(newMap.values());
         } */
    }
    public static void beforeUpdate(Map<id,Account> newMap,Map<Id,Account> oldMap){
        updatemarketoSyncOnAccForoptyCon(newMap,oldMap);
      emailUpdateToAwsPFevent(newMap,oldMap);
     /* if(recursiveClass.accDupEmail==false){
      dupEmailPrevent(newMap,oldMap); //sfdc-1081 , was deployed , check with raj
      } */
    }
    public static void afterInsert(Map<Id,Account> newMap){
        handleAfterInsert(newMap.values(),null,null,false);
    }
    public static void afterUpdate(Map<id,Account> newMap,Map<Id,Account> oldMap){
        handleAfterInsert(newMap.values(),newMap,oldMap,true);
            marketingUpdateHandler(newMap,oldMap);
            emailUpdateToAwsPFevent(newMap,oldMap);
            kitStkUpdateToAXPFevent(newMap,oldMap,true); //- 1373
            aXCusUpdatePFevent(newMap.values(),newMap,oldMap);
            updateProviderFaciltyId(newMap.values(),oldMap);   //sfdc-1208
             if(recursiveClass.oppPrimaryChangeABO == false){
            sendABoEvents(NewMap,oldMap);} 
            /*if(recursiveClass.accOwnerUpdate == false){
               updateOptyOwner(newMap,oldMap);
           }*/
    }
    
    public static void handleAfterInsert(List<Account> AccountList,Map<Id,Account> newMap, Map<Id,Account> oldMap,Boolean accountsUpdate){
        List<Consumer_Update_Event__e> consumerUpdateEventList = new List<Consumer_Update_Event__e>();//This list is publish final events 
        String consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Set<Id> userIds = new Set<Id>();
     
        if(AccountList!=null && !AccountList.isEmpty()){
            for(Account acc:AccountList){
                userIds.add(acc.LastmodifiedById);
            }
        }
   
        //SFDC - 1348 Start
        Set<String> fieldAPINames = new Set<String>();
        List<Schema.FieldSetMember> oppfields = SObjectType.Account.FieldSets.RestrictPlatformEvents.getFields();
        Map<Id,Boolean> accsToAvoidPF = new Map<Id,Boolean>();
        for(Schema.FieldSetMember sc:oppfields){
            fieldAPINames.add(sc.getFieldPath());
        }
         //SFDC - 1348 End
        //Logic to publish platform event when id information field is updated in saleforce 
        if(accountsUpdate == true){
            for(Account acc:AccountList){
                 Boolean isUpdated = false;
                 if(!isUpdated){
                    for(String s:fieldAPINames){
                        if(newMap.get(acc.id).get(s)!=oldMap.get(acc.id).get(s)){
                            isUpdated = true;
                        }
                    }
                 }
                 if(isUpdated){
                    accsToAvoidPF.put(acc.id,isUpdated); 
                 }
             }
            for(Account acc:AccountList){
                Boolean temp = false;
                
            if(acc.RecordTypeId == consumerRecordTypeId && acc.ContactEnrolledScore__pc!=oldMap.get(acc.id).ContactEnrolledScore__pc){
                temp = true;
            }
           // system.debug('temp--'+temp);
           // system.debug('userMap.get(acc.LastModifiedById).FirstName--'+userMap.get(acc.LastModifiedById).FirstName);
           // system.debug('accsToAvoidPF---'+accsToAvoidPF);
            if(acc.RecordTypeId == consumerRecordTypeId &&(  UserInfo.getName()!= 'Integration User' && (accsToAvoidPF!=null && !accsToAvoidPF.containsKey(acc.id)))){
            //if(acc.RecordTypeId == consumerRecordTypeId &&( (!userMap.isEmpty() && userMap.get(acc.LastModifiedById).Name!= 'Integration User') || !temp)){
               // system.debug('inside if');
               // if(acc.RecordTypeId == consumerRecordTypeId && !userMap.isEmpty() && userMap.get(acc.LastModifiedById).Name!= 'Integration User'){
                    //Platform event is created if account updated is consumer recordtype and if it is not modified by integration user
                    Consumer_Update_Event__e newConsumerEvent = new Consumer_Update_Event__e();
                    newConsumerEvent.Consumer_ID__c = acc.Id;
                        if(String.isBlank(acc.ID_Information__pc)){
                            newConsumerEvent.ID_Information_IsChanged__c = false;//Id_information_ischanged flag is set to false as id_info field is null
                        }
                        //we set ID_Information_IsChanged__c true if id_information field value is updated or else ID_Information_IsChanged__c is set to false
                        else if(String.isNotBlank(acc.ID_Information__pc)){
                           if(acc.ID_Information__pc!= oldMap.get(acc.id).ID_Information__pc){
                                newConsumerEvent.ID_Information_IsChanged__c = true;
                           }
                           else if(acc.ID_Information__pc== oldMap.get(acc.id).ID_Information__pc){
                                newConsumerEvent.ID_Information_IsChanged__c = false;
                           } 
                        }
                    
                    consumerUpdateEventList.add(newConsumerEvent);
                }//end of Record type check
                
            }//End of for loop
        }
        //Logic to publish platform event when new account is created and id_inofrmation__pc field has value
        else{
            for(Account acc:AccountList){
            
               // if(String.isBlank(acc.SCSS_Contact_Id__c) && acc.RecordTypeId == consumerRecordTypeId && !userMap.isEmpty() &&userMap.get(acc.LastModifiedById).Name!= 'Integration User'){
           if(String.isBlank(acc.SCSS_Contact_Id__c) && acc.RecordTypeId == consumerRecordTypeId && UserInfo.getName()!= 'Integration User'){
                   // system.debug('acc.LastModifiedBy.FirstName---'+userMap.get(acc.LastModifiedById).FirstName);
                    Consumer_Update_Event__e newConsumerEvent = new Consumer_Update_Event__e();
                    newConsumerEvent.Consumer_ID__c = acc.Id;
                    if(String.isNotBlank(acc.ID_Information__pc)){
                        newConsumerEvent.ID_Information_IsChanged__c = true;
                    }
                    else{
                        newConsumerEvent.ID_Information_IsChanged__c = false;
                    }
                    consumerUpdateEventList.add(newConsumerEvent);
                }

            }
        }

        //Publish platform events
        List<Database.SaveResult> saveResults = EventBus.publish(consumerUpdateEventList);
        for (Database.SaveResult sr : saveResults) {
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() +' - ' +err.getMessage());
            }
        }       
    }
    }
    //Method to handle marketing contact changes
    public static void marketingUpdateHandler(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        //if(UserInfo.getProfileId() == System.Label.MarketoSyncProfileId || System.Label.MarketoSyncProfileId.contains(UserInfo.getProfileId())){
            System.debug('In main method');
            createOppOnLeadAssignment(newMap,oldMap);
            if(!recursiveClass.conUpdateFromCI){
                createCIOnLastTouchCodeUpdate(newMap,oldMap);
                updateOppEnrolledScore(newMap,oldMap);
            }
        //}
    }
    //SFDC - 1284 Start
    public static void updateOppEnrolledScore(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        Map<Id,Decimal> accIds = new Map<id,Decimal>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Account acc:newMap.values()){
            if(acc.ContactEnrolledScore__pc!=null && acc.ContactEnrolledScore__pc != oldMap.get(acc.Id).ContactEnrolledScore__pc){
                accIds.put(acc.id,acc.ContactEnrolledScore__pc);
            }
        }
        if(accIds!=null && !accIds.isEmpty()){
            oppMap = new MAp<Id,Opportunity>([select id,AccountId,OpportunityEnrolledScore__c  from opportunity where accountId IN:accIds.keyset() AND StageName = 'Enrolled' AND (OpportunityEnrolledScore__c =null OR OpportunityEnrolledScore__c = 0) ]);
            if(oppMap!=null){
                for(Opportunity opp:oppMap.values()){
                    //if(opp.OpportunityEnrolledScore__c==null || opp.OpportunityEnrolledScore__c ==0)
                    opp.OpportunityEnrolledScore__c =accIds.get(opp.AccountId);
                }
            }
            update oppMap.values();
            
            
        }
    }
    
    //SFDC - 1284 End
    //Method to Create opportuntiy when lead assignment is updated by marketo sync user
    public static void createOppOnLeadAssignment(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        System.debug('In Method---');
        System.debug('Acc---'+newMap);
        System.debug('Old Map---'+oldMap);
        List<Opportunity> newOppInsert = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();
        List<OpportunityContact__c> oppConList = new List<OpportunityContact__c>();
        Set<id> enrollOpenAccIds = new Set<Id>();
            Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            for(Account acc:newMap.values()){
                System.debug('debug---1');
                if(acc.RecordTypeId == consumerRTId && String.isNotBlank(acc.Lead_assignment__pc) && ((oldMap.get(acc.Id).Lead_assignment__pc!=acc.Lead_assignment__pc && String.isNotBlank(oldMap.get(acc.Id).Lead_assignment__pc)) || String.isBlank(oldMap.get(acc.Id).Lead_assignment__pc))){
                    accIds.add(acc.Id);
                }
            }
            System.debug('accids=='+accIds);
        if(!accIds.isEmpty()){
            oppConList = [Select id,PersonAccount__C,Opportunity__c from OpportunityContact__c where PersonAccount__c IN:accIds AND (Opportunity__r.Status__C ='Open' OR Opportunity__r.Status__c = 'Enrolled')];
        }
        System.debug('oppConList---'+oppConList);
        if(!oppConList.isEmpty()){
            
            for(OpportunityContact__c oppCon:oppConList){
                enrollOpenAccIds.add(oppCon.PersonAccount__C);
            }
        }
        if(!newMap.isEmpty() && newMap!=null){
            System.debug('Debug---2');
            for(Account acc:newMap.values()){
                System.debug('acc---'+acc);
                if(accIds.contains(acc.Id) && ((!enrollOpenAccIds.isEmpty() && !enrollOpenAccIds.contains(acc.Id)) ||enrollOpenAccIds.isEmpty() )){
                    Opportunity opp = new Opportunity();
                    opp.Due_Date__c = acc.Due_Date__pc;
                    opp.Primary_Source__c = acc.Primary_Source__pc;
                    opp.Lead_Assignment__c  = acc.Lead_Assignment__pc;
                    opp.Lead_Source_Code__c = acc.First_Touch_Code__pc;
                    opp.LeadSource = 'Internet';
                    opp.Opty_Source_Code__c = acc.Last_Touch_Code__pc;
                    opp.Lead_UTM_Source__c = acc.utm_source_FT__pc;
                    opp.Lead_UTM_Medium__c = acc.utm_medium_FT__pc;
                    opp.Lead_UTM_Campaign__c = acc.utm_campaign_FT__pc;
                    opp.Opty_UTM_Campaign__c = acc.utm_campaign_LT__pc;
                    opp.Opty_UTM_Medium__c = acc.utm_medium_LT__pc;
                    opp.Opty_UTM_Source__c = acc.utm_source_LT__pc;
                    opp.AccountId = acc.id;
                    opp.Name = 'Test val';
                    opp.CloseDate = System.today();
                    opp.StageName = 'Marketing Qualified';
                    opp.Lead_RecordType_Name__c = 'NonMQL';// This field is populated with NonMQL so that workflow field update will change stage to marketing qualified
                    newOppInsert.add(opp);
                }
            }
        }
        System.debug('Optys---'+newOppInsert);
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        if(!newOppInsert.isEmpty()){
            saveResults =  Database.insert(newOppInsert,false);
            System.debug('saveResults----'+saveResults);
        }
        
    }
    //Create Campaign Influence record when last touch code field is updated
    public static void createCIOnLastTouchCodeUpdate(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        List<OpportunityContact__c> optyContactsList = new List<OpportunityContact__c>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Set<String> campaignCodes = new Set<String>();
        Map<String,Id> campaignIds = new Map<String,Id>();
        List<CampaignInfluence> capaignInfList = new List<CampaignInfluence>();
        Map<Id,Id> accOppMap = new Map<Id,Id>();
        System.debug('newMap========'+newMap);
        for(Account acc:newMap.values()){
            System.debug('In for loop');
            System.debug('acc.RecordTypeId===='+acc.RecordTypeId);
            System.debug('acc.Last_Touch_Code__pc===='+acc.Last_Touch_Code__pc);
            System.debug('oldMap.get(acc.Id).Last_Touch_Code__pc===='+oldMap.get(acc.Id).Last_Touch_Code__pc);
            if(acc.RecordTypeId == consumerRTId && String.isNotBlank(acc.Last_Touch_Code__pc) && ((oldMap.get(acc.Id).Last_Touch_Code__pc!=acc.Last_Touch_Code__pc && String.isNotBlank(oldMap.get(acc.Id).Last_Touch_Code__pc)) || String.isBlank(oldMap.get(acc.Id).Last_Touch_Code__pc)) ){
                System.debug('acc record---'+acc);
                accMap.put(acc.Id,acc);
                campaignCodes.add(acc.Last_Touch_Code__pc);
            }
        }
        if(!accMap.isEmpty()){
            optyContactsList = [select id,PersonAccount__c,Opportunity__C from OpportunityContact__c where PersonAccount__c IN:accMap.keyset() AND Opportunity__r.Status__C = 'Open' ];
            for(OpportunityContact__c oppCon:optyContactsList){
                accOppMap.put(oppCon.PersonAccount__c,oppCon.Opportunity__C);
            }
        }
        if(!campaignCodes.isEmpty()){
            //Campaign_Model_Id label
            List<Campaign> campaignList = new List<Campaign>();
            CampaignList = [Select id,Campaign_Code__c from Campaign where  Campaign_Code__c IN:campaignCodes];
            for(Campaign cam:CampaignList){
                campaignIds.put(cam.Campaign_Code__c,cam.Id);
            }
        }
        System.debug('accMap==='+accMap);
        System.debug('accOppMap==='+accOppMap);
        System.debug('campaignIds==='+campaignIds);
        if(!accMap.isEmpty() && !accOppMap.isEmpty() && !campaignIds.isEmpty()){
            System.debug('inside all if check');
            for(Account acc:accMap.values()){
                CampaignInfluence ci = new CampaignInfluence();
                ci.CampaignId = campaignIds.get(acc.Last_Touch_Code__pc);
                ci.OpportunityId = accOppMap.get(acc.id);
                ci.ContactId = acc.PersonContactId;
                ci.Modelid =Label.Campaign_Model_Id;
                capaignInfList.add(ci);
            }
        }
        List<Database.SaveResult> saveresults = new List<Database.SaveResult>();
        System.debug('capaignInfList---'+capaignInfList);
        if(!capaignInfList.isEmpty()){
            recursiveClass.conUpdateFromCI = true;
            saveresults = Database.insert(capaignInfList,false);
            System.debug('  '+saveresults);
            
            System.debug('recursiveClass.conUpdateFromCI---'+recursiveClass.conUpdateFromCI);
        }
        System.debug('recursiveClass.conUpdateFromCI-- outside if');
    }
     public static void updatemarketoSyncOnAccForoptyCon(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        
        map<String,Account> mapOfAccountIdToAccount = new Map<String,Account>();
        Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            for(Account acc:newMap.values()){
                System.debug('debug---1');
                if(acc.RecordTypeId == consumerRTId && String.isNotBlank(acc.PersonEmail) && !acc.Marketo_Sync__pc && String.isBlank(oldMap.get(acc.Id).PersonEmail)){
                   mapOfAccountIdToAccount.put(acc.Id, acc);
                }
            }
            
        if(!mapOfAccountIdToAccount.isEmpty()){
            for(OpportunityContact__c oppContact : [Select id,PersonAccount__C,Opportunity__c from OpportunityContact__c where PersonAccount__c IN : mapOfAccountIdToAccount.keySet() AND Role__c in ('Father','Mother','Adoptive Mom','Adoptive Dad','Grandparent','Partner','Adoptive Father','Adoptive Mother')]) {
                mapOfAccountIdToAccount.get(oppContact.PersonAccount__c).Marketo_Sync__pc = true;
            }
        }
      }
      //This method is called in before insert trigger. When nonmql lead is converted we update owner if the owner is markto user
      public static void updateAccountOwner(List<Account> accList){
        String consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Set<id> userIds = new Set<Id>();
        for(Account acc:accList){
            if(acc.RecordTypeId == consumerRecordTypeId && String.isNotBlank(acc.Lead_RecordTypeName__pc) && acc.Lead_RecordTypeName__pc == 'NonMQL' && acc.OwnerId != Userinfo.getuserId()){
                userIds.add(acc.OwnerId);
                userIds.add(Userinfo.getUserId());
            }
        }
        if(!userIds.isEmpty()){
            Map<Id,User> userMap = new Map<Id,User>([select id,Profile.name from user where Id IN:userIds limit 49999]);
            for(Account acc:accList){
                if(!userMap.isEmpty() && userMap.get(acc.ownerId).Profile.name =='Marketo Sync' && userMap.get(UserInfo.getuserId()).Profile.name =='Sales Rep NSCE'){
                    acc.OwnerId = Userinfo.getUserId();
                }
            }
        }
        
      } 
      
     /*************************************************************************************************
     * @description This method is used to publish platform event(AWS) for email changed on Contact
     * @param - Trigger map
     * @story - SFDC-1042
     * @return Void
     * @date - 28-JULY-2020 (Teksystems)
     */
    public static void emailUpdateToAwsPFevent(Map<Id,Account> newMap, Map<Id,Account> oldMap){
          if(!recursiveClass.emailUpdateToPFevent){
       List<Consumer_Email_Update_Event__e> consumerEmailUpdateEventList = new List<Consumer_Email_Update_Event__e>();
       Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Map<Id,Account> accMap = new Map<Id,Account>();
        set<id> accids=new set<id>();
       Map<Id,Account> accMaptoUpdate = new Map<Id,Account>();
     List<OpportunityContact__c> optyContactsList = new List<OpportunityContact__c>();
        
        for(Account acc:newMap.values()){
            System.debug('In for loop');
            System.debug('acc.RecordTypeId===='+acc.RecordTypeId);
            if(acc.RecordTypeId == consumerRTId && String.isNotBlank(acc.PersonEmail) && String.isNotBlank(oldMap.get(acc.Id).PersonEmail) && acc.PersonEmail <> oldMap.get(acc.Id).PersonEmail){
                System.debug('acc record---'+acc);
                accMap.put(acc.Id,acc);
                
            }
        }
         if(!accMap.isEmpty()){
            optyContactsList = [select id,PersonAccount__c,Opportunity__C from OpportunityContact__c where PersonAccount__c IN:accMap.keyset() AND Primary__c = true];
            for(OpportunityContact__c oppCon:optyContactsList){
                accids.add(oppCon.PersonAccount__c);
            }
        }
          for(Account accA:newMap.values()){
          if(accids.contains(accA.Id)){
            system.debug('value in pf :::'+'---'+accA.PersonEmail+'---'+oldMap.get(accA.id).PersonEmail+accA.Id);
              Consumer_Email_Update_Event__e newConsumerEvent = new Consumer_Email_Update_Event__e();
                                newConsumerEvent.AccountEmailNew__c = accA.PersonEmail;
                                newConsumerEvent.AccountEmailOld__c= oldMap.get(accA.id).PersonEmail;
                                newConsumerEvent.Consumer_Id__c = accA.Id;
                        
                    consumerEmailUpdateEventList.add(newConsumerEvent);
                    }
              
          }
           //Publish platform events
        List<Database.SaveResult> saveResults = EventBus.publish(consumerEmailUpdateEventList);
        for (Database.SaveResult sr : saveResults) {
        if (sr.isSuccess()) {
            System.debug('Successfully published event for Email Update.');
            recursiveClass.emailUpdateToPFevent = true;
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned for event consumer Email update: ' + err.getStatusCode() +' - ' +err.getMessage());
            }
        }       
    }
        
    }
    }
    /*************************************************************************************************
     * @description This method is used to show error message for duplicate email on Email update for existing record
     * @param - Trigger map
     * @story - SFDC-1081
     * @return Void
     * @date - 29-JULY-2020 (Teksystems)
     */
  /*  public static void dupEmailPrevent(Map<Id,Account> newMap, Map<Id,Account> oldMap){
         //Preparing Account names in Set from trigger.new
         system.debug('Entered preventDupEmailOnAcc method ');
        Set<String> emailSet = new Set<String>();
       for(Account acc : newMap.values()){
        if(String.isNotBlank(acc.PersonEmail) && String.isNotBlank(oldMap.get(acc.Id).PersonEmail) && acc.PersonEmail <> oldMap.get(acc.Id).PersonEmail){
           emailSet.add(acc.PersonEmail);   
           }  
           else if (String.isBlank(oldMap.get(acc.Id).PersonEmail) && String.isNotBlank(acc.PersonEmail) ){
           emailSet.add(acc.PersonEmail);
           }   
        }
        // calling generic method
        dupEmailPreventGeneric(emailSet,newMap);
     } */
     /*************************************************************************************************
     * @description This method is used to show error message for duplicate email on new record creation
     * @param - Trigger list
     * @story - SFDC-1081
     * @return Void
     * @date - 01-AUG-2020 (Teksystems)
     */
   /*  public static void dupEmailPrevent(List<Account> newAccounts){
        Map<Id,Account> newMap=new Map<Id,Account>();
         //Preparing Account names in Set from trigger.new
         system.debug('Entered preventDupEmailOnAcc method ');
        Set<String> emailSet = new Set<String>();
       for(Account acc : newAccounts){
        newMap.put(acc .Id,acc);
        if(String.isNotBlank(acc.PersonEmail)){
           emailSet.add(acc.PersonEmail);   
           }     
        }
        // calling generic method
        dupEmailPreventGeneric(emailSet,newMap);
     } */
     /*************************************************************************************************
     * @description This is generaic  method used for prevent  duplicate email 
     * @param - Trigger map
     * @story - SFDC-1081
     * @return Void
     * @date -01-AUG-2020 (Teksystems)
     */
  /*   private static void dupEmailPreventGeneric(Set<String> emailSet , Map<Id,Account> newMap){
       map<id,Account> accMap=new map<id,Account>();
        if(emailSet.size()>0){
          accMap=new map<id,Account>( [select id,PersonEmail ,RecordType.Name from Account where PersonEmail in: emailSet AND RecordType.Name='Consumer']);
           system.debug('map accmap'+accMap);
            }
            Map<String,Account> emailAccMap = new Map<String,Account>();
            if(accMap.size() > 0){
            for(Account acc:accMap.values()){
                emailAccMap.put(acc.personEmail,acc);
                system.debug('map is'+acc);
            }
            }
        for(Account a : newMap.values()){
            if(accMap.size() > 0 && emailAccMap.containsKey(a.PersonEmail)){
             system.debug('a is'+a);
              a.addError('Account already exists in your Organization with same Email ');
            }        
        }
         recursiveClass.accDupEmail=true;
} */
      /* @description This method is to update open opty's owner when account owner is updated 
     * @param - Trigger map
     * @story - SFDC-1045
     * @return Void
     * @date - 29-JULY-2020 (Teksystems)
     
     public static void updateOptyOwner(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        List<Opportunity> opToUpdate = new List<Opportunity>();
        Map<Id,Id> accOwnerIdsMap = new Map<Id,Id>();
        Map<id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Account acc:newMap.values()){
            if(acc.OwnerId != oldMap.get(acc.id).OwnerId){
                accOwnerIdsMap.put(acc.id,acc.ownerId);
            }
        }
        if(accOwnerIdsMap.size()>0){
            oppMap = new Map<Id,Opportunity>([select id,ownerId,AccountId,status__c from opportunity where AccountId IN:accOwnerIdsMap.keySet() AND status__c = 'Open']);
        }
        if(oppMap.size()>0){
            for(Opportunity opp:oppMap.values()){
                opp.ownerId = accOwnerIdsMap.get(opp.AccountId);
                opToUpdate.add(opp);
            }
        }
        if(opToUpdate.size()>0){
            recursiveClass.accOwnerUpdate = true;
            database.update(opToUpdate,false);
        }
     }*/
  /*************************************************************************************************
     * @description This method is used to publish platform event(AX) for Kit Stocking flag TRUE  on Facility
     * @param - Trigger map
     * @story - SFDC-1151
     * @return Void
     * @date - 17-AUG-2020 (Teksystems)
     * @Comment - Updated with "facilityUpdate" on 29-SEP-2020 as part of SFDC-1193(flag is true and record is updated)
     */
    public static void kitStkUpdateToAXPFevent(Map<Id,Account> newMap, Map<Id,Account> oldMap,Boolean facilityUpdate){
        List<Message__c> messageList = new List<Message__c>();
        List<Facility_Kit_Update_Event__e> consumerEmailUpdateEventList = new List<Facility_Kit_Update_Event__e>();
        Id facilityRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        Map<Id,Account> accMap = new Map<Id,Account>();
        set<id> accids=new set<id>();
        Map<Id,Account> accMaptoUpdate = new Map<Id,Account>();
        List<OpportunityContact__c> optyContactsList = new List<OpportunityContact__c>();
        
        for(Account acc:newMap.values()){
            System.debug('In for loop');
            System.debug('acc.RecordTypeId===='+acc.RecordTypeId);
            if(acc.RecordTypeId == facilityRTId && acc.Kit_Stocking__c  && (acc.Kit_Stocking__c <> oldMap.get(acc.Id).Kit_Stocking__c || facilityUpdate)){
                System.debug('acc record---'+acc);
                accMap.put(acc.Id,acc);
                
            }
        }
        for(Account accA:accMap.values()){
            PlatformEventWrapper.FacilityKitUpdateEvent accWrp=new PlatformEventWrapper.FacilityKitUpdateEvent();
            Message__c msgRec = new Message__c();
            msgRec.Event_Type__c = 'Facility Kit Update Event';
            accWrp.FacilityId=accA.id;
            msgRec.Payload__c = JSON.serialize(accWrp);
            msgRec.status__c = 'New';
            msgRec.Direction__c = 'Outbound';
            messageList.add(msgRec);
        }
        if(!messageList.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(messageList,false);
            
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for Kit Stocking Update.1151 and 1193');
                    // recursiveClass.kitUpdateToPFevent = true;
                    
                } else {
                    string ErrDetail='Error returned for Kit Stocking Update.1151 and 1193';
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
      /*************************************************************************************************
     * @description This method is used to publish platform event(AX) for ax customer id update on consumer
     * @param - Trigger map
     * @story - SFDC-1088
     * @return Void
     * @date - 18-AUG-2020 (Teksystems)
     */
    public static void aXCusUpdatePFevent(List<Account> AccountList,Map<Id,Account> newMap, Map<Id,Account> oldMap){
    if(!recursiveClass.axCus2Pfevent){
    system.debug('SFDC-1200 did not call it');
     if(!recursiveClass.cusUpdatePfevent){
       List<Message__c> messageList = new List<Message__c>();
       Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
         Set<String> fieldAPINames = new Set<String>();
        List<Schema.FieldSetMember> oppfields = SObjectType.Account.FieldSets.AxplatformEventsRestrcition.getFields();
        Map<Id,Boolean> accsToAvoidPF = new Map<Id,Boolean>();
        for(Schema.FieldSetMember sc:oppfields){
            fieldAPINames.add(sc.getFieldPath());
        }
        for(Account acc:AccountList){
                 Boolean isUpdated = false;
                 if(!isUpdated){
                    for(String s:fieldAPINames){
                        if(newMap.get(acc.id).get(s)!=oldMap.get(acc.id).get(s)){
                            isUpdated = true;
                        }
                    }
                 }
                 if(isUpdated){
                    accsToAvoidPF.put(acc.id,isUpdated); 
                 }
             }
          for(Account acc:AccountList){
            
                if(String.isNotBlank(acc.AX_Customer_Id__pc) && acc.RecordTypeId == consumerRTId &&UserInfo.getName()!= 'Integration User'
                   && UserInfo.getName()!= 'MulesoftUser MulesoftUser' && !accsToAvoidPF.isEmpty() && accsToAvoidPF.containsKey(acc.id)){
                PlatformEventWrapper.AxCustomerUpdateEvent accWrp=new PlatformEventWrapper.AxCustomerUpdateEvent();
                Message__c msgRec=new Message__c();
                msgRec.Event_Type__c='Ax Customer Update Event';
                accWrp.AxConsumerId=acc.Id;
                msgRec.Payload__c=JSON.serialize(accWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                messageList.add(msgRec);             
                }
            }
          
         if(!messageList.isEmpty()){
             List<Database.SaveResult> saveResults = Database.insert(messageList,false);
             List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
             for (Database.SaveResult sr : saveResults) {
                 if (sr.isSuccess()) {
                     System.debug('Successfully published event for customer id update.1088');
                     
                 } else {
                     string ErrDetail='Error returned for customer id update.1088';
                     for(Database.Error err : sr.getErrors()) {
                         ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                     }
                     
                     system.debug('erromessgae'+ErrDetail);
                     cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Ax Customer Update Event', 'Apex Event', ErrDetail, false, false);
                     system.debug('cbrutility'+cbr);
                     cbrErrorLog.add(cbr);
                     system.debug('cbrutilityList'+cbrErrorLog);
                     
                 }       
             }
             Database.insert(cbrErrorLog, false);
             system.debug('>>>>>>'+cbrErrorLog);    
         }
         recursiveClass.cusUpdatePfevent= true;
     }
    }
    }  
    
  /*************************************************************************************************
* @description This method is used to update provider facility Id with Facility Name and Provider name on change of account last name or first name.
* @param - Trigger map
* @story - SFDC-1208
* @return Void
* @date - 18-SEP-2020 (Teksystems)
*/
    public static void updateProviderFaciltyId(list<account> accList , map<id,account> oldAccMap){
        set<id> accountIds = new set<id>();
        list<Provider_Facility__c> providerFacilityList = new list<Provider_Facility__c>();
        Id providerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        Id facilityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        for(account acc  : accList){
            system.debug('acc.FirstName'+acc.FirstName);
            system.debug('acc.LastName'+acc.LastName);
            system.debug('acc.Name'+acc.Name);
            if((acc.FirstName != oldAccMap.get(acc.id).firstName || acc.LastName != oldAccMap.get(acc.id).lastname || acc.Name != oldAccMap.get(acc.id).Name) && 
               (acc.RecordTypeId == providerRecordTypeId || acc.RecordTypeId == facilityRecordTypeId)){
                  accountIds.add(acc.id); 
                   
               }

        }
        if(!accountIds.isempty()){
            for(Provider_Facility__c provider : [select id,Name,Facility__r.Name,Provider_Name__c,Provider__r.Name from Provider_Facility__c where facility__c IN : accountIds Or  Provider__c IN : accountIds]){
                provider.name=provider.Facility__r.Name +' - '+provider.Provider__r.Name;
                providerFacilityList.add(provider);
            }
            
            
        }
        if(!providerFacilityList.isempty()){
            update providerFacilityList;
            
        }
    }
    //Start SFDC - 1410
    public static void sendABoEvents(Map<Id,Account> newMap,Map<Id,Account> oldMap){
        Id consumerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Set<Id> accids = new Set<Id>();
        Map<id,OpportunityContact__c> optycons =new Map<Id,OpportunityContact__c>();
        Set<String> optyAxIds = new Set<String>();
            Map<id,Message__c> msgRecs = new Map<id,Message__c>();
            Map<String,Message__c> msgMap = new Map<String,Message__c>();
             List<Message__c> msgList = new List<Message__c>();
        For(Account acc:newMap.values()){
            if(userInfo.getFirstName() !='MulesoftUser' && acc.RecordTypeId == consumerRTId && (acc.FirstName <> oldMap.get(acc.Id).FirstName || acc.LastName <> oldMap.get(acc.Id).LastName || acc.PersonMobilePhone <> oldMap.get(acc.Id).PersonMobilePhone || acc.Phone <> oldMap.get(acc.Id).Phone)){
                accids.add(acc.Id);
            }
        }
        if(accids!=null && !accids.isEmpty()){
            optycons = new Map<Id,OpportunityContact__c>([select id,Role__c, Opportunity__r.AX_Order_Id__c,Opportunity__r.stageName from OpportunityContact__c where personAccount__c IN:accids AND Role__c ='Mother' AND Opportunity__r.StageName ='Enrolled' AND Opportunity__r.AX_Order_Id__c!=null]);
        }
        if(optycons!=null && !optycons.isEmpty()){
            for(OpportunityContact__c optycon:optycons.values()){
                optyAxIds.add(optycon.Opportunity__r.AX_Order_Id__c);
            }
        }
                    if(optyAxIds!=null && !optyAxIds.isEmpty()){
            msgRecs = new Map<id,Message__c>([select id,TimeStamp__c,Ax_order_id__c,status__c from Message__c where Ax_order_id__c in:optyAxIds AND status__c = 'New']);
            }
            if(msgRecs!=null && !msgRecs.isEmpty()){
                for(Message__c msg:msgRecs.values()){
                    msgMap.put(msg.Ax_order_id__c,msg);
                }
            }
            for(OpportunityContact__c opty:optycons.values()){
                if( String.isNotBlank(opty.Opportunity__r.Ax_order_id__c) && ((!msgMap.containsKey(opty.Opportunity__r.Ax_order_id__c) && msgMap!=null) || msgMap ==null)){
                    Message__c msgRec = new Message__c();
                    msgRec.Event_Type__c = 'QucikABO Enrolled Opty';
                    msgrec.TimeStamp__c = system.now().addMinutes(35);
                    PlatformEventWrapper.sencABOEvent ordrIdMap = new PlatformEventWrapper.sencABOEvent();
                    ordrIdMap.axOrderId = opty.Opportunity__r.Ax_order_id__c;
                    msgRec.Payload__c=JSON.serialize(ordrIdMap);
                    msgRec.status__c = 'New';
                    msgRec.Direction__c = 'outbound';
                    msgRec.Ax_order_id__c = opty.Opportunity__r.Ax_order_id__c;
                    msgList.add(msgRec); 
                }
            }
            if(msgList!=null && !msgList.isEmpty()){
                database.insert(msgList,false);
            }
    }
    //End SFDC - 1410
}