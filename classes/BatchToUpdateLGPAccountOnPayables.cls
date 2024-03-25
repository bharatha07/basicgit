/**************************************************************************************************************************************
*Component Name : BatchToUpdateLGPAccountOnPayables 
*Developed By   : TEKsystems
*Description    : This Batch will update the LGP(large group practice) facility on Payable associated to opportunity DeliveryProvider.
*User Story     :  SFDC-1884
**********************************************************************************************************************************/
global class BatchToUpdateLGPAccountOnPayables implements Database.Batchable <sObject>{
    List<String> errors = new List<String>();
    Integer nDays;
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
    public BatchToUpdateLGPAccountOnPayables(integer n){
        this.nDays=n;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('inside start');
        //Getting opportunity record where status is stored
        String  query='';
        if(Test.isRunningTest()){
            query=query+'select id,name,Payable_LGP__c,Opportunity__c,Provider_ID__c from Payable__c where Provider_ID__c!=null and Opportunity__c!=null and  Payable_LGP__c=null and Opportunity__r.Status__c!=\'Closed_Lost\' and CreatedDate=today';
        }
        else{
            query=query+'select id,name,Payable_LGP__c,Opportunity__c,Provider_ID__c from Payable__c where Provider_ID__c!=null and Opportunity__c!=null and  Payable_LGP__c=null and Opportunity__r.Status__c!=\'Closed_Lost\' and CreatedDate=LAST_N_DAYS:'+nDays;
        }
        system.debug('query==========>>>>>>>'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Payable__c> scope){
        set<id> providerIDS = new set<id>();
        set<id> opportunityIDS = new set<id>();
        Map<ID,ID> PayableLGPMap= new Map<ID,ID>();
        List<Payable__c> finalPayables= new List<Payable__c>();
        try{
            if(scope!=null && !scope.isEmpty()){
                for(Payable__c eachPayable:scope){
                    opportunityIDS.add(eachPayable.Opportunity__c);  
                }
            } 
            if(opportunityIDS!=null && opportunityIDS.size()>0){
                Map<Id,Opportunity> optyProviderMap= new Map<Id,Opportunity>([select id,name,(select provider__c,Provider_Facility__r.Facility__r.ParentID from Opportunity_Providers__r where Delivering_Provider__c=true and Provider_Facility__c!=null and provider__c!=null) from Opportunity where ID IN:opportunityIDS]);
                If(optyProviderMap!=null && !optyProviderMap.isEmpty()){
                    for(Opportunity eachoptyProviderMap:optyProviderMap.values()){
                        PayableLGPMap.put(eachoptyProviderMap.Opportunity_Providers__r[0].provider__c,eachoptyProviderMap.Opportunity_Providers__r[0].Provider_Facility__r.Facility__r.ParentID);
                    }
                }
            }
             system.debug('payablemap==========>>>>>>>'+PayableLGPMap);
            if(PayableLGPMap!=null && !PayableLGPMap.isEmpty()){
                for(Payable__c eachPay:scope){
                    if(PayableLGPMap.containsKey(eachPay.Provider_ID__c)){
                        eachPay.Payable_LGP__c=PayableLGPMap.get(eachPay.Provider_ID__c)!=null?PayableLGPMap.get(eachPay.Provider_ID__c):null;
                        finalPayables.add(eachPay);
                    } 
                } 
            }
            system.debug('the payablerecords are'+finalPayables);
            //Insert Payable
            if(finalPayables!= null && !finalPayables.isEmpty()){
                List<Database.SaveResult> saveResults = Database.update(finalPayables,false);
                for (integer i=0; i<saveResults.size(); i++) {
                    string ErrDetail='';
                    if (!saveResults.get(i).issuccess()) {
                        //Database.Error error  = ;
                        for (Database.Error e : saveResults.get(i).getErrors()) {
                            ErrDetail+=e.getMessage()+e.getStatusCode();
                            errors.add(e.getMessage());
                            system.debug('error..................'+e.getMessage());
                            
                        }
                        cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'Payable update for LGP Account', 'Apex', ErrDetail, false, false);
                        cbrErrorLog.add(cbr);
                    }
                }
            }
            
        }
        catch(Exception ex){
            system.debug('Exception Found----'+ex.getMessage());
            string exceptionerror =ex.getMessage();
            system.debug('Exception Found----'+exceptionerror);
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Payable update for LGP Account', 'Apex', exceptionerror, false, false);
            cbrErrorLog.add(cbr);
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
    }
    global void finish(Database.BatchableContext BC){  
    }
}