/**********************************************************************************************************************************************
*Component Name: opportuityTriggerHandler
*Created Date : 8th July 2020
*Description : To publish platform events when a new account is created and id information field is not null and ScssId is null
or when a account id information field is not updated by Integration User.
*Created By : Tejaswini Janda(TekSystems)
**************************************************************************************************************************************************/
public class opportunityTriggerHandler{
    public static void beforeInsert(Map<Id,Opportunity> newMap){
        updateoptyName(newMap);
    }
    public static void beforeUpdate(Map<id,opportunity> newMap,Map<Id,Opportunity> oldMap){
        updateoptyName(newMap);
    }
    
    public static void updateOwner(List<Opportunity> oppList){
        set<id> userIds = new Set<id>();
        for(opportunity opp:oppList){
            system.debug('opp.Lead_RecordType_Name__c'+opp.Lead_RecordType_Name__c);
            system.debug('opp.OnLeadConvertion__c'+opp.OnLeadConvertion__c);
            if( String.isNotblank(opp.Lead_RecordType_Name__c) && opp.OnLeadConvertion__c && ((opp.OwnerId != Userinfo.getuserId() && opp.Lead_RecordType_Name__c =='NonMQL') ||( opp.Lead_RecordType_Name__c =='NonMQL' || opp.Lead_RecordType_Name__c =='Manual Lead') ) ){
                userIds.add(opp.OwnerId);
                userIds.add(Userinfo.getuserId());
            }
        }
        if(!userIds.isEmpty()){
            Map<Id,User> userMap = new Map<Id,User>([select id,Profile.name from user where Id IN:userIds]);
            for(Opportunity opp:oppList){
                if(!userMap.isEmpty() ){
                if(userMap.get(opp.OwnerId).Profile.Name == 'Marketo Sync' && userMap.get(UserInfo.getuserId()).Profile.Name == 'Sales Rep NSCE'){
                    opp.OwnerId = userInfo.getuserId();
                }
                 if(userMap.get(UserInfo.getuserId()).Profile.Name == 'Client Services Special' || userMap.get(UserInfo.getuserId()).Profile.Name == 'Client Support Specialist'){
                    opp.Primary_Source__c = 'Referred by CBR Client';
                    opp.ownerid=system.label.User_Integration_Id;
                }
                }
                
            }
            
        } //NSCEProfileId -- MarketoSyncProfileID
        
    }
    //method to enroll online enrollment opportunities when completed flag is set to true
    public static void updateOptyStage(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        Set<Id> completedOptyIds = new Set<Id>();
        // Set<Id> deliveringHospitalIds = new Set<Id>();
        Map<Id,Opportunity_Provider__c> oppProvidersMap = new Map<Id,Opportunity_Provider__c>();
        Map<id,Opportunity_Provider__c> providerMap = new Map<Id,Opportunity_Provider__c>();//This map holds key as opty id and its primary provider
        Map<Id,Account> hospitalsMap = new Map<Id,Account>();
        for(Opportunity opp:newMap.values()){
            if(opp.Completed_Flag__c == true && !oldMap.isEmpty() && oldMap.get(opp.Id).Completed_Flag__c == false){
                /* if(String.isnotBlank(opp.Delivering_Hospital__c)){
deliveringHospitalIds.add(opp.Delivering_Hospital__c);
} */
                completedOptyIds.add(opp.id);
                
            }
        }
        
     /*   if(!completedOptyIds.isEmpty()){
            oppProvidersMap = new Map<Id,Opportunity_Provider__c>([select id,Opportunity__c,Provider__c,Provider__r.Name from Opportunity_Provider__c where Primary_Provider__c =true AND Opportunity__c IN:completedOptyIds]);
            
        }
        if(oppProvidersMap!=null && !oppProvidersMap.isEmpty()){
            for(Opportunity_Provider__c op:oppProvidersMap.values()){
                providerMap.put(op.Opportunity__c,op);
            }
        } */ //commented for new OLE
        /*  if(deliveringHospitalIds!=null && !deliveringHospitalIds.isEmpty()){
hospitalsMap = new Map<Id,Account>([select id,Name from account where Id IN:deliveringHospitalIds]);
}*/
        try{
            for(Opportunity opp:newMap.values()){
                if(completedOptyIds!= null && !completedOptyIds.isEmpty() && completedOptyIds.contains(opp.id)){
                    //  if(String.isNotBlank(opp.Delivering_Hospital__c) && !hospitalsMap.isEmpty() && hospitalsMap.get(opp.Delivering_Hospital__c).Name != 'No Hospital Available' && !providerMap.isEmpty() && providerMap.containsKey(opp.id) && providerMap.get(opp.id).Provider__r.Name!='Available No Provider' && opp.LeadSource =='OENROLL' && (opp.Adoption_Type__c =='N/A' || opp.Adoption_Type__c =='NA' )){
                    // if(String.isNotBlank(opp.Delivering_Hospital__c) && !providerMap.isEmpty() && providerMap.containsKey(opp.id) && providerMap.get(opp.id).Provider__r.Name!='Available No Provider' && (opp.Adoption_Type__c =='N/A' || opp.Adoption_Type__c =='NA' )){
                    if(String.isNotBlank(opp.Delivering_Hospital__c) && opp.Payment_Plan__c !='Care Credit 48 month' && (opp.Adoption_Type__c =='N/A' || opp.Adoption_Type__c =='NA' ) && opp.Pricebook2Id ==Label.CPQUsaPriceBook){
                        recursiveClass.optyEnrolledOLE = true; 
                        recursiveClass.OleEnrolled = true;
                        opp.Statements1__c = true;
                        opp.PrimaryContactInfoConfirmation1__c = true;
                        opp.ConfirmDueDateCBCTAdoptionType1__c= true;
                        opp.InformedConsent1__c = true;
                        opp.CancellationFee1__c = true;
                        opp.KitPickupOrShipConfirmation1__c = true;
                        if(opp.Loss_Reason__c !=null){
                            opp.Loss_Reason__c='';   
                        }
                        if(opp.Requested_Shipping_Date__c < system.today()){
                            opp.Requested_Shipping_Date__c=system.today();   
                        } 
                        opp.StageName = 'Enrolled';
                        opp.Online_Enroll_Status__c='Auto Enrolled';
                    }
                    else{
                        system.debug('Partial enroll opty');
                        opp.StageName = 'Partial Online Enroll';
                        opp.Online_Enroll_Status__c='Complete';
                        
                    }
                    opp.of_CB_at_enrollment__c = Integer.valueOf(opp.of_CB__c);
                    opp.of_CT_at_enrollment__c = integer.valueOf(opp.of_CT__c);
                    opp.ofGSatenrollment__c = opp.of_GS__c;
                    
                }              
                opp.stageName = opp.stageName;
            }
        }
        catch(Exception ex){
            
        }
        //SFDC - 1313 Logic Start
        for(Opportunity opp:newMap.values()){
            // Start SFDC - 1700
            if(opp.ofquotedGS__c!=null && opp.ofquotedGS__c>0 && opp.ofquotedGS__c != oldMap.get(opp.id).ofquotedGS__c){
                opp.of_GS__c = opp.ofquotedGS__c;
            }
            //End SFDC - 1700
            if((opp.Quoted_of_CB__c > 0 || opp.Quoted_of_CT__c > 0 || opp.ofquotedGS__c > 0) && oldMap!=null && !oldMap.isEmpty()){
                if(String.isNotBlank(opp.of_CB__c) && opp.Quoted_of_CB__c!=null && Integer.valueOf(opp.of_CB__c)!= opp.Quoted_of_CB__c && opp.Quoted_of_CB__c!=null){
                    if(oldMap.get(opp.id).Quoted_of_CB__c != opp.Quoted_of_CB__c && opp.Quoted_of_CB__c == 0){
                        opp.of_CB__c = '0';
                    }
                    else if(oldMap.get(opp.id).Quoted_of_CB__c != opp.Quoted_of_CB__c){
                        opp.of_CB__c = String.valueOf(Integer.valueOf(opp.Quoted_of_CB__c));
                    }  
                }
                if(oldMap.get(opp.id).Quoted_of_CB__c != opp.Quoted_of_CB__c && (opp.Quoted_of_CB__c == 0 || opp.Quoted_of_CB__c == null)){
                    opp.of_CB__c = '0';
                }
                if(String.isNotBlank(opp.of_CT__c) && opp.Quoted_of_CT__c!=null && Integer.valueOf(opp.of_CT__c)!= opp.Quoted_of_CT__c && opp.Quoted_of_CT__c!=null){
                    if(oldMap.get(opp.id).Quoted_of_CT__c != opp.Quoted_of_CT__c && opp.Quoted_of_CT__c == 0){
                        opp.of_CT__c = '0';
                    }
                    else if(oldMap.get(opp.id).Quoted_of_CT__c != opp.Quoted_of_CT__c){
                        opp.of_CT__c = String.valueOf(Integer.valueOf(opp.Quoted_of_CT__c));
                    } 
                }
                if(oldMap.get(opp.id).Quoted_of_CT__c != opp.Quoted_of_CT__c && (opp.Quoted_of_CT__c == 0 || opp.Quoted_of_CT__c == null)){
                    opp.of_CT__c = '0';
                }
             if(opp.of_GS__c !=null && opp.ofquotedGS__c!=null && Integer.valueOf(opp.of_GS__c)!= opp.ofquotedGS__c){
                    if(oldMap.get(opp.id).ofquotedGS__c != opp.ofquotedGS__c && opp.ofquotedGS__c == 0){
                        opp.of_GS__c = 0;
                    }
                    else if(oldMap.get(opp.id).ofquotedGS__c != opp.ofquotedGS__c){
                        opp.of_GS__c = Integer.valueOf(opp.ofquotedGS__c);
                    }  
                }
                if(oldMap.get(opp.id).ofquotedGS__c != opp.ofquotedGS__c && (opp.ofquotedGS__c == 0 || opp.ofquotedGS__c == null)){
                    opp.of_GS__c = 0;
                }   
            }   
        } 
        //SFDC - 1313 Logic End
    }
    
    public static void updateAccOwner(Map<Id,opportunity> newMap, Map<Id,Opportunity> oldMap){
        Map<Id,Account> consumerMap = new Map<Id,Account>();
        List<Account> accsToUpdate = new List<Account>();
        Map<id,id> oppAccIdsMap = new Map<Id,Id>();
        for(Opportunity opp:newMap.values()){
            if(opp.OwnerId != oldMap.get(opp.id).OwnerId && opp.Status__c=='Open'){
                oppAccIdsMap.put(opp.AccountId,opp.OwnerId);
            }
        }
        if(oppAccIdsMap.size()> 0){
            consumerMap = new Map<Id,account>([select id,ownerId from account where Id IN:oppAccIdsMap.keyset()]);
        }
        if(consumerMap.size()>0){
            for(Account acc:consumerMap.values()){
                acc.OwnerId = oppAccIdsMap.get(acc.id);
                accsToUpdate.add(acc);
            }
        }
        if(accsToUpdate.size()>0){
            recursiveClass.accOwnerUpdate = true;
            database.update(accsToUpdate,false);
        }
    } 
    
    /*************************************************************************************************
* @description This method to create quote on  opportunities when auto enrolled 
* @param - Trigger map
* @story - SFDC-965
* @return Void
* @date - 10-AUG-2020 (Teksystems)
*/
    public static void createQuoteForOLE(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        recursiveClass.createQuoteonOpty= true;
        Set<Id> OLEOptyIds = new Set<Id>();
        set<Id> QLineIds = new set<Id>();
        Map<Id,Opportunity> optyMap = new Map<Id,Opportunity>();
        List<SBQQ__Quote__c> newQuoteCreate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteForQline = new List<SBQQ__Quote__c>();
        for(Opportunity opp:newMap.values()){
            if(String.isNotBlank(opp.Online_Enroll_Status__c) && (opp.Online_Enroll_Status__c == 'Auto Enrolled'  || opp.Online_Enroll_Status__c == 'Complete')&& opp.Online_Enroll_Status__c <> oldMap.get(opp.Id).Online_Enroll_Status__c){
                OLEOptyIds.add(opp.id);  
            }
        }
        if(OLEOptyIds.size()> 0){
            optyMap = new Map<Id,Opportunity>([select id,AccountId,account.BillingCountry,Selected_Payment_Plan__c,of_CB__c,of_CT__c,Promo_Code__c,StageName,Payment_Plan__c,Primary_Contact__c,of_GS__c,Pricebook2Id,Online_Enroll_Status__c  from Opportunity where Id IN: OLEOptyIds]);
        }
        if(optyMap.size()>0){
            for(Opportunity oppVar:optyMap.values()){
                SBQQ__Quote__c quoteVar = new SBQQ__Quote__c();
                quoteVar.SBQQ__Account__c=oppVar.AccountId;
                if(oppVar.Pricebook2Id ==Label.CPQUsaPriceBook){
                    quoteVar.SBQQ__PricebookId__c=Label.CPQUsaPriceBook;
                }
                else{
                    quoteVar.SBQQ__PricebookId__c=Label.CPQIntPriceBook;
                }
                quoteVar.SBQQ__Opportunity2__c=oppVar.id;
                quoteVar.SBQQ__StartDate__c = system.today();
                if(oppVar.StageName =='Enrolled'){
                    quoteVar.SBQQ__Status__c = 'Accepted';
                }
                if(oppVar.StageName =='Partial Online Enroll'){
                    quoteVar.SBQQ__Status__c = 'Draft';
                }
                quoteVar.SBQQ__Primary__c=true;
                if(oppVar.Payment_Plan__c == 'CBR 6 month'){
                    quoteVar.Payment_Plan__c='6-Months Plan';
                }
                else if(oppVar.Payment_Plan__c == 'CBR 12 month'){
                    quoteVar.Payment_Plan__c='12-Months Plan';
                }
                else if(oppVar.Payment_Plan__c == 'CBR 36 month'){
                    quoteVar.Payment_Plan__c='CBR 36 month';
                }else if(oppVar.StageName =='Partial Online Enroll' && oppVar.Online_Enroll_Status__c=='Complete' && oppVar.Payment_Plan__c == 'Care Credit 48 month' ){
          quoteVar.Payment_Plan__c='Care Credit 48 month';
        }
                /* else if(oppVar.Payment_Plan__c == 'Care Credit 12 month' || oppVar.Payment_Plan__c == 'Care Credit 24 month' || oppVar.Payment_Plan__c == 'Care Credit 36 month' || oppVar.Payment_Plan__c == 'Care Credit 48 month'){
quoteVar.Payment_Plan__c= oppVar.Payment_Plan__c;
}*/
                if(oppVar.Payment_Plan__c == 'Pay in Full'){
                    quoteVar.Payment_Plan__c='Pay in Full';
                }
                quoteVar.SBQQ__PrimaryContact__c = oppVar.Primary_Contact__c;
                newQuoteCreate.add(quoteVar);
            }
        }
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        if(newQuoteCreate.size()>0){
            saveResults =  Database.insert(newQuoteCreate,false);
            System.debug('saveResults----'+saveResults); 
        }
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted quote. quote ID: ' + sr.getId());
                QLineIds.add(sr.getId());
                System.debug('qlineids is ' + QLineIds);
            }
        }
        if(QLineIds!=null && !QLineIds.isEmpty()){
        quoteForQline =[select id,SBQQ__Opportunity2__r.of_CT__c,SBQQ__Opportunity2__r.of_CB__c,SBQQ__Opportunity2__r.Promo_Code__c,SBQQ__Opportunity2__r.CB_Storage_Option__c,SBQQ__Opportunity2__r.CT_Storage_Option__c,SBQQ__Opportunity2__r.CT_Value__c,SBQQ__Opportunity2__r.CB_Value__c,SBQQ__Opportunity2__r.Primary_Source__c,SBQQ__Opportunity2__r.Payment_Plan__c,SBQQ__Opportunity2__r.of_Babies__c,SBQQ__Opportunity2__r.Promotion__c,Payment_Plan__c,SBQQ__Opportunity2__r.of_GS__c from SBQQ__Quote__c where id in : QLineIds];
        }
        if(!quoteForQline.isEmpty()){
            createQuoteLineForQuote(quoteForQline);
        } 
    }
    /*************************************************************************************************
* @description This method to create quoteline items on quote when auto enrolled 
* @param - Trigger map
* @story - SFDC-965
* @return Void
* @date - 10-AUG-2020 (Teksystems)
*/
    public static void createQuoteLineForQuote(List<SBQQ__Quote__c> quoteForQline){
        List<SBQQ__QuoteLine__C > newQuoteLineInsertA = new List<SBQQ__QuoteLine__C >();
        //Map<String,Integer> babiesMap = new Map<String,Integer>{'Single'=>1,'Twins'=>2,'Triplets'=>3,'Quadruplets'=>4};
        List<Product2> prdList=Database.query('select id,name,IsActive from Product2 where IsActive=true AND '+System.Label.CPQProductList+'order by name ASC limit 12');
        List<SBQQ__ProductOption__c> prodOptionsList = [select id,Name,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__r.Name = 'CBR Preservation Service'] ;
        Map<String,Id> prodOptionIds = new Map<String,Id>();
        if(prodOptionsList!=null && !prodOptionsList.isEmpty()){
            for(SBQQ__ProductOption__c option:prodOptionsList){
                prodOptionIds.put(option.SBQQ__OptionalSKU__r.Name,option.id);
            }
        }
        Map<id,List<SBQQ__QuoteLine__C>> quoteToqline = new map<id,List<SBQQ__QuoteLine__C>>();
        List<SBQQ__QuoteLine__C> toUpdateQline=new List<SBQQ__QuoteLine__C>();
        String countVar='';
        List<String> prodNames = system.Label.ProductNames.split(';');
        //  Map<string,Product2> productMap = new Map<String,Product2>();
        for(SBQQ__Quote__c quotevar:quoteForQline){
            if(quotevar.SBQQ__Opportunity2__r.CB_Value__c > 0){
                prodNames.add('Cord Blood Processing and Banking Fee');
                if(quotevar.SBQQ__Opportunity2__r.CB_Storage_Option__c.contains('18 Years')){
                    prodNames.add('Cord Blood Storage 18 Year Plan');
                }
                else if(quotevar.SBQQ__Opportunity2__r.CB_Storage_Option__c.contains('Lifetime')){
                    prodNames.add('Cord Blood Storage Lifetime Plan');
                }
                else if(quotevar.SBQQ__Opportunity2__r.CB_Storage_Option__c =='Annual Storage'){
                    prodNames.add('Cord Blood Annual Storage Fee');
                }
            }
            if(quotevar.SBQQ__Opportunity2__r.CT_Value__c > 0){
                prodNames.add('Cord Tissue Processing and Banking Fee');
                if(quotevar.SBQQ__Opportunity2__r.CT_Storage_Option__c.contains('18 Years')){
                    prodNames.add('Cord Tissue Storage 18 Year Plan');
                }
                else if(quotevar.SBQQ__Opportunity2__r.CT_Storage_Option__c.contains('Lifetime')){
                    prodNames.add('Cord Tissue Storage Lifetime Plan');
                }
                else if(quotevar.SBQQ__Opportunity2__r.CT_Storage_Option__c =='Annual Storage'){
                    prodNames.add('Cord Tissue Annual Storage Fee');
                }
            }
            if(quotevar.SBQQ__Opportunity2__r.of_GS__c > 0){
                prodNames.add('Genetic Screening');
            }
        }
        for(SBQQ__Quote__c  qVar:quoteForQline ){
            newQuoteLineInsertA = new List<SBQQ__QuoteLine__C >();
            Boolean repeatClient = false;
            String storageOption = null;
            for(Product2 prd:prdList){
                if(prodNames.contains(prd.name)){
                    if(prd.name==System.Label.CPQCbpAndBanFee  || prd.name==System.Label.CPQCbAnnualStorageFee  || prd.Name == 'Cord Blood Storage 18 Year Plan' || prd.Name == 'Cord Blood Storage Lifetime Plan')  
                    { 
                        if(prd.Name == 'Cord Blood Storage 18 Year Plan'){
                            storageOption ='18 Years';
                        }
                        else if(prd.name==System.Label.CPQCbAnnualStorageFee){
                            storageOption ='Annual Storage';
                        }
                        else if( prd.Name == 'Cord Blood Storage Lifetime Plan'){
                            storageOption ='Lifetime';
                        }
                        countVar=qVar.SBQQ__Opportunity2__r.of_CB__c;
                        
                    }
                    else if (prd.name==System.Label.CPQCtpAndBanFee|| prd.name==System.Label.CPQCtAnnualStorageFee || prd.Name =='Cord Tissue Storage 18 Year Plan' || prd.Name =='Cord Tissue Storage Lifetime Plan'){
                        countVar=qVar.SBQQ__Opportunity2__r.of_CT__c;
                        if(prd.Name == 'Cord Tissue Storage 18 Year Plan'){
                            storageOption ='18 Years';
                        }
                        else if(prd.name==System.Label.CPQCtAnnualStorageFee){
                            storageOption ='Annual Storage';
                        }
                        else if( prd.Name == 'Cord Tissue Storage Lifetime Plan'){
                            storageOption ='Lifetime';
                        }
                    }
                    else if(prd.Name == system.label.ReadyGen_Genetic_Screening){
                        countVar = String.valueOf(qVar.SBQQ__Opportunity2__r.of_GS__c);
                    }
                    else {
                        countVar='1';
                    } 
                    
                    SBQQ__QuoteLine__C qlineVar = new SBQQ__QuoteLine__C();
                    qlineVar.SBQQ__Product__c =prd.id;
                    
                    qlineVar.Storage_Fee_Option__c = storageOption;
                    qlineVar.SBQQ__Quote__c =qVar.id; 
                    qlineVar.SBQQ__Quantity__c =decimal.valueOf(countVar);
                    qlineVar.SBQQ__PricingMethod__c='List';
                    qlineVar.Promo_Code__c=qVar.SBQQ__Opportunity2__r.Promo_Code__c;
                    if(prodOptionIds!=null && !prodOptionIds.isEmpty() && prd.Name != 'CBR Preservation Service'){
                        qlineVar.SBQQ__ProductOption__c = prodOptionIds.get(prd.NAme);}
                    if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'CBR 6 month'){
                        qlineVar.Payment_Plan_Options__c='6 Month Plan Admin Fee';
                    }
                    if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'CBR 12 month'){
                        qlineVar.Payment_Plan_Options__c='12 Month Plan Admin Fee';
                    }
                    if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'CBR 36 month'){
                        qlineVar.Payment_Plan_Options__c='36 Month Plan Admin Fee';
                    }
                    if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Pay in Full'){
                        qlineVar.Payment_Plan_Options__c='Pay in Full';
                    }
          if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Care Credit 48 Month'){
                        qlineVar.Payment_Plan_Options__c='Care Credit 48 Month Plan';
                    }
                    /*  if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Care Credit 12 month'){
qlineVar.Payment_Plan_Options__c='Care Credit 12 Month Plan';
}
if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Care Credit 24 month'){
qlineVar.Payment_Plan_Options__c='Care Credit 24 Month Plan';
}
if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Care Credit 36 month'){
qlineVar.Payment_Plan_Options__c='Care Credit 36 Month Plan';
}*/ 
if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'Care Credit 48 month'){
qlineVar.Payment_Plan_Options__c='Care Credit 48 Month Plan';
}
                    if(qVar.SBQQ__Opportunity2__r.Primary_Source__c=='I\'m a Current Client' && ((String.isBlank(qVar.SBQQ__Opportunity2__r.Promo_Code__c) && String.isBlank(qVar.SBQQ__Opportunity2__r.Promotion__c)))){
                        qlineVar.Corporate_Discount__c = 'Repeat Client';
                        if(qVar.SBQQ__Opportunity2__r.of_Babies__c!='Single'){
                            qlineVar.Do_Not_Apply_Discount_by_Quantity__c = true;}
                        if(qVar.SBQQ__Opportunity2__r.Payment_Plan__c == 'CBR 36 month'){
                            qlineVar.Corporate_Discount__c = null;
                        }
                    }
                    newQuoteLineInsertA.add(qlineVar);
                }
            }
            quoteToqline.put(qVar.id,newQuoteLineInsertA);
        }
        if(!quoteToqline.isEmpty()){
            for (List<SBQQ__QuoteLine__C> oppsList : quoteToqline.values())
            {
                toUpdateQline.addAll(oppsList);
            }
        }
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        if(toUpdateQline.size()>0){
            saveResults =  Database.insert(toUpdateQline,false);
            System.debug('saveResults----'+saveResults);
        } 
    }
    
    /*************************************************************************************************
* @description This method to publish platform event when opty is stored 
* @param - Trigger map
* @story - SFDC-1199
* @return Void
* @date - 21-OCT-2020 (Teksystems)
*/
    public static void sendOptyStoredAxPfEvt(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        recursiveClass.optystoredPfevent= true;
        List<Message__c> msgList = new List<Message__c>();
        for(Opportunity opty:newMap.values()){   
            if(!opty.Storage_Sent_to_AX__c && !opty.Reopened_after_Stored__c && !String.isBlank(opty.AX_Order_Id__c) && opty.Status__c=='Stored' &&  opty.Status__c <> oldMap.get(opty.Id).Status__c){
                PlatformEventWrapper.SendOpportunityStoredToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityStoredToAXEvent();
                Message__c msgRec=new Message__c();
                msgRec.Event_Type__c='Send Opportunity Stored ToAX Event';
                optyWrp.AxOpportunityId=opty.id;
                msgRec.Payload__c=JSON.serialize(optyWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                msgRec.TimeStamp__c = system.now().addMinutes(15);
                msgList.add(msgRec);  
            }
        }  
        if(!msgList.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert(msgList,false);
            system.debug('punlish list ::'+msgList);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for opty stored.1199');
                    // recursiveClass.facConPfevent= true;
                } else {
                    string ErrDetail='Error returned for opty stored.1199';
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Send Opportunity Stored ToAX Event', 'Apex Event', ErrDetail, false, false);
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
* @description This method to publish platform event when opty is Enrolled 
* @param - Trigger map
* @story - SFDC-1152
* @return Void
* @date - 27-OCT-2020 (Teksystems)
*/
    public static void sendOptyEnrolledAxPfEvt(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        recursiveClass.optyenrolledPfevent= true;
        List<Message__c> messageList = new List<Message__c>();
        for(Opportunity opty:newMap.values()){   
            if(opty.StageName=='Enrolled' && ( opty.StageName <> oldMap.get(opty.Id).StageName || recursiveClass.optyEnrolledOLE )){
                 
                PlatformEventWrapper.SendOpportunityEnrolledToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityEnrolledToAXEvent();
                Message__c msgRec=new Message__c();
                msgRec.Event_Type__c='Send Opportunity Enrolled ToAX Event';
                optyWrp.AxOpportunityId=opty.id;
                msgRec.Payload__c=JSON.serialize(optyWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                messageList.add(msgRec);  
            }
        }  
        recursiveClass.optyEnrolledOLE = false;
        if(!messageList.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(messageList,false);
            
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for opty enrolled.1152'); 
                } else {
                    string ErrDetail='Error returned for opty enrolled.1152';
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Send Opportunity Enrolled ToAX Event', 'Apex Event', ErrDetail, false, false);
                    system.debug('cbrutility'+cbr);
                    cbrErrorLog.add(cbr);
                    system.debug('cbrutilityList'+cbrErrorLog);
                    
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
            
        }
        
    }
    //SFDC - 1410 start
    public static void sendABOEvent(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        //recursiveClass.oppPrimaryChangeABO = true;
        Set<String> optyAxIds = new Set<String>();
        Map<id,Message__c> msgRecs = new Map<id,Message__c>();
        Map<String,Message__c> msgMap = new Map<String,Message__c>();
        List<Message__c> msgList = new List<Message__c>();
        Map<Id,String> oppAxIds = new Map<id,String>();
        for(Opportunity opty:newMap.values()){
            if( opty.StageName=='Enrolled' && String.isNotBlank(opty.AX_Order_Id__c) && ((userInfo.getFirstName() !='MulesoftUser'&&(opty.StageName <> oldMap.get(opty.Id).StageName || opty.of_Babies__c <> oldMap.get(opty.Id).of_Babies__c || opty.AccountId <> oldMap.get(opty.id).AccountId || opty.Adoption_Type__c <> oldMap.get(opty.Id).Adoption_Type__c || opty.Due_Date__c <> oldMap.get(opty.Id).Due_Date__c )) || ( opty.AX_Order_Id__c <> oldMap.get(opty.id).AX_Order_Id__c))){
                optyAxIds.add(opty.AX_Order_Id__c);
                system.debug(' optyAxIds.add(opty.AX_Order_Id__c);'+ opty.AX_Order_Id__c);
                oppAxIds.put(opty.id,opty.AX_Order_Id__c);
            }
        }
        if(optyAxIds!=null && !optyAxIds.isEmpty()){
            msgRecs = new Map<id,Message__c>([select id,TimeStamp__c,Ax_order_id__c from Message__c where Ax_order_id__c in:optyAxIds AND status__c='New']);
        }
        if(msgRecs!=null && !msgRecs.isEmpty()){
            for(Message__c msg:msgRecs.values()){
                msgMap.put(msg.Ax_order_id__c,msg);
            }
        }
        for(Opportunity opty:newMap.values()){
            if(oppAxIds!=null && oppAxIds.containsKey(opty.id) && (( !msgMap.containsKey(opty.Ax_order_id__c) && String.isNotblank(opty.Ax_order_id__c) && msgMap!=null)) || msgMap ==null){
                Message__c msgRec = new Message__c();
                msgRec.Event_Type__c = 'QucikABO Enrolled Opty';
                msgrec.TimeStamp__c = system.now().addMinutes(35);
                PlatformEventWrapper.sencABOEvent ordrIdMap = new PlatformEventWrapper.sencABOEvent();
                
                ordrIdMap.axOrderId = opty.Ax_order_id__c;
                msgRec.Payload__c=JSON.serialize(ordrIdMap);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                msgRec.Ax_order_id__c = opty.Ax_order_id__c;
                msgList.add(msgRec); 
            }
        }
        if(msgList!=null && !msgList.isEmpty()){
            database.insert(msgList,false);
            
        }
    }
    //SFDC - 1410 End
    //SFDC - 1366 Start
    public static void sendOptyClosedAxPfEvt(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
        recursiveClass.optyClosedToAX= true;
        List<Message__c> messageList = new List<Message__c>();
        Map<Id,User> userMap = new Map<Id,User>();
        
        for(Opportunity opty:newMap.values()){   
            if(opty.StageName=='Closed Lost' &&  opty.StageName <> oldMap.get(opty.Id).StageName && !String.isBlank(opty.AX_Order_Id__c) && Userinfo.getName()!='MulesoftUser MulesoftUser'){
                PlatformEventWrapper.SendOpportunityClosedToAXEvent optyWrp=new PlatformEventWrapper.SendOpportunityClosedToAXEvent();
                Message__c msgRec=new Message__c();
                msgRec.Event_Type__c='Send Opportunity Closed ToAX Event';
                optyWrp.AxOpportunityId=opty.id;
                msgRec.Payload__c=JSON.serialize(optyWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                messageList.add(msgRec);  
            }
        }  
        
        if(!messageList.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert(messageList,false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for opty Closed'); 
                } else {
                    string ErrDetail='Error returned for opty Closed';
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Send Opportunity Closed ToAX Event', 'Apex Event', ErrDetail, false, false);
                    system.debug('cbrutility'+cbr);
                    cbrErrorLog.add(cbr);
                    system.debug('cbrutilityList'+cbrErrorLog);
                    
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
            
        }
        
    }
    //SFDC - 1366 End
    public static void updateBillToShipTo(Map<Id,Opportunity> newMap, Map<Id,opportunity> oldMap){
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp:newMap.values()){
            if(recursiveClass.OleEnrolled && opp.stageName =='Enrolled' && opp.Completed_Flag__c ){
                accIds.add(opp.AccountId);
            }
        }
        if(accIds!=null && !accIds.isEmpty())
        {
            
            Map<Id,OpportunityContact__c> oppContacts = new Map<Id,OpportunityContact__c>([select id,personAccount__c,Bill_To__c,Ship_To__c from OpportunityContact__c where personAccount__c IN:accIds AND primary__c = true]);
            if(oppContacts!=null){
                for(OpportunityContact__c oppcon:oppContacts.values()){
                    oppcon.Bill_To__c = true;
                    oppcon.Ship_To__c = true;
                }
                database.update(oppContacts.values(),false);
                recursiveClass.OleEnrolled = false;
            }
        }
    }
    //This method is to update delivering hospital count on facility account.story no 1547,1548
    public static void updateDeliveringHospFacility(List<opportunity> optyList){
        set<id> delvngHopsIds = new set<id>();
        map<id,opportunity> oldMap = (map<id,opportunity>) trigger.oldMap;
        for(Opportunity opp:optyList){
            if(trigger.isInsert && opp.Delivering_Hospital__c !=null){
                delvngHopsIds.add(opp.Delivering_Hospital__c);
            }
            
            if(Trigger.isUpdate && (opp.Delivering_Hospital__c != oldMap.get(opp.id).Delivering_Hospital__c || opp.Status__c != oldMap.get(opp.id).Status__c) 
               && opp.Delivering_Hospital__c !=null){
                   delvngHopsIds.add(opp.Delivering_Hospital__c);
                   if(oldMap.get(opp.id).Delivering_Hospital__c != Null){
                       delvngHopsIds.add(oldMap.get(opp.id).Delivering_Hospital__c);  
                   }
                   
               }
        }
        if(!delvngHopsIds.isEmpty() && !system.isBatch()){
            UpdateOptyCountOnFacilityAccount.UpdateOptyCountOnFacilityAccountMethod(delvngHopsIds);
        }
        
    }
    
    //This method is to update Provider Account count on provider account.story no 1519,1520
    public static void updateProviderRecords(Map<Id,Opportunity> newMap, Map<Id,opportunity> oldMap){
        set<id> optySetids = new set<id>();
        for(Opportunity opty:newMap.values()){   
            if(opty.Status__c != oldMap.get(opty.id).Status__c){
                optySetids.add(opty.id);
            }
        }
        if(!optySetids.isEmpty() && !system.isBatch()){
            UpdateOptyCountOnPrimaryProvider.UpdateOptyCountOnPrimaryProviderMethod(optySetids,true);
        }
    }
   
    //This Method is to update opty name field. SFDC - 1725
    public static void updateoptyName(Map<id,Opportunity> newMap){
        if(newMap!=null){
            for(Opportunity opp:newMap.values()){
                if(opp.Name != opp.Opportunity_Number__c){
                    opp.Name = opp.Opportunity_Number__c;
                }
            }
        }
    }
    
    /*************************************************************************************************
* @description This method is used to create task if primary contact DOB is less than 18 years old.
* @param - Trigger.new
* @story - SFDC-1860
* @return Void
* @date - 27-Jul-2021 (Teksystems)
*/
    public static void createTaskBasedPrimaryContDOB(Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap){
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity oppId:newMap.values()){
            if(oldMap.get(oppId.id).Profile_Complete__c!= oppId.Profile_Complete__c&& oppId.Profile_Complete__c){
                opportunityIds.add(oppId.id);
            }
        }
        if(!opportunityIds.isEmpty()){
            CreateTaskBasedOnPrimaryContactDOB.validateAcctDoB(opportunityIds);
        } 
    }
    /*************************************************************************************************
* @description This method is used to send FAX email for Enrolled Opportunities.
* @param - Trigger.new
* @story - SFDC-1955
* @return Void
* @date - 31-AUG-2021 (Teksystems)
*/

    public static void OpportunitySendFaxEmail(Map<id,Opportunity> newMap,Map<id,Opportunity> oldMap){
        String invoke=system.label.SendFaxEmail;
        
        Map<id,Opportunity> finalOpty=new Map<id,Opportunity>();
        if(!newMap.isEmpty()){
            if(test.isRunningTest() ||invoke=='True'){
                for(Opportunity opp:newMap.values()){
                    if(Trigger.isUpdate && ((opp.Status__c != oldMap.get(opp.id).Status__c) && (opp.Status__c=='Enrolled' || opp.Status__c=='Stored') && !recursiveClass.optySendFaxEmail) ){
                        finalOpty.put(opp.id,opp);
                    }
                }   
            }
        }   
        system.debug('The opts sending are-->'+finalOpty);
        if(!finalOpty.isEmpty()){
            OpportunitySendFaxEmail.sendEmail(finalOpty);
            recursiveClass.optySendFaxEmail=true;
        }
    }
}