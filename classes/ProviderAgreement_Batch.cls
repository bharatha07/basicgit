/*************************************************
Component Name:ProviderAgreement_Batch
Description: Batch to Update Provider HPN Flag based on ProviderAgreement Active HPN Falg
Created By: Teksystems
User Story: SFDC-1078
**************************************************/
global class ProviderAgreement_Batch implements Database.Batchable <sObject>{
    
    List<String> errors = new List<String>();
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,HPN_Flag__c From Account where HPN_Flag__c=true AND recordtype.name=\'Provider\'';  
        system.debug('query is-->'+query);
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){
        Map<Id,Provider_Agreement__c> providerAgreementMap = new Map<Id,Provider_Agreement__c>([select id,HPN_End_Date__c,provider__c,Active_HPNFlag__c from Provider_Agreement__c where Provider__c IN:scope]);
        Map<Id,Boolean> proAgreementsCheck = new Map<Id,Boolean>();
        Set<Id> providerIds = new Set<Id>();
        List<Account> finalaccountstoUpate= new List<Account>();
        try{
            if(providerAgreementMap!=null ){
                for(Provider_Agreement__c pARec:providerAgreementMap.values()){
                    providerIds.add(pARec.provider__c);
                    if(pARec.Active_HPNFlag__c){
                        if(proAgreementsCheck!=null && proAgreementsCheck.containsKey(pARec.provider__c)  ){
                            proAgreementsCheck.put(pARec.provider__c,true);
                        }
                        else{
                            proAgreementsCheck.put(pARec.provider__c,true);
                        }
                    }
                    
                }
                
            }
            if(proAgreementsCheck!=null){
                for(account acc:scope){
                    if(providerIds!=null && providerIds.contains(acc.Id) && (proAgreementsCheck ==null || (proAgreementsCheck!=null && !proAgreementsCheck.containsKey(acc.id)))){
                        acc.HPN_Flag__c = false;
                        finalaccountstoUpate.add(acc);
                        
                    }
                }
            }
            system.debug('The final providers  are -->'+finalaccountstoUpate); 
            if(finalaccountstoUpate!= null && !finalaccountstoUpate.isEmpty()){
                List<Database.SaveResult> saveResults = Database.update(finalaccountstoUpate,false);
                for (Database.SaveResult saveResult : saveResults) {
                    if (!saveResult.isSuccess()) {
                        for (Database.Error e : saveResult.getErrors()) {
                            system.debug('error..................'+e.getMessage());
                            errors.add(e.getMessage());
                            
                        }
                    }
                }
                system.debug(errors);
                system.debug('error size'+errors.size());
            }
        }
        catch(exception  ex){
            string exceptionerror = ex.getMessage();
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'ProviderAgreement_Batch Exception', 'Apex', exceptionerror, false, false);
            cbrErrorLog.add(cbr);
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
    }
    
    
    
    global void finish(Database.BatchableContext BC){   
        
    }
    
}