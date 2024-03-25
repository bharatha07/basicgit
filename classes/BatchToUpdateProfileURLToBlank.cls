/*************************************************************************************************
* @description This Batch job is to update profile URL field to blank based on primary provider and contact date of birth and ID type,Information.
* @param - 
* @story - SFDC-1856
* @Author -Teksystems
* @date - 17-SEP-2021 (Teksystems)
*/
public class BatchToUpdateProfileURLToBlank implements Database.Batchable<sObject>,Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        datetime enrollmentdateForNewOle= datetime.valueOf(system.label.enrollmentdateNewOle);
        String query ='select id,status__c,AccountId,Profile_URL__c,Online_Enroll_Status__c,Enrollment_Date__c,Profile_Complete__c,Account.Profile_URL__c from opportunity where Status__c =\'Enrolled\' AND Enrollment_Date__c >=:enrollmentdateForNewOle  AND Profile_URL__c !=null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        string ErrDetail;
        Map<id,opportunity> OppMap = new Map<id,opportunity>();
        Set<Id> OptyIds = new Set<Id>();
        List<Sobject> sObjeLst = new List<Sobject>();
        List<Account> accLst = new List<Account>();
        List<Opportunity> optyLst = new List<Opportunity>();
        Map<Id,Opportunity_Provider__c> oppProvidersMap = new Map<Id,Opportunity_Provider__c>();
        if(!scope.isEmpty()){
            for(Opportunity opp:scope){
                OppMap.put(opp.Id,opp);
            }
        }
        
        if(!OppMap.isEmpty()){
            for(Opportunity_Provider__c oppProvide : [select id,opportunity__r.account.PersonBirthdate,opportunity__r.account.ID_Type__pc,
                                                      opportunity__r.account.ID_Information__pc,opportunity__r.Delivering_Hospital__c,opportunity__r.Profile_Complete__c,
                                                     opportunity__c from Opportunity_Provider__c where opportunity__c IN : OppMap.keySet() AND Primary_Provider__c = true]){
                
                                                         if(oppProvide.opportunity__r.account.PersonBirthdate != Null && string.isNotBlank(oppProvide.opportunity__r.account.ID_Information__pc)
                                                            && oppProvide.opportunity__r.account.ID_Type__pc != Null && oppProvide.opportunity__r.Delivering_Hospital__c != Null && OppMap.containsKey(oppProvide.opportunity__c)){
                                                             	
                                                                opportunity opty = oppMap.get(oppProvide.opportunity__c);
                                                                opty.Profile_URL__c = '';
                                                                if(opty.Profile_Complete__c !=true){
                                                                  opty.Profile_Complete__c=true;  
                                                                }
                                                                
                                                                optyLst.add(opty);
                                                                
                                                                Account Acc = new Account(id=opty.AccountId);
                                                                Acc.Profile_URL__c='';                                                                
                                                                accLst.add(acc);
                                                                
                                                         }
                                                     }
            if(!accLst.isEmpty() && !optyLst.isEmpty()){
                sObjeLst.addAll(optyLst);
                sObjeLst.addAll(accLst);
            }
        }
        if(!sObjeLst.isEmpty()){
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for(Database.SaveResult sr : Database.update(sObjeLst,false)){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    system.debug('erromessgae'+ErrDetail);
                }  
            } 
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Profile URL batch', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}