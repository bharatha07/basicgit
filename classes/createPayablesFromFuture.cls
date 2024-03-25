public class createPayablesFromFuture {
    
    @future
    public static void createPayables(string jsonString){
        system.debug('inside future');
        List<String> errors = new List<String>();
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        set<id> oppyIds= new set<id>();
        set<id> providerIds= new set<id>();
        set<id> assetWithPayables = new set<id>();
        Map<Id,Opportunity_Provider__c> oppyProviderMap = new Map<Id,Opportunity_Provider__c>();
        Map<Id,Provider_Agreement__c> provAgrMap = new Map<Id,Provider_Agreement__c>();
        Map<Id,Provider_Agreement__c> accAgrMap = new Map<Id,Provider_Agreement__c>();
        Map<string,string> PaAgrementMap= new Map<string,string>();
        Map<Id,CBR_PAY_TO__c> activePayTo = new Map<Id,CBR_PAY_TO__c>();
        Map<Id,CBR_PAY_TO__c> provAgrPayTo = new Map<Id,CBR_PAY_TO__c>();
        List<Payable__c> insertPayable = new  List<Payable__c>();
        Boolean allowpayble= true;
        
        List<Opportunity_Provider__c> opyprvdlist = (List<Opportunity_Provider__c>)Json.deserialize(jsonString,List<Opportunity_Provider__c>.class);
        System.debug('--opyprvdlist List--->'+opyprvdlist);
        for(Opportunity_Provider__c eachrec:opyprvdlist ){
            oppyIds.add(eachrec.Opportunity__c);
            providerIds.add(eachrec.Provider__c);
            oppyProviderMap.put(eachrec.Opportunity__c,eachrec); 
        }
        if(!providerIds.isEmpty()){
            provAgrMap = new Map<Id,Provider_Agreement__c>([select id,Pay_to_Group__c,Provider__c,Agreement__c,Agreement__r.CBR_PAY_TO__c,Agreement__r.Agreement_Start_Date__c,Agreement__r.Agreement_End_Date__c,Agreement__r.Special_Handling__c,Provider__r.Name,Provider__r.HPN_Flag__c,Active_HPNFlag__c from Provider_Agreement__c where  Provider__c IN:providerIds And Active_HPNFlag__c=true]);  
            system.debug('the provideragreement are'+provAgrMap);
        } 
        if(provAgrMap!=null && !provAgrMap.isEmpty()){
            for(Provider_Agreement__c PA:provAgrMap.values()){
                accAgrMap.put(PA.Provider__c,PA); // Hold key as provider id and values as provider_agreement records
                PaAgrementMap.put(PA.id,PA.Agreement__r.CBR_PAY_TO__c);
                //paAgreementID.add(PA.Agreement__c);
            }
        }
        system.debug('the provideragreementMap are'+accAgrMap);
        system.debug('the provideragreementMap ************'+PaAgrementMap);
        
        //Excluding the asset having payable reocrds
        /*List<Payable__c> allpayable=[select id,name,Asset__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c!=null and Opportunity__c IN:oppyIds];
        
        for(Payable__c existingpayable:allpayable){
            assetWithPayables.add(existingpayable.Asset__c);
        }
        system.debug('the asset id\'s are'+ assetWithPayables);*/
        
        List<Asset> allAssets=[Select id,name,Opportunity__c,Opportunity__r.Adoption_Type__c,FreezeDate__c,Status from Asset where Opportunity__c!=null and Opportunity__c IN:oppyIds];
        for(Asset existingpayable:allAssets){
            assetWithPayables.add(existingpayable.id);
        }
        system.debug('the asset id\'s are'+ assetWithPayables);
        
        //Getting asset records for stored Opportunity
        Map<Id,Asset> oppyAsserts = new Map<Id,Asset>([select id,name,Opportunity__c,Opportunity__r.Adoption_Type__c,FreezeDate__c,Status from Asset where Status='Stored'and FreezeDate__c!=null and Opportunity__c!=null and Opportunity__c IN : oppyIds  AND id NOT IN(select Asset__c from Payable__c where Asset__c!=null and Opportunity__c IN:oppyIds) AND ID NOT IN(select Asset__c from Payable__c where Asset__c!=null and Asset__c IN:assetWithPayables)]);//:assetWithPayables
        system.debug('the oppy asst'+oppyAsserts);
        
        //fetching OpportunityContact
        Map<Id,OpportunityContact__c> opyConMap = new Map<Id,OpportunityContact__c>();
        List<OpportunityContact__c> opyContact= [select id,name,PersonAccount__r.name,Role__c,Primary__c,Opportunity__r.Account.name from OpportunityContact__c where Role__c='Mother' and Opportunity__c In:oppyIds];
        if(opyContact!=null && !opyContact.isEmpty()){
            for(OpportunityContact__c OC:opyContact){
                opyConMap.put(OC.Opportunity__c,OC); // Hold key as provider id and values as provider_agreement records
            }
        }
        system.debug('the oppyContacts are'+ opyConMap);
        
        activePayTo = new Map<Id,CBR_PAY_TO__c>([select id,name,Provider_Agreement__c,Active__c,Address__c,Address_2__c,City__c,Country__c,State__c,Tax_ID__c,Zip_Code__c from CBR_PAY_TO__c where Active__c=true and Provider_Agreement__c=:provAgrMap.keyset()]);
        system.debug('The Pay To\'s are-->'+activePayTo);
        if(activePayTo!=null && !activePayTo.isEmpty()){
            for(CBR_PAY_TO__c pT:activePayTo.values()){
                provAgrPayTo.put(pT.Provider_Agreement__c,pT); // Hold key as provider id and values as provider_agreement records
                //ActvPA.add(pT.Provider_Agreement__c);
            }
        }
        try{
            if(oppyAsserts!= null && !oppyAsserts.isEmpty()){
                for(Asset ast:oppyAsserts.values()){
                    if(!oppyProviderMap.isEmpty()  && oppyProviderMap.containsKey(ast.Opportunity__c)  && oppyProviderMap.get(ast.Opportunity__c).Delivering_Provider__c){
                        Opportunity_Provider__c oppyProvider= oppyProviderMap.get(ast.Opportunity__c);
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
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Payable Creation Batch from Future Method', 'Apex', exceptionerror, false, false);
            cbrErrorLog.add(cbr);
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
        
    }
    
}