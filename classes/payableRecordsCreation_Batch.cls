/**************************************************************************************************************************************
*Component Name : payableRecordsCreation_Batch 
*Developed By   : TEKsystems
*Description    : This Batch will create the Payable records for stored assets when based on Asset Freeze date.
*User Story     :  SFDC-1083
**********************************************************************************************************************************/
global class payableRecordsCreation_Batch implements Database.Batchable <sObject>{
    List<String> errors = new List<String>();
    Integer nDays;
    string query='';
    String isAllow = system.label.PayablesCreation;
    date AssetFreeze=date.valueOf(system.label.AssetFreeze);
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
    public payableRecordsCreation_Batch(integer n){
        this.nDays=n;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('inside start');
        //Getting opportunity record where status is stored
        if(Test.isRunningTest()){
            query=query+'SELECT Id, Name, Status,FreezeDate__c,Opportunity__c FROM Asset Where Opportunity__c!=null and  Status=\'Stored\' and (NOT Opportunity__r.Program_Enrolled_in__c like \'%Newborn Possibilities Program%\') and FreezeDate__c=LAST_N_DAYS:'+nDays;
        }
        else if(isAllow!=null && isAllow =='Allow'){
            system.debug('Inside else if');
            query='SELECT Id, Name, Status,FreezeDate__c,Opportunity__c FROM Asset Where Opportunity__c!=null and  Status=\'Stored\' and (NOT Opportunity__r.Program_Enrolled_in__c like \'%Newborn Possibilities Program%\') and id not in( select Asset__c from Payable__c) and FreezeDate__c<:AssetFreeze and FreezeDate__c=LAST_N_DAYS:'+nDays;
        }
        else{
            system.debug('Inside else');
            query='SELECT Id, Name, Status,FreezeDate__c,Opportunity__c FROM Asset Where Opportunity__c!=null and  Status=\'Stored\' and (NOT Opportunity__r.Program_Enrolled_in__c like \'%Newborn Possibilities Program%\') and FreezeDate__c=LAST_N_DAYS:'+nDays;
        }
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Asset> scope){
        system.debug('The asset records are--->'+scope);
        system.debug('The asset records are--->'+scope.size());
        set<id> oppyId = new set<id>();
        set<id> assetId = new set<id>();
        Map<Id,Opportunity> storedOppy= new Map<Id,Opportunity>();
        Set<Id> oppyAccID = new Set<Id>();
        Map<Id,Opportunity_Provider__c> oppyProviderMap = new Map<Id,Opportunity_Provider__c>();
        Map<id,Opportunity_Provider__c> oppIDProviderMap = new Map<Id,Opportunity_Provider__c>();
        Map<Id,Provider_Agreement__c> provAgrMap = new Map<Id,Provider_Agreement__c>();
        Map<Id,Provider_Agreement__c> accAgrMap = new Map<Id,Provider_Agreement__c>();
        Map<Id,List<Asset>> oppyAssertMap = new Map<Id,List<Asset>>();
        List<Payable__c> insertPayable = new  List<Payable__c>();
        Map<string,string> PaAgrementMap= new Map<string,string>();
        set<id> paAgreementID= new set<id>();
        Map<Id,CBR_PAY_TO__c> activePayTo = new Map<Id,CBR_PAY_TO__c>();
        Map<Id,CBR_PAY_TO__c> provAgrPayTo = new Map<Id,CBR_PAY_TO__c>();
        Boolean allowpayble= true;
        
        if(scope!=null && !scope.isEmpty()){
            for(Asset ass:scope){
                if(ass.Status == 'Stored'){
                    assetId.add(ass.id);
                    oppyId.add(ass.Opportunity__c);
                }
            } 
        }
        
        //fetching opportunity_Provider Records
        if(!oppyId.isEmpty()){
            oppyProviderMap = new Map<Id,Opportunity_Provider__c>([select id,Opportunity__c,Provider__c,Provider__r.Name,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true AND Provider__r.HPN_Flag__c=true  AND Opportunity__c IN:oppyId]);
            system.debug('the oppyprovider'+oppyProviderMap);
        }
        if(oppyProviderMap!=null && !oppyProviderMap.isEmpty()){
            for(Opportunity_Provider__c op:oppyProviderMap.values()){
                oppIDProviderMap.put(op.Opportunity__c,op);// Hold key as opportunity ID and values as Opportunity_Provider Records
                oppyAccID.add(op.Provider__c);
            }
        }
        system.debug('the oppyproviderMap'+oppIDProviderMap);
        system.debug('the provider ID from Oppyprovidermap'+oppyAccID);
        
        //fetching Provider_Agreement Records
        if(!oppyAccID.isEmpty()){
            provAgrMap = new Map<Id,Provider_Agreement__c>([select id,Pay_to_Group__c,Provider__c,Agreement__c,Agreement__r.CBR_PAY_TO__c,Agreement__r.Agreement_Start_Date__c,Agreement__r.Agreement_End_Date__c,Agreement__r.Special_Handling__c,Provider__r.Name,Provider__r.HPN_Flag__c,Active_HPNFlag__c from Provider_Agreement__c where  Provider__c IN:oppyAccID And Active_HPNFlag__c=true]);  
            system.debug('the provideragreement are'+provAgrMap);
        }
        if(provAgrMap!=null && !provAgrMap.isEmpty()){
            for(Provider_Agreement__c PA:provAgrMap.values()){
                accAgrMap.put(PA.Provider__c,PA); // Hold key as provider id and values as provider_agreement records
                PaAgrementMap.put(PA.id,PA.Agreement__r.CBR_PAY_TO__c);
                paAgreementID.add(PA.Agreement__c);
            }
        }
        system.debug('the provideragreementMap are'+accAgrMap);
        system.debug('the provideragreementMap ************'+PaAgrementMap);
        
        //fetching OpportunityContact
        Map<Id,OpportunityContact__c> opyConMap = new Map<Id,OpportunityContact__c>();
        List<OpportunityContact__c> opyContact= [select id,name,PersonAccount__r.name,Role__c,Primary__c,Opportunity__r.Account.name from OpportunityContact__c where Role__c='Mother' and Opportunity__c In:oppyId];
        if(opyContact!=null && !opyContact.isEmpty()){
            for(OpportunityContact__c OC:opyContact){
                opyConMap.put(OC.Opportunity__c,OC); // Hold key as provider id and values as provider_agreement records
            }
        }
        system.debug('the oppyContacts are'+ opyConMap);
        
        //fetching the Agreements 
        Map<id,Agreement__c> agreementMap = new  Map<id,Agreement__c>([select id,Name,CB_Amt__c,CT_Amt__c,Program__c,CBR_PAY_TO__c from Agreement__c where ID In :paAgreementID]);
        
        activePayTo = new Map<Id,CBR_PAY_TO__c>([select id,name,Provider_Agreement__c,Active__c,Address__c,Address_2__c,City__c,Country__c,State__c,Tax_ID__c,Zip_Code__c from CBR_PAY_TO__c where Active__c=true and Provider_Agreement__c=:provAgrMap.keyset()]);
        system.debug('The Pay To\'s are-->'+activePayTo);
        if(activePayTo!=null && !activePayTo.isEmpty()){
            for(CBR_PAY_TO__c pT:activePayTo.values()){
                provAgrPayTo.put(pT.Provider_Agreement__c,pT); // Hold key as provider id and values as provider_agreement records
                //ActvPA.add(pT.Provider_Agreement__c);
            }
        }
        
        //Storing asset ID which has existing payable records
        List<Payable__c> allpayable=[select id,name,Asset__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c!=null and Asset__c IN:assetId];
        set<id> assetWithPayable = new set<id>();
        for(Payable__c existingpayable:allpayable){
            assetWithPayable.add(existingpayable.Asset__c);
        }
        system.debug('the asset id\'s are'+ assetWithPayable);        
        //Getting asset records for stored Opportunity
        Map<Id,Asset> oppyAsserts = new Map<Id,Asset>([select id,name,Opportunity__c,Opportunity__r.Adoption_Type__c,FreezeDate__c from Asset where  Opportunity__c!=null and id IN : assetId  AND id NOT IN:assetWithPayable]);
        system.debug('the oppy asst'+oppyAsserts.keyset());
        
        try{
            if(oppyAsserts!= null && !oppyAsserts.isEmpty()){
                for(Asset ast:oppyAsserts.values()){
                    if( !oppIDProviderMap.isEmpty()  && oppIDProviderMap.containsKey(ast.Opportunity__c)  && oppIDProviderMap.get(ast.Opportunity__c).Delivering_Provider__c){
                        Opportunity_Provider__c oppyProvider= oppIDProviderMap.get(ast.Opportunity__c);
                        system.debug('the oppyProvider list-->'+oppyProvider);
                        if(accAgrMap!= null && !accAgrMap.isEmpty() && accAgrMap.containsKey(oppyProvider.Provider__c) && accAgrMap.get(oppyProvider.Provider__c).Provider__r.HPN_Flag__c){
                            DateTime dT =ast.FreezeDate__c;
                            Date freezedate = date.newinstance(dT.year(), dT.month(), dT.day());
                            if(accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_Start_Date__c!=null &&((accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_End_Date__c==null && accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_Start_Date__c<=freezedate) || (
                                accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_End_Date__c!=null && 
                                (accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_Start_Date__c<=freezedate &&
                                 accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Agreement_End_Date__c>=freezedate)))){
                                     system.debug('inside create payable');
                                     Payable__c pY= new Payable__c();
                                     pY.Asset__c=ast.Id;
                                     pY.Opportunity__c=ast.Opportunity__c;
                                     pY.Provider_ID__c=oppyProvider.Provider__c;
                                     pY.Account_ID_Mother__c=opyConMap.containsKey(ast.Opportunity__c)?opyConMap.get(ast.Opportunity__c).PersonAccount__c:null;
                                     if(opyConMap.containsKey(ast.Opportunity__c)){
                                         pY.Patient_Name__c=ast.Opportunity__r.Adoption_Type__c!='N/A'?'N/A':opyConMap.get(ast.Opportunity__c).PersonAccount__r.name;
                                     }
                                     pY.HPN_Provider_Agreement__c=accAgrMap.containsKey(oppyProvider.Provider__c)?accAgrMap.get(oppyProvider.Provider__c).id:null;
                                     pY.Agreement__c=accAgrMap.containsKey(oppyProvider.Provider__c)?accAgrMap.get(oppyProvider.Provider__c).Agreement__c:null;
                                     Boolean payToGrp =accAgrMap.get(oppyProvider.Provider__c).Pay_to_Group__c;
                                     if(payToGrp==false){
                                         if(!provAgrPayTo.isEmpty()){
                                             system.debug('inside IF***********');
                                             string paID= accAgrMap.containsKey(oppyProvider.Provider__c)?accAgrMap.get(oppyProvider.Provider__c).id:null;
                                             pY.CBR_PAY_TO__c=provAgrPayTo.containskey(paID)?provAgrPayTo.get(paID).id:null;
                                         }
                                         else{
                                             pY.CBR_PAY_TO__c=null;
                                         }
                                     }
                                     else if(payToGrp==true){
                                         system.debug('inside else***********');
                                         string paID= accAgrMap.containsKey(oppyProvider.Provider__c)?accAgrMap.get(oppyProvider.Provider__c).id:null; 
                                         pY.CBR_PAY_TO__c=PaAgrementMap.containskey(paID)?PaAgrementMap.get(paID):null;  
                                     }
                                     pY.Status__c=accAgrMap.get(oppyProvider.Provider__c).Agreement__r.Special_Handling__c?'Special Handling':'Pending Accounting';
                                     insertPayable.add(pY);
                                 }                             
                        } 
                    }  
                }
            }
            system.debug('the payablerecors are'+insertPayable);
            //Insert Payable
            if(insertPayable!= null && !insertPayable.isEmpty()){
                List<Database.SaveResult> saveResults = Database.insert(insertPayable,false);
                for (integer i=0; i<saveResults.size(); i++) {
                    string ErrDetail='';
                    if (!saveResults.get(i).issuccess()) {
                        //Database.Error error  = ;
                        for (Database.Error e : saveResults.get(i).getErrors()) {
                            ErrDetail+=e.getMessage()+e.getStatusCode();
                            errors.add(e.getMessage());
                            system.debug('error..................'+e.getMessage());
                            
                        }
                        
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'Payable Creation Batch Using Asset', 'Apex', ErrDetail, false, false);
                        cbrErrorLog.add(cbr);
                    }
                }
                
                system.debug(errors);
                system.debug('error size'+errors.size());
            }
        }
        
        catch(Exception ex){
            system.debug('Exception Found----'+ex.getMessage());
            string exceptionerror =ex.getMessage();
            system.debug('Exception Found----'+exceptionerror);
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Payable Creation Batch Using Asset Exception', 'Apex', exceptionerror, false, false);
            cbrErrorLog.add(cbr);
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
    }
    global void finish(Database.BatchableContext BC){   
        
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.  
        
        /* AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
TotalJobItems, CreatedBy.Email
from AsyncApexJob where Id =:BC.getJobId()];



// Send an email to the Apex job's submitter notifying of job completion.  
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {a.CreatedBy.Email,'bavaldar@teksystems.com'};
mail.setToAddresses(toAddresses);


mail.setSubject('Payable Creation Batch ' + a.Status);
if(errors!= null && !errors.isEmpty()){
mail.setHtmlBody('<br/> Hi, <br/><br/> The batch job is failed with below errors : <br/><br/>' +errors);
}
else{
mail.setHtmlBody('<br/> Hi, <br/><br/> The batch job processed with <b>' + a.TotalJobItems +
'</b> batches and excetuted with <strong>'+ a.NumberOfErrors + '</strong> failures. <br/><br/> Thanks,<br/> Admin.');
}

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  */
    } 
    
}