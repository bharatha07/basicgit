/**************************************************************************************************************************************
*Component Name : updatepayableStatusButton_Batch 
*Developed By   : TEKsystems
*Description    : This batch class will update the status of payable from Pending Accounting to Needs Attention by validating CBRPayTO record.                  
*User Story     :  SFDC-1545
**********************************************************************************************************************************/
global class updatepayableStatusButton_Batch  implements Database.Batchable <sObject>,Database.Stateful{
    List<String> errors = new List<String>();
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query='';
        //Getting opportunity record where status is stored
        query='select id,HPN_Provider_Agreement__c,HPN_Provider_Agreement__r.Agreement__c,Provider_ID__c,Opportunity__c from Payable__c where Status__c=\'Pending Accounting\' and Provider_ID__c!=null and HPN_Provider_Agreement__c!=null';
        
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Payable__c> scope){
        system.debug('The payable  records are--->'+scope);
        system.debug('The payable records size--->'+scope.size());
        set<id> prdID = new set<id>();
        set<id> ActvPA = new set<id>();
        List<id> finalpayableid = new List<id>();
        List<Payable__c> finalUpdateList= new List<Payable__c>();
        Map<id,Payable__c> finalPayables = new Map<id,Payable__c>();
        List<Payable__c> payablesWithNullPayto= new List<Payable__c>();
        List<Payable__c> agreementpayables= new List<Payable__c>();
        Map<Id,Provider_Agreement__c> provAgrMap = new Map<Id,Provider_Agreement__c>();
        Map<Id,CBR_PAY_TO__c> activePayTo = new Map<Id,CBR_PAY_TO__c>();
        Map<Id,CBR_PAY_TO__c> provAgrPayTo = new Map<Id,CBR_PAY_TO__c>();
        Map<Id,Id> mappayableprovider = new Map<Id,Id>();
        Map<Id,Id> mapproviderAgr = new Map<Id,Id>();
        
        if(scope!=null && !scope.isEmpty()){
            for(Payable__c pays:scope){
                prdID.add(pays.Provider_ID__c);
                mappayableprovider.put(pays.Provider_ID__c,pays.id);
            } 
        }
        system.debug('The providers are-->'+prdID);
        provAgrMap= new Map<Id,Provider_Agreement__c>([select id,Name,Provider__c,Agreement__c,Agreement__r.CBR_PAY_TO__c from Provider_Agreement__c where Provider__c=:prdID and Active_HPNFlag__c=true]);
        system.debug('The provider Agreements are-->'+provAgrMap);
        for(Provider_Agreement__c pca:provAgrMap.values()){
            mapproviderAgr.put(pca.id,pca.provider__c);
        }
        system.debug('The map is-->'+provAgrMap);
        activePayTo = new Map<Id,CBR_PAY_TO__c>([select id,name,Provider_Agreement__c,Active__c,Address__c,Address_2__c,City__c,Country__c,State__c,Tax_ID__c,Zip_Code__c from CBR_PAY_TO__c where Active__c=true and  CBR_PAY_TO__c.Provider_Agreement__c!=null and Provider_Agreement__c=:provAgrMap.keyset()]);
        system.debug('The Pay To\'s are-->'+activePayTo);
        if(activePayTo!=null && !activePayTo.isEmpty()){
            for(CBR_PAY_TO__c pT:activePayTo.values()){
                provAgrPayTo.put(pT.Provider_Agreement__c,pT); // Hold key as provider id and values as provider_agreement records
                ActvPA.add(pT.Provider_Agreement__c);
            }
        }
        system.debug('The provAgrPayTo is-->'+provAgrPayTo);
        payablesWithNullPayto=new List<Payable__c>([select id,name,Status__c,CBR_PAY_TO__r.Address__c,CBR_PAY_TO__r.City__c,CBR_PAY_TO__r.Country__c,CBR_PAY_TO__r.Zip_Code__c,CBR_PAY_TO__r.Tax_ID__c,CBR_PAY_TO__r.State__c from Payable__c where CBR_PAY_TO__c=null and Id=:scope]);
        system.debug('the payablesWithNullPayto-->'+payablesWithNullPayto);
        
        agreementpayables= new List<Payable__c>([select id,name,Status__c,CBR_PAY_TO__r.Provider_Agreement__c,CBR_PAY_TO__r.Address__c,CBR_PAY_TO__r.City__c,CBR_PAY_TO__r.Country__c,CBR_PAY_TO__r.Zip_Code__c,CBR_PAY_TO__r.Tax_ID__c,CBR_PAY_TO__r.State__c,CBR_PAY_TO__r.Active__c from Payable__c  where CBR_PAY_TO__r.Provider_Agreement__c=null and Id=:scope and ID NOT IN:payablesWithNullPayto]);
        system.debug('the agreementpayables-->'+agreementpayables);
        
        try{
            if(provAgrMap!= null && !provAgrMap.isEmpty()){
                system.debug('Inside If------>');
                if(provAgrPayTo!= null && !provAgrPayTo.isEmpty()){
                    for(Payable__c validatepay:scope){
                        if(provAgrMap.containsKey(validatepay.HPN_Provider_Agreement__c)){
                            if(provAgrPayTo.containskey(validatepay.HPN_Provider_Agreement__c)){
                                CBR_PAY_TO__c chkPayto=provAgrPayTo.get(validatepay.HPN_Provider_Agreement__c);
                                system.debug('The check pay to---->'+chkPayto);
                                if(chkPayto.Address__c==null  || chkPayto.City__c==null || chkPayto.Country__c==null || chkPayto.Zip_Code__c==null || chkPayto.Tax_ID__c==null || chkPayto.Name==null || chkPayto.State__c==null){
                                    validatepay.Status__c='Needs Attention';
                                    if(chkPayto.Tax_ID__c==null && (chkPayto.Address__c==null  || chkPayto.City__c==null || chkPayto.Country__c==null || chkPayto.Zip_Code__c==null || chkPayto.State__c==null)){
                                        validatepay.Declined_Reason__c='Tax ID and Address fields are missing';
                                    }
                                    else{
                                        validatepay.Declined_Reason__c=(chkPayto.Address__c==null  || chkPayto.City__c==null || chkPayto.Country__c==null || chkPayto.Zip_Code__c==null || chkPayto.State__c==null)?'Address fields are missing.':'Tax ID is missing';
                                        
                                    }
                                    finalUpdateList.add(validatepay);
                                }
                            }
                        }
                    }
                }
                
                if(payablesWithNullPayto!= null && !payablesWithNullPayto.isEmpty()){
                    for(Payable__c nullpayto:payablesWithNullPayto){
                        nullpayto.Status__c='Needs Attention';
                        nullpayto.Declined_Reason__c='No Active PayTo For ProviderAgreement';
                        finalUpdateList.add(nullpayto);  
                    }
                    
                }
                if(agreementpayables!= null && !agreementpayables.isEmpty()){
                    for(Payable__c eachpayable:agreementpayables){
                        system.debug('the payable to be updates are'+eachpayable);
                        
                        if(eachpayable.CBR_PAY_TO__r.Active__c==false){
                            eachpayable.Status__c='Needs Attention';
                            eachpayable.Declined_Reason__c='Active Flag is missing on Agreement PayTo';
                        }
                        else if(eachpayable.CBR_PAY_TO__r.Active__c==true && eachpayable.CBR_PAY_TO__r.Tax_ID__c==null && (eachpayable.CBR_PAY_TO__r.Address__c==null  || eachpayable.CBR_PAY_TO__r.City__c==null || eachpayable.CBR_PAY_TO__r.Country__c==null || eachpayable.CBR_PAY_TO__r.Zip_Code__c==null || eachpayable.CBR_PAY_TO__r.State__c==null)){
                            eachpayable.Declined_Reason__c='Tax ID and Address fields are missing';
                            eachpayable.Status__c='Needs Attention';
                        }
                        else if(eachpayable.CBR_PAY_TO__r.Active__c==true && eachpayable.CBR_PAY_TO__r.Tax_ID__c!=null && (eachpayable.CBR_PAY_TO__r.Address__c==null  || eachpayable.CBR_PAY_TO__r.City__c==null || eachpayable.CBR_PAY_TO__r.Country__c==null || eachpayable.CBR_PAY_TO__r.Zip_Code__c==null ||  eachpayable.CBR_PAY_TO__r.State__c==null)){
                            eachpayable.Declined_Reason__c='Address fields are missing.';
                            eachpayable.Status__c='Needs Attention';
                        }
                        else if(eachpayable.CBR_PAY_TO__r.Active__c==true && eachpayable.CBR_PAY_TO__r.Tax_ID__c==null && !(eachpayable.CBR_PAY_TO__r.Address__c==null  || eachpayable.CBR_PAY_TO__r.City__c==null || eachpayable.CBR_PAY_TO__r.Country__c==null || eachpayable.CBR_PAY_TO__r.Zip_Code__c==null ||  eachpayable.CBR_PAY_TO__r.State__c==null)){
                            eachpayable.Declined_Reason__c='Tax ID fields are missing.';
                            eachpayable.Status__c='Needs Attention';
                        }
                        
                        finalUpdateList.add(eachpayable);
                    }
                }
                
            } 
            
            system.debug('the payablerecords are'+finalUpdateList);
            //update Payable
            if(finalUpdateList!= null && !finalUpdateList.isEmpty()){
                finalPayables.putall(finalUpdateList);
                List<Database.SaveResult> saveResults = Database.update(finalPayables.values(),false);
                for (integer i=0; i<saveResults.size(); i++) {
                    string ErrDetail='';
                    if (!saveResults.get(i).issuccess()) {
                        //Database.Error error  = ;
                        for (Database.Error e : saveResults.get(i).getErrors()) {
                            ErrDetail+=e.getMessage()+e.getStatusCode();
                            errors.add(e.getMessage());
                            system.debug('error..................'+e.getMessage());
                            
                        }
                        
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'Payable status update batch', 'Apex', ErrDetail, false, false);
                        cbrErrorLog.add(cbr);
                    }
                }
                
                system.debug(errors);
                system.debug('error size'+errors.size());
            }
        }
        catch(Exception ex){
            string exceptionerror = ex.getMessage();
            exceptionerror+=','+ex.getTypeName();
            exceptionerror+=','+ex.getStackTraceString();
            system.debug('Exception Found----'+exceptionerror);
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Payable status update batch Exception', 'Apex', exceptionerror, false, false);
                        cbrErrorLog.add(cbr);
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
    }
    global void finish(Database.BatchableContext BC){}
}