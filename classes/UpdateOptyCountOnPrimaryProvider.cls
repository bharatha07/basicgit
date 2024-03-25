/*******************************************************************************************************************************************
* Component Name:UpdateOptyCountOnPrimaryProvider
* Description: Batch to update #of Open and #of Enroll Opty count on providers.
* Created By: TEKsystems
* Created Date: 
* User Story: SFDC - 1519,1520,1521
************************************************************************************************************************************************/
public class UpdateOptyCountOnPrimaryProvider {
    @future
    public static void UpdateOptyCountOnPrimaryProviderMethod(set<id> OptySet,boolean optypro){
        //Map<id,Opportunity_Provider__c> optyproviderLst = new Map<id,Opportunity_Provider__c>([select id,Opportunity__c,Provider__c from Opportunity_Provider__c where Opportunity__c IN :OptySet AND Primary_Provider__c =true]);
        string ErrDetail;
        set<id> provdrSet = new set<id>();
        Map<id,Account> prdAcc = new Map<id,Account>();
        map<id,set<id>> optyMapOpen = new map<id,set<id>>();
        map<id,set<id>> optyMapEnroll = new map<id,set<id>>();
        map<id,set<id>> optyMapEnrollNotPri = new map<id,set<id>>();
        String SOURCE = 'I\'m a Current Client';
        if(!OptySet.isEmpty()){
            if(optypro == true){
                for(Opportunity_Provider__c provderOpty : [select id,Opportunity__c,Provider__c from Opportunity_Provider__c where Opportunity__c IN :OptySet AND Primary_Provider__c =true]){
                    if(string.isNotBlank(provderOpty.Provider__c)){
                        provdrSet.add(provderOpty.Provider__c);
                    }
                }  
            }
            else{
                provdrSet.addAll(OptySet);
            }
            
        }
        if(!provdrSet.isEmpty()){
            for(Opportunity_Provider__c provdr : [select id,Opportunity__c,Opportunity__r.Status__c,Provider__c,Opportunity__r.Primary_Source__c from Opportunity_Provider__c where Provider__c IN :provdrSet 
                                                  and Primary_Provider__c =true and (Opportunity__r.Status__c='Open' or Opportunity__r.Enrollment_Date__c !=null)limit 49999]){
                                                      if(provdr.Opportunity__r.Status__c=='Open'){
                                                          if(optyMapOpen.containskey(provdr.Provider__c)){
                                                              optyMapOpen.get(provdr.Provider__c).add(provdr.Opportunity__c);
                                                          }
                                                          else{
                                                              optyMapOpen.put(provdr.Provider__c,new set<id>{provdr.Opportunity__c}); 
                                                          }
                                                      }else if(provdr.Opportunity__r.Status__c !='Open'){
                                                          if(optyMapEnroll.containskey(provdr.Provider__c)){
                                                              optyMapEnroll.get(provdr.Provider__c).add(provdr.Opportunity__c);
                                                          }
                                                          else{
                                                              optyMapEnroll.put(provdr.Provider__c,new set<id>{provdr.Opportunity__c}); 
                                                          }
                                                      } 
                                                      if(provdr.Opportunity__r.Status__c !='Open' && provdr.Opportunity__r.Primary_Source__c !=SOURCE){
                                                          if(optyMapEnrollNotPri.containskey(provdr.Provider__c)){
                                                              optyMapEnrollNotPri.get(provdr.Provider__c).add(provdr.Opportunity__c);
                                                          }
                                                          else{
                                                              optyMapEnrollNotPri.put(provdr.Provider__c,new set<id>{provdr.Opportunity__c}); 
                                                          }
                                                      }
                                                      
                                                  }
        }
        if(!optyMapOpen.isEmpty() || !optyMapEnroll.isEmpty() || !optyMapEnrollNotPri.isEmpty()){
            for(id providerid : provdrSet){
                if(optyMapOpen.containskey(providerid)){
                    if(prdAcc.containskey(providerid)){
                        account acct =  prdAcc.get(providerid);
                        double opn = acct.of_open_optys__c == Null ? 0 : acct.of_open_optys__c;
                        acct.of_open_optys__c=optyMapOpen.get(providerid).size() +opn;
                        prdAcc.put(acct.id,acct);
                        system.debug('OPen>>>');
                    }else{
                        account acc = new account(id=providerid);
                        acc.of_open_optys__c=optyMapOpen.get(providerid).size() ;
                        prdAcc.put(acc.id,acc);
                        system.debug('OPenelse>>>');
                    }
                }
                if(optyMapEnroll.containskey(providerid)){
                    if(prdAcc.containskey(providerid)){
                        account acct =  prdAcc.get(providerid);
                        double enrol = acct.of_enrolled_optys__c == Null ? 0 : acct.of_enrolled_optys__c;
                        acct.of_enrolled_optys__c=optyMapEnroll.get(providerid).size() +enrol;
                        prdAcc.put(acct.id,acct);
                        system.debug('Enroll>>>');
                    }else{
                        account acc = new account(id=providerid);
                        acc.of_enrolled_optys__c=optyMapEnroll.get(providerid).size() ;
                        prdAcc.put(acc.id,acc);
                        system.debug('Enrollelse>>>');
                    }
                }
                if(optyMapEnrollNotPri.containskey(providerid)){
                    if(prdAcc.containskey(providerid)){
                        account acct =  prdAcc.get(providerid);
                        double enrolWitotPri = acct.New_Enrollments__c == Null ? 0 : acct.New_Enrollments__c;
                        acct.New_Enrollments__c=optyMapEnrollNotPri.get(providerid).size() +enrolWitotPri;
                        prdAcc.put(acct.id,acct);
                        system.debug('WithOutEnroll>>>');
                    }else{
                        account acc = new account(id=providerid);
                        acc.New_Enrollments__c=optyMapEnrollNotPri.get(providerid).size() ;
                        prdAcc.put(acc.id,acc);
                        system.debug('WithOutEnrollelse>>>');
                    }
                }
            }
        }
        if(!prdAcc.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (prdAcc.values(),false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                   
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Update Open and Enrolled Count on Provider', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }
}