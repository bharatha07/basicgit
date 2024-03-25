/**************************************************************************************************************************************
*Component Name : FaxButtonController 
*Developed By   : TEKsystems
*Description    : This class is controller for "EnrollmentFaxButton" and "StorageFaxButton" QuickAction button on opportunity record page.
On click of this button,it will validate the opportunityprovider record for below condtion, If  condition
is satified then send a Fax Email.
--> Checks for primary opportunityprovider for an Enrolled/Stored Opportunity.
--> Checks whether Fax number available at facility.
--> If fax is available the sends the fax email based on button click either Enrolled or Stored.
*User Story     :  SFDC-2198
**********************************************************************************************************************************/


public class FaxButtonController {
    
    @auraenabled
    Public static validationWrapper validateOpportunity(string optyID, Boolean Enrollment, Boolean Storage){
        validationWrapper wrpcls= new validationWrapper();
        List<Opportunity_Provider__c> optyProvider= new  List<Opportunity_Provider__c>();
        optyProvider=[select id,ProviderCredential__c, Provider__c,Opportunity__c, Provider_Facility__c, Provider__r.FirstName, Provider__r.LastName,Provider_Facility__r.Facility_Fax__c from Opportunity_Provider__c where Primary_Provider__c =true and Provider__c !=null and Provider_Facility__c!=null and Opportunity__c =:optyID];
        system.debug('the results are-->'+optyProvider);
        if(optyProvider.size() == 0) {
            wrpcls.errorCheck=True;
            wrpcls.message='No Primary Opportunity Provider';
        }
        
        else if(optyProvider.size()>0){
            string faxNumber=optyProvider[0].Provider_Facility__r.Facility_Fax__c;
            if(faxNumber==null){
                wrpcls.errorCheck=True;
                wrpcls.message='Facility Fax Number is Missing';
            }
            // OpportunitySendFaxEmail.sendEmail(opts);
            else if(Enrollment && !Storage){
                opportunitySendFaxButtonClass.sendEmail(optyID, Enrollment, Storage);
                wrpcls.errorCheck=False;
                wrpcls.message='Initiated Enrollment Fax';
            }
            else  if(!Enrollment && Storage){
                opportunitySendFaxButtonClass.sendEmail(optyID, Enrollment, Storage);
                wrpcls.errorCheck=False;
                wrpcls.message='Initiated Storage Fax';
            }
            
        }
        
        return wrpcls;
    }
    
    Public class validationWrapper{
        @auraenabled public string message;
        @auraenabled public Boolean errorCheck;
        
    }
    
}