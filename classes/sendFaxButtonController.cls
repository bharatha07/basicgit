/**************************************************************************************************************************************
*Component Name : sendFaxButtonController 
*Developed By   : TEKsystems
*Description    : This class is controller for "Send Fax" QuickAction button on opportunity record page.
                  On click of this button,it will validate the opportunity record for below condtion, If  condition
                  is satified then send a Fax Email.
                  -->Checks if the opportunity status is either Enrolled/Stored.
*User Story     :  SFDC-2099
**********************************************************************************************************************************/

public class sendFaxButtonController {
    @auraenabled
    Public static validationWrapper validateOpportunity(string optyID){
        validationWrapper wrpcls= new validationWrapper();
        String faxID;
        map<id,opportunity> opts= new  map<id,opportunity>([select id,name,Status__c from Opportunity where ID =:optyID]);
        system.debug('the results are-->'+opts);
        if(opts!=null && !opts.isempty() && (opts.get(optyID).Status__c!='Enrolled' && opts.get(optyID).Status__c!='Stored')) {
            wrpcls.errorCheck=True;
            wrpcls.message='The opportunity is not Enrolled/Stored';
        }
        else{
            OpportunitySendFaxEmail.sendEmail(opts);
            wrpcls.errorCheck=false;
            wrpcls.message='Fax Email Sent for Opportunity';
        }
        return wrpcls;
    }
    
    Public class validationWrapper{
        @auraenabled public string message;
        @auraenabled public Boolean errorCheck;
        
    }
}