/**********************************************************************************************************************************************
*Component Name: PayableTriggerHandler
*Created Date :27 SEP 2021
*Description : Handler logic for DML operation on Payable object.
*Created By : Tejaswini Janda(TekSystems)
***Version          UserStory           Date            ModifiedBy             Description
	1.0             SFDC-2128           27 SEP 2021     Bharath(Teksystems)    Method to update LGP Account on payable Creation

**************************************************************************************************************************************************/
public class PayableTriggerHandler {
    public static void afterInsert(Map<Id,Payable__c> newMap){
        updateLGPAccount(newMap.values());
    }
    
    public static void updateLGPAccount(List<Payable__c> newPayables){
        set<id> opportunityIDS = new set<id>(); 
        Map<ID,ID> PayableLGPMap= new Map<ID,ID>();
        List<Payable__c> finalPayables= new List<Payable__c>();
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        for(Payable__c eachPayable:newPayables){
            if(eachPayable.Opportunity__c!=null){
               opportunityIDS.add(eachPayable.Opportunity__c);   
            }
            
        }
        if(opportunityIDS!=null && opportunityIDS.size()>0){
            Map<Id,Opportunity> optyProviderMap= new Map<Id,Opportunity>([select id,name,(select provider__c,opportunity__c,Provider_Facility__r.Facility__r.ParentID from Opportunity_Providers__r where Delivering_Provider__c=true and Provider_Facility__c!=null and provider__c!=null) from Opportunity where ID IN(select opportunity__c from Opportunity_Provider__c where opportunity__c!=null and Delivering_Provider__c=true and opportunity__c  IN:opportunityIDS)]);
            If(optyProviderMap!=null && !optyProviderMap.isEmpty()){
                for(Opportunity eachoptyProviderMap:optyProviderMap.values()){
                    PayableLGPMap.put(eachoptyProviderMap.Opportunity_Providers__r[0].opportunity__c,eachoptyProviderMap.Opportunity_Providers__r[0].Provider_Facility__r.Facility__r.ParentID);
                }
            }
        }
        system.debug('payablemap==========>>>>>>>'+PayableLGPMap);
        if(PayableLGPMap!=null && !PayableLGPMap.isEmpty()){
            for(Payable__c eachPay:newPayables){
                if(PayableLGPMap.containsKey(eachPay.opportunity__c)){
                    Payable__c payabletoUpdate = new Payable__c(Id = eachPay.Id, Payable_LGP__c= PayableLGPMap.get(eachPay.opportunity__c)!=null?PayableLGPMap.get(eachPay.opportunity__c):null);
                    finalPayables.add(payabletoUpdate);
                } 
            } 
        }
        //update Payable
        if(finalPayables!= null && !finalPayables.isEmpty()){
            List<Database.SaveResult> saveResults = Database.update(finalPayables,false);
            for (integer i=0; i<saveResults.size(); i++) {
                string ErrDetail='';
                if (!saveResults.get(i).issuccess()) {
                    //Database.Error error  = ;
                    for (Database.Error e : saveResults.get(i).getErrors()) {
                        ErrDetail+=e.getMessage()+e.getStatusCode();
                        system.debug('error..................'+e.getMessage());  
                    }
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'Payable update for LGP Account', 'Apex', ErrDetail, false, false);
                    cbrErrorLog.add(cbr);
                }
            }
        }
        if(cbrErrorLog.size()>0){
            Database.insert(cbrErrorLog, false);  
        }
    }  
}