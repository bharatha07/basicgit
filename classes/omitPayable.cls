/**************************************************************************************************************************************
*Component Name : omitPayable 
*Developed By   : TEKsystems
*Description    : This class is controller for "Omit Payable" button on Payable record page.
                  On click of this button,it will update the status to Omit, except for the payable status as PAID.
*User Story     :  SFDC-1103
**********************************************************************************************************************************/

public class omitPayable {
    @AuraEnabled
    Public static Payable__c getPayable(string payId,boolean check){
        Payable__c pay = [select id,name,Status__c from Payable__c where id=:payId];
        
        if(!check){
            if(pay.Status__c !='Paid'){
                pay.Status__c='Omit';
                update pay;
            } 
        }
        return pay;
    }  
}