public class kitsInfo{
    @AuraEnabled(cacheable=true)
    public static Integer orderKits(String facilityId,Integer kitcount){
        system.debug('kitcount'+kitcount);
        system.debug('facilityId'+facilityId);
        try{
            Account acc = [Select id ,Name,SCSS_Facility_Id__c,Kit_Stocking__c from account where id =:facilityId and recordtype.Name = 'Facility' LIMIT 1];
            orderKitswrapper wrapper = new orderKitswrapper();
            Order_kit_request order_kit_request = new Order_kit_request();
            order_kit_request.assignedToFacility = acc.SCSS_Facility_Id__c;
            order_kit_request.transferQuantity = kitcount;
            wrapper.Order_kit_request = order_kit_request;
            String strBody = JSON.serialize(wrapper);
            
            system.debug('strBody--'+strBody);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(String.format('callout:Kits_Info/{0}',new String[]{'order'}));
            req.setHeader('Authorization','Basic');
            req.setHeader('app_name','Salesforce_Mobile');
            req.setHeader('transaction_id',acc.SCSS_Facility_Id__c+system.today());
            req.setHeader('Content-Type', 'application/json');
            req.setBody(strBody);
            req.setMethod('POST');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Integer status = res.getStatuscode();
            return status;
        }
        catch(Exception ex){
            system.debug('AuraMesseage'+ex.getMessage()+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
            
        }
        
    }
    //userId=ebreder
    @AuraEnabled(cacheable=true)
    public static List<Kits_response> getKitList(String facilityId){
        system.debug('facility id'+facilityId);
        try{
            List<Kits_response> kitList = new List<Kits_response>();
            HttpRequest req = new HttpRequest();
            User u = [select id,AD_Login__c from user where id =: Userinfo.getUserId() LIMIT 1];
            req.setEndpoint(String.format('callout:Kits_Info?{0}={1}',new String[]{'userId',u.AD_Login__c}));
            req.setMethod('GET');
            req.setHeader('Authorization','Basic');
            req.setHeader('app_name','Salesforce_Mobile');
            req.setHeader('transaction_Id','ebreder'+system.today());
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() ==200){
                String jsonStr = res.getbody();
                kitsData tempVal = new kitsData();
                tempVal = (kitsData)JSON.deserialize(jsonStr,kitsData.class);
                system.debug('tempVal=='+tempVal);
                kitList.addAll(tempVal.Kits_response);
                // system.debug('kitList=='+kitList);
            }
            system.debug('res.getStatusCode()--'+res.getStatusCode());
            //system.debug('res.getbody()--'+res.getbody());
            Map<String,Account> accIdName = new Map<String,Account>();
            Set<String> scssids = new Set<String>();
            system.debug('kitList---size'+kitList.size());
            for(Kits_response kitrec:kitList){
                scssids.add(kitrec.assignedToFacility);
            }
            Set<Id> providerIds = new Set<Id>();
            Id facilityId1 =null;
            Set<String> providerPrimaryFacIds = new Set<String>();
            List<Account> accountsList = [select Id,name,recordtype.name,SCSS_Facility_Id__c,SCSS_Provider_Id__c ,BillingStreet,BillingState,BillingCountry,BillingCity,BillingPostalCode from account where id =:facilityId or SCSS_Facility_Id__c =:scssids  ];
            if(accountsList!=null && !accountsList.isEmpty()){
                for(Account acc:accountsList){
                    if(acc.Recordtype.name =='Provider'){
                        
                        providerIds.add(acc.Id);
                    }
                    else if(acc.Recordtype.name =='Facility' && acc.id ==facilityId ){
                        facilityId1 = facilityId;
                    }
                }
            }
            if(providerIds!=null && !providerIds.isEmpty()){
                for(Provider_Facility__c proFac:[select id,SCSS_Provider_Id__c,Facility__c,Facility_Name__c,SCSS_Facility_Id__c,Provider__c from Provider_Facility__c where Provider__c =:providerIds and Primary__c = true]){
                    providerPrimaryFacIds.add(proFac.SCSS_Facility_Id__c);
                }
            }
            system.debug('providerIds==='+providerIds);
            system.debug('facilityId1==='+facilityId1);
            for(Account acc:accountsList){
                if((facilityId1!=null && facilityId1 ==acc.id)  ||(facilityId!=null && providerIds!=null &&  providerPrimaryFacIds.contains(acc.SCSS_Facility_Id__c)) || facilityId==null){
                    accIdName.put(acc.SCSS_Facility_Id__c,acc);  
                }
            }
            system.debug('accIdName---'+accIdName);
            
            
            system.debug('providerPrimaryFacIds=='+providerPrimaryFacIds);
            List<Kits_response> kitsFinal = new List<Kits_response>();
            
            for(Kits_response kitWrapper:kitList){
                
                if(accIdName!=null && accIdName.containsKey(kitWrapper.assignedToFacility)){
                    Kits_response tempWrap = new Kits_response();
                    tempWrap.assignedToFacility = kitWrapper.assignedToFacility;
                    tempWrap.depositId = kitWrapper.depositId;
                    Date expiryDate= Date.valueOf(kitWrapper.expirationDate);
                    tempWrap.expirationDate = expiryDate.format();
                    tempWrap.daysToExpire = system.today().daysBetween(date.valueOf(kitWrapper.expirationDate));
                    Account acc = accIdName.get(kitWrapper.assignedToFacility);
                    tempWrap.facilityAddress = acc.BillingStreet +','+acc.BillingCity+','+acc.BillingState+','+acc.BillingCountry+','+acc.BillingPostalCode; 
                    tempWrap.facilityName = acc.Name;
                    tempWrap.recType = acc.Recordtype.Name;
                    tempWrap.facilityId=acc.Id;
                    system.debug('acc.recordtype.name' +acc.recordtype.name);
                    if(providerPrimaryFacIds!=null && providerPrimaryFacIds.contains(kitWrapper.assignedToFacility)){
                        tempWrap.recType = 'Provider';
                        system.debug('chcek1');
                        kitsFinal.add(tempWrap);
                    }
                    else if(providerPrimaryFacIds==null ||providerPrimaryFacIds.isEmpty()){ 
                        tempWrap.recType = 'Facility';
                        kitsFinal.add(tempWrap);}	
                    system.debug('before if');
                }
            }
            system.debug(kitsFinal.size());
            return kitsFinal;}
        catch(Exception ex){
            system.debug('AuraMesseage1'+ex.getMessage()+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static void invokeKitsAPI(String facilityId){
        List<Barcode_Scan__c > countList= new List<Barcode_Scan__c >();
        set<id > transferSet= new set<id >();
        string SCSSfacilityID='';
        
        if(!String.isEmpty(facilityId)){
            for(Barcode_Scan__c eachRec:[select id,Account__c,Account__r.SCSS_Facility_Id__c, Activity__c, Barcode__c from Barcode_Scan__c where Account__c =:facilityId and SentToAX__c=false]){
                SCSSfacilityID=eachRec.Account__r.SCSS_Facility_Id__c;
                if(eachRec.Activity__c=='Count'){
                    countList.add(eachRec);
                }
                if(eachRec.Activity__c=='Transfer'){
                    transferSet.add(eachRec.id);
                }
            }
        }
        If(countList.size()>0){
            kitCountRequest(countList,SCSSfacilityID,facilityId);
        }
        If(transferSet.size()>0){
            system.debug('transferSet size'+transferSet.size());
            transferKits(SCSSfacilityID,facilityId);
            //system.debug('transferList'+transferList);
        } 
    }
    @future(callout=true)
    public static void transferKits(String SCSSfacilityID, String facilityId){
        if(!String.isEmpty(SCSSfacilityID) && !String.isEmpty(facilityId)){
            system.debug('Inside---->transfer');
            List<Barcode_Scan__c > finaltransferKits= new  List<Barcode_Scan__c >();
            list<cbr_Error_Log__c> cbrLst = new list<cbr_Error_Log__c>();
            try{
                String userId=[select id,AD_Login__c from user where id =: Userinfo.getUserId() LIMIT 1]?.AD_Login__c;
                for(Barcode_Scan__c eachkitTransfer:[select id,Account__c,Account__r.SCSS_Facility_Id__c, Activity__c, Barcode__c from Barcode_Scan__c where Account__c =:facilityId and SentToAX__c=false and Activity__c='Transfer']){
                    if(eachkitTransfer.Barcode__c!=null && userId!=null){
                        transferkitwrapper wrapperTransferKit= new transferkitwrapper();
                        transfer_kit_request transferwrapper = new transfer_kit_request();
                        transferwrapper.assignedToFacilityId=SCSSfacilityID;
                        transferwrapper.userId=userId;
                        transferwrapper.kitSerial=eachkitTransfer.Barcode__c;
                        wrapperTransferKit.transfer_kit_request=transferwrapper;
                        String strBody = JSON.serialize(wrapperTransferKit);
                        system.debug('strBody--'+strBody);
                        HttpRequest req = new HttpRequest();
                        req.setEndpoint(String.format('callout:Kits_Info/{0}',new String[]{'transfer'}));
                        req.setHeader('Authorization','Basic');
                        req.setHeader('app_name','Salesforce_Mobile');
                        req.setHeader('transaction_id',String.valueOf(system.now()));
                        req.setHeader('Content-Type', 'application/json');
                        req.setBody(strBody);
                        system.debug('reqstrBody--'+strBody);
                        req.setMethod('POST');	
                        system.debug('request--'+req);
                        Http http = new Http();
                        HTTPResponse res = http.send(req);
                        Integer status = res.getStatuscode();
                        system.debug('Transfer the response code is'+res.getStatuscode());
                        system.debug('Transfer the body is'+res.getBody());
                        system.debug('Transfer the headers are'+res.getHeaderKeys());
                        system.debug('Status----'+status);
                        if(status != 200){
                            cbrLst.add(UtilityClass.logErrors(null, 'Kits transfer Error Handle', 'Apex Error', 'Request is'+strBody+'__ Response is'+res.getStatus()+'__'+res.getStatusCode(), false, false));
                        }
                        else if(status == 200){
                            eachkitTransfer.SentToAX__c=true;
                            finaltransferKits.add(eachkitTransfer);
                        }
                    }
                } 
                if(finaltransferKits.size()>0){
                    update finaltransferKits;
                }
                if(!cbrLst.isEmpty()){
                    insert cbrLst;
                }
            }
            catch(Exception ex){
                system.debug('The error message is'+ex.getMessage()+'trace is'+ex.getStackTraceString());  
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static void kitCountRequest(List<Barcode_Scan__c > countRecs,String SCSSfacilityID, String facilityID){
        if(!countRecs.isEmpty() && !String.isEmpty(SCSSfacilityID) && !String.isEmpty(facilityID)){
            try{
                List<kitCountItem> kitCounts= new List<kitCountItem>();
                for(Barcode_Scan__c eachCountKit:countRecs){
                    kitCountItem eachkit=new kitCountItem();
                    eachkit.kitQuantity=1;
                    eachkit.kitSerial=eachCountKit.Barcode__c;
                    kitCounts.add(eachkit);
                }
                kitCountwrapper wrapperKitCount= new kitCountwrapper();
                kit_count_request kitCountWrapper = new kit_count_request();
                kitCountWrapper.facilityId=SCSSfacilityID;
                kitCountWrapper.latitude='0';
                kitCountWrapper.longitude='0';
                kitCountWrapper.transactionDate=String.valueof(System.today());
                kitCountWrapper.userId=[select id,AD_Login__c from user where id =: Userinfo.getUserId() LIMIT 1]?.AD_Login__c;
                kitCountWrapper.kitCountItem=kitCounts;
                wrapperKitCount.kit_count_request=kitCountWrapper;
                String strBody = JSON.serialize(wrapperKitCount);
                system.debug('strBody--'+strBody);
                HttpRequest req = new HttpRequest();
                req.setEndpoint(String.format('callout:Kits_Info/{0}',new String[]{'count'}));
                req.setHeader('Authorization','Basic');
                req.setHeader('app_name','Salesforce_Mobile');
                req.setHeader('transaction_id',String.valueOf(system.now()));
                req.setHeader('Content-Type','application/json');
                req.setBody(strBody);
                system.debug('the hitting request body'+strBody);
                req.setMethod('POST');
                Http http = new Http();
                HTTPResponse res = http.send(req);
                Integer status = res.getStatuscode();
                system.debug('the response code is'+res.getStatuscode());
                system.debug('the body is'+res.getBody());
                system.debug('the headers are'+res.getHeaderKeys());
                if(status != 200){
                    list<cbr_Error_Log__c> cbrLst = new list<cbr_Error_Log__c>();
                    cbrLst.add(UtilityClass.logErrors(null, 'Kits Count Error Handle', 'Apex Error','Request is'+strBody+'__ Response is'+res.getStatus()+'__'+res.getStatusCode(), false, false));
                    insert cbrLst;
                }
                else if(status == 200){
                    List<Barcode_Scan__c > finalKits= new  List<Barcode_Scan__c >();
                    for(Barcode_Scan__c eachRec:countRecs){
                        eachRec.SentToAX__c=true;
                        finalKits.add(eachRec);
                    }
                    if(finalKits.size()>0){
                        update finalKits;
                    }
                    
                }
            }
            catch(Exception ex){
                
                system.debug('The error message is'+ex.getMessage()+'trace is'+ex.getStackTraceString());
                
            }
        }  
    }
    public class kitsData{
        @AuraEnabled
        public List<Kits_response> Kits_response{get;set;}
    }
    
    public class Kits_response {
        @AuraEnabled
        public String assignedToFacility{get;set;}
        @AuraEnabled
        public String boxId{get;set;}
        @AuraEnabled
        public String depositId{get;set;}
        @AuraEnabled
        public String expirationDate{get;set;}
        @AuraEnabled
        public String latitude{get;set;}
        @AuraEnabled
        public String longitude{get;set;}
        @AuraEnabled
        public String product{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String transactionDate{get;set;}
        @AuraEnabled
        public String facilityName{get;set;}
        @AuraEnabled
        public String facilityAddress{get; set;}
        @AuraEnabled
        public Integer daysToExpire{get; set;}
        @AuraEnabled
        public String recType{get;set;}
        @AuraEnabled
        public String facilityId{get;set;}
    }
    public class orderKitswrapper{
        public order_kit_request order_kit_request;
    } 
    public class order_kit_request{
        @AuraEnabled
        public String assignedToFacility;
        @AuraEnabled
        public Integer transferQuantity;
        
    }
    public class transfer_kit_request{
        @AuraEnabled
        public String assignedToFacilityId;
        @AuraEnabled
        public string userId;
        @AuraEnabled
        public String kitSerial;
    }
    
    public class kitCountwrapper{
        public kit_count_request kit_count_request;
    } 
    public class transferkitwrapper{
        public transfer_kit_request transfer_kit_request;
    }
    public  class kit_count_request {
        @AuraEnabled
        public String facilityId;	//1-1G9EY8
        @AuraEnabled
        public String latitude;	//0
        @AuraEnabled
        public String longitude;	//0
        @AuraEnabled
        public String transactionDate;	//2022-01-06T05:11:14.492266Z
        @AuraEnabled
        public String userId;	//ebreder
        @AuraEnabled
        public kitCountItem[] kitCountItem;
    }
    public class kitCountItem {
        @AuraEnabled
        public Integer kitQuantity;	//1
        @AuraEnabled
        public String kitSerial;	//440000199860
    }
}