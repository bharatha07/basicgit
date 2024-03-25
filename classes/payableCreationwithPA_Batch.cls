/**************************************************************************************************************************************
*Component Name : payableCreationwithPA_Batch 
*Developed By   : TEKsystems
*Description    : This Batch will create the Payable records for stored assets when New ProviderAgreements are Created.
*User Story     :  SFDC-1083
**********************************************************************************************************************************/


global class payableCreationwithPA_Batch implements Database.Batchable <sObject> {
    List<String> errors = new List<String>();
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query='';
        //Getting opportunity record where status is stored
        if(Test.isRunningTest()){
            query=query+'select id,Provider__c,Pay_to_Group__c,Agreement__c,Agreement__r.CBR_PAY_TO__c,Agreement__r.Agreement_Start_Date__c,Agreement__r.Agreement_End_Date__c,Agreement__r.Special_Handling__c,Provider__r.Name from Provider_Agreement__c where Createddate=today and Active_HPNFlag__c=true';
        }
        else {
            query='select id,Pay_to_Group__c,Provider__c,Agreement__c,Agreement__r.CBR_PAY_TO__c,Agreement__r.Agreement_Start_Date__c,Agreement__r.Agreement_End_Date__c,Agreement__r.Special_Handling__c,Provider__r.Name from Provider_Agreement__c where  Createddate=Yesterday and Active_HPNFlag__c=true';
        }
        
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Provider_Agreement__c> scope){
        system.debug('the PA are-->'+scope);
        system.debug('the PA size is-->'+scope.size());
        Map<Id,Provider_Agreement__c> providerAgreementMap = new Map<Id,Provider_Agreement__c>();
        Map<Id,Opportunity_Provider__c> Opyprovider = new Map<Id,Opportunity_Provider__c>();
        Map<id,List<Opportunity_Provider__c>> oppyIDProviderMap = new Map<Id,List<Opportunity_Provider__c>>();
        Set<Id> providerOppyID = new Set<Id>();
        List<Payable__c> insertPayable = new  List<Payable__c>();
        Map<Id,List<Asset>> oppyAssertMap = new Map<Id,List<Asset>>();
        Map<string,string> PaAgrementMap= new Map<string,string>();
        Map<Id,CBR_PAY_TO__c> activePayTo = new Map<Id,CBR_PAY_TO__c>();
        Map<Id,CBR_PAY_TO__c> provAgrPayTo = new Map<Id,CBR_PAY_TO__c>();
        Boolean allowpayble= false;
        
        if(scope!=null && !scope.isEmpty()){
            for(Provider_Agreement__c PA:scope){
                providerAgreementMap.put(PA.Provider__c,PA); // Hold key as provider id and values as provider_agreement records
                PaAgrementMap.put(PA.id,PA.Agreement__r.CBR_PAY_TO__c);
            }
        }
        system.debug('the provideragreementMap are'+providerAgreementMap);
        system.debug('the provideragreementMap are'+providerAgreementMap.keyset());
        
        if(!providerAgreementMap.isEmpty()){
            Opyprovider = new Map<Id,Opportunity_Provider__c>([select id,Opportunity__c,Provider__c,Provider__r.Name,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true AND Provider__r.HPN_Flag__c=true  AND Provider__c IN:providerAgreementMap.keyset() and (NOT Opportunity__r.Program_Enrolled_in__c like '%Newborn Possibilities Program%')]);
            system.debug('the oppyprovider'+Opyprovider);
        }
        //Fetching Active PayTo for provider Agreement
        activePayTo = new Map<Id,CBR_PAY_TO__c>([select id,name,Provider_Agreement__c,Active__c,Address__c,Address_2__c,City__c,Country__c,State__c,Tax_ID__c,Zip_Code__c from CBR_PAY_TO__c where Active__c=true and Provider_Agreement__c=:scope]);
        system.debug('The Pay To\'s are-->'+activePayTo);
        if(activePayTo!=null && !activePayTo.isEmpty()){
            for(CBR_PAY_TO__c pT:activePayTo.values()){
                provAgrPayTo.put(pT.Provider_Agreement__c,pT); // Hold key as provider id and values as provider_agreement records
                //ActvPA.add(pT.Provider_Agreement__c);
            }
        }
        
        if(Opyprovider!=null && !Opyprovider.isEmpty()){
            for(Opportunity_Provider__c op:Opyprovider.values()){
                
                if(oppyIDProviderMap.containskey(op.Provider__c)) { 
                    oppyIDProviderMap.get(op.Provider__c).add(op);
                }
                
                else{
                    oppyIDProviderMap.put(op.Provider__c, new List<Opportunity_Provider__c>{op});
                }
                // Hold key as Provider ID and values as Opportunity_Provider Records
                providerOppyID.add(op.Opportunity__c);
            }
        }
        system.debug('the oppyproviderMap'+oppyIDProviderMap);
        system.debug('the oppy'+providerOppyID);
        
        //fetching OpportunityContact
        Map<Id,OpportunityContact__c> opyConMap = new Map<Id,OpportunityContact__c>();
        List<OpportunityContact__c> opyContact= [select id,name,PersonAccount__r.name,Role__c,Primary__c,Opportunity__r.Account.name from OpportunityContact__c where Role__c='Mother' and Opportunity__c In:providerOppyID];
        if(opyContact!=null && !opyContact.isEmpty()){
            for(OpportunityContact__c OC:opyContact){
                opyConMap.put(OC.Opportunity__c,OC); // Hold key as opportunity id and values as opporunity contact records
            }
        }
        
        //Excluding the asset having payable reocrds
        List<Payable__c> allpayable=[select id,name,Asset__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c!=null and Opportunity__c IN:providerOppyID];
        set<id> assetWithPayables = new set<id>();
        for(Payable__c existingpayable:allpayable){
            assetWithPayables.add(existingpayable.Asset__c);
        }
        system.debug('the asset id\'s are'+ assetWithPayables);
        
        //Getting asset records for stored Opportunity
        Map<Id,Asset> oppyAsserts = new Map<Id,Asset>([select id,name,Opportunity__c,Opportunity__r.Adoption_Type__c,FreezeDate__c from Asset where  Opportunity__c!=null and FreezeDate__c!=null and Opportunity__c IN : providerOppyID  AND id NOT IN:assetWithPayables]);
        system.debug('the oppy asst'+oppyAsserts);
        for(Asset ast:oppyAsserts.values())
        {
            if(oppyAssertMap.containskey(ast.Opportunity__c)) { 
                oppyAssertMap.get(ast.Opportunity__c).add(ast);
            }
            
            else{
                oppyAssertMap.put(ast.Opportunity__c, new List<Asset>{ast});
            } 
        }
        system.debug('the oppy asst Map'+oppyAssertMap);
        try{
            if(providerAgreementMap!= null && !providerAgreementMap.isEmpty()){
                for(Provider_Agreement__c PA:providerAgreementMap.values()){
                    if(!oppyIDProviderMap.isEmpty()  && oppyIDProviderMap.containsKey(PA.provider__c)){
                        List<Opportunity_Provider__c> oppyProvider= oppyIDProviderMap.get(PA.provider__c);
                        system.debug('the oppyProvider list-->'+oppyProvider);
                        if(oppyProvider!= null){
                            for(Opportunity_Provider__c ops:oppyProvider){
                                List<Asset> lstasrt=oppyAssertMap.get(ops.Opportunity__c);//providermap.keyset
                                system.debug('the assert list-->'+lstasrt);
                                if(lstasrt!= null){
                                    for(Asset ass:lstasrt) { 
                                        DateTime dT =ass.FreezeDate__c;
                                        Date freezedate = date.newinstance(dT.year(), dT.month(), dT.day());
                                        if(providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_Start_Date__c!=null &&((providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_End_Date__c==null && providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_Start_Date__c<=freezedate) || (
                                                                                                                                                                                                                                  providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_End_Date__c!=null && 
                                                                                                                                                                                                                                  (providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_Start_Date__c<=freezedate &&
                                                                                                                                                                                                                                   providerAgreementMap.get(ops.Provider__c).Agreement__r.Agreement_End_Date__c>=freezedate)))){
                                       
                                        
                                        
                                        Payable__c pY= new Payable__c();
                                        pY.Asset__c=ass.Id;
                                        pY.Opportunity__c=ass.Opportunity__c;
                                        pY.Provider_ID__c=ops.Provider__c;
                                        pY.Account_ID_Mother__c=opyConMap.containsKey(ops.Opportunity__c)?opyConMap.get(ops.Opportunity__c).PersonAccount__c:null;
                                        if(opyConMap.containsKey(ops.Opportunity__c)){
                                         pY.Patient_Name__c=ass.Opportunity__r.Adoption_Type__c!='N/A'?'N/A':opyConMap.get(ops.Opportunity__c).PersonAccount__r.name;
                                         }                                                                                                                                                                                               
                                        pY.HPN_Provider_Agreement__c=providerAgreementMap.containsKey(ops.Provider__c)?providerAgreementMap.get(ops.Provider__c).id:null;
                                        pY.Agreement__c=providerAgreementMap.containsKey(ops.Provider__c)?providerAgreementMap.get(ops.Provider__c).Agreement__c:null;
                                        Boolean payToGrp =providerAgreementMap.get(ops.Provider__c).Pay_to_Group__c;
                                        if(payToGrp==false){
                                            if(!provAgrPayTo.isEmpty()){
                                                system.debug('inside IF***********');
                                                string paID= providerAgreementMap.containsKey(ops.Provider__c)?providerAgreementMap.get(ops.Provider__c).id:null;
                                                pY.CBR_PAY_TO__c=provAgrPayTo.containskey(paID)?provAgrPayTo.get(paID).id:null;
                                            }
                                            else{
                                                pY.CBR_PAY_TO__c=null;
                                            }
                                        }
                                        else if(payToGrp==true){
                                            system.debug('inside else***********');
                                            string paID = providerAgreementMap.containsKey(ops.Provider__c)?providerAgreementMap.get(ops.Provider__c).id:null;
                                            
                                            pY.CBR_PAY_TO__c=PaAgrementMap.containskey(paID)?PaAgrementMap.get(paID):null;  
                                        }
                                        pY.Status__c=providerAgreementMap.get(ops.Provider__c).Agreement__r.Special_Handling__c?'Special Handling':'Pending Accounting';
                                        insertPayable.add(pY);
                                    } 
                                    } 
                                }
                            }
                        }
                    }
                }
            }
            
            system.debug('the payablerecords are'+insertPayable);
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
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'Payable Creation Batch Using ProviderAgreement', 'Apex', ErrDetail, false, false);
                        cbrErrorLog.add(cbr);
                    }
                }
                system.debug(errors);
                system.debug('error size'+errors.size());
            }
            
        }
        
        catch(Exception ex){
            system.debug('Exception Found----'+ex.getMessage());
            string exceptionerror = ex.getMessage();
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Payable Creation Batch Using ProviderAgreement Exception', 'Apex', exceptionerror, false, false);
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


mail.setSubject('Payable Creation Batch using ProviderAgreement ' + a.Status);
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