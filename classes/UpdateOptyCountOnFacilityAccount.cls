/*******************************************************************************************************************************************
* Component Name:UpdateOptyCountOnFacilityAccount
* Description: Batch to update #of Open and #of Enroll Opty count on Facility.
* Created By: TEKsystems
* Created Date: 
* User Story: SFDC - 1547,1548
************************************************************************************************************************************************/
public class UpdateOptyCountOnFacilityAccount {
    @future
    public static void UpdateOptyCountOnFacilityAccountMethod(set<id> facilitySet){
        map<id,list<opportunity>> optyMapOpen = new map<id,list<opportunity>>();
        map<id,list<opportunity>> optyMap1Enroll = new map<id,list<opportunity>>();
        Map<id,Account> FacliLst = new Map<id,Account>();
        string ErrDetail;
        
        if(!facilitySet.isEmpty()){
            for(account accWithOpen : [select id,of_open_optys__c,of_enrolled_optys__c ,(select id,Delivering_Hospital__c,status__c from OpportunitiesDH__r
                                                                                         where Delivering_Hospital__c IN :facilitySet and status__c='open') from account where id IN :facilitySet limit 49999]){
                                                                                             list<opportunity> openOptylst = accWithOpen.OpportunitiesDH__r;
                                                                                             optyMapOpen.put(accWithOpen.id,openOptylst);
                                                                                             system.debug('optyMapOpen>>>'+optyMapOpen);
                                                                                         }
            for(account accWithEnroll : [select id,of_open_optys__c,of_enrolled_optys__c ,(select id,Delivering_Hospital__c,status__c from OpportunitiesDH__r
                                                                                           where Delivering_Hospital__c IN :facilitySet and (status__c ='Enrolled' or Enrollment_Date__c !=null)) from account where id IN :facilitySet limit 49999]){
                                                                                               list<opportunity> enrollOptylst = new list<opportunity>();
                                                                                               for(opportunity oppenrl :accWithEnroll.OpportunitiesDH__r){
                                                                                                   enrollOptylst.add(oppenrl);
                                                                                               }
                                                                                               optyMap1Enroll.put(accWithEnroll.id,enrollOptylst);
                                                                                               system.debug('optyMap1Enroll>>>'+optyMap1Enroll);
                                                                                           }
            
            for(id accIdRec : facilitySet){
                if(optyMapOpen.containskey(accIdRec)){
                    if(FacliLst.containskey(accIdRec)){
                        account acct =  FacliLst.get(accIdRec);
                        double opn = acct.of_open_optys__c == Null ? 0 : acct.of_open_optys__c;
                        acct.of_open_optys__c=optyMapOpen.get(accIdRec).size() +opn;
                        FacliLst.put(acct.id,acct);
                        system.debug('OPen>>>');
                    }else{
                        account acc = new account(id=accIdRec);
                        acc.of_open_optys__c=optyMapOpen.get(accIdRec).size() ;
                        FacliLst.put(acc.id,acc);
                        system.debug('OPenelse>>>');
                    } 
                }
                if(optyMap1Enroll.containskey(accIdRec)){
                    if(FacliLst.containskey(accIdRec)){
                        account acct =  FacliLst.get(accIdRec);
                        double enrol = acct.of_enrolled_optys__c == Null ? 0 : acct.of_enrolled_optys__c;
                        acct.of_enrolled_optys__c=optyMap1Enroll.get(accIdRec).size() +enrol;
                        FacliLst.put(acct.id,acct);
                        system.debug('Enroll>>>');
                    }
                    else{
                        account acc1 = new account(id=accIdRec);
                        acc1.of_enrolled_optys__c=optyMap1Enroll.get(accIdRec).size(); 
                        FacliLst.put(acc1.id,acc1);
                        system.debug('Enrollelse>>>');
                    }
                }
                
            }
        }
        if(!FacliLst.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (FacliLst.values(),false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';
                    }
                    
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Open and Enrolled Count on Facility', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }
    
}