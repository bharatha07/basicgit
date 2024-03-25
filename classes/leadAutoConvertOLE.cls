/*************************************************************************************************************************
* Component Name: leadAutoConvertOLE
* Description: Auto converrt lead for OLE , will check email and send response to 3rd party as per business logic
* Story : SFDC-1170
* Date : 11-SEPT-2020
* DevelopedBy: TEKsystems
*****************************************************************************************************************************/
@RestResource(urlMapping='/OLESearch/*')
global with sharing class leadAutoConvertOLE{
    
    /*************************************************************************************************
* @description This method is used to post lead related data when email is sent to slaesforce
* @param - Email
* @story - SFDC-1170
* @return response to webservice
* @date - 11-SEPT-2020 (Teksystems)
*/
    @HttpPost
    global static OutputWrapper emailInforOLEdoPost(){
        OutputWrapper response = new OutputWrapper();
        
        savepoint sp = database.setsavepoint();  //Save point to roll back
        RestRequest req=RestContext.request;           
        Blob body = req.requestBody;
        String requestString = body.toString();
        try {        
            InputWrapper iw = (InputWrapper) JSON.deserialize(requestString, InputWrapper.class);            
            String emailInput= iw.email;
            List<Account> accList=[select id,PersonEmail from account where PersonEmail=:emailInput limit 1];
            if(accList.size()>0){    // if email found on contact ,send contact and opty id along with message.
                response.ContactId=accList[0].id;
                List<Opportunity> optyList=[SELECT Id, AccountId FROM Opportunity where AccountId=:accList[0].id limit 1];
                if(optyList.size()>0){
                    response.OptyId=optyList[0].id;
                } 
                response.message=System.Label.OLESearchC1;
            } 
            else    // if email not found on contact,check if its on lead ,if yes convert lead and send lead, contact and opty id along with message.
            {
                List<Lead> leadList= [SELECT id,Email,Name,utm_medium_LT__c,utm_campaign_LT__c,utm_source_LT__c,Last_Touch_Code__c FROM Lead WHERE Email=:emailInput limit 1];
                if(leadList.size()>0){
                    if(String.isNotBlank(iw.utmMeduLT)){
                    leadList[0].utm_medium_LT__c = iw.utmMeduLT;
                    }
                    if(String.isNotBlank(iw.utmCampLT)){
                    leadList[0].utm_campaign_LT__c = iw.utmCampLT;
                    }
                    if(String.isNotBlank(iw.utmSourLT)){
                    leadList[0].utm_source_LT__c = iw.utmSourLT;
                    }
                    if(String.isNotBlank(iw.lastTouchCode)){
                    leadList[0].Last_Touch_Code__c = iw.lastTouchCode;
                    }
                    if(String.isNotBlank(iw.utmMeduLT) || String.isNotBlank(iw.utmCampLT) || String.isNotBlank(iw.lastTouchCode) || String.isNotBlank(iw.utmSourLT)){
                    database.update(leadList[0], false);
                    }
                    system.debug('leadList---'+leadList[0]);
                    response=AutoConvertLead(leadList);  
                    response.message=System.Label.OLESearchC2;
                }
                else {  //if not then just send message 
                    response.message=System.Label.OLESearchC3;
                }
            }            
            return response;      
        }catch(Exception e){
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR,'Rollbacked');
            //  OutputWrapper responseE=new OutputWrapper();       
            System.debug('The following exception has occurred: ' + e.getMessage());
            response.message=e.getMessage();
            return response;
            
        }
        
    }
    //input wrapper to store request variable from 3rd party
    global class InputWrapper{
        global String email;
        global String lastTouchCode;
        global String utmSourLT;
        global String utmMeduLT;
        global String utmCampLT;
    }
    //output wrapper to send response to 3rd party
    global class OutputWrapper{
        global String ContactId;
        global String OptyId;
        global String message;
    }
    /*************************************************************************************************
* @description This method is used to Convert lead 
* @param - Lead
* @story - SFDC-1170
* @return wrapper instance to be used in response part
* @date - 11-SEPT-2020 (Teksystems)
*/
    global static OutputWrapper AutoConvertLead(List<Lead> LeadIds){
        OutputWrapper owv= new OutputWrapper();
        Database.LeadConvert Leadconvert = new Database.LeadConvert();
        Leadconvert.setLeadId(LeadIds[0].id);
        String oppName = LeadIds[0].Name;
        Leadconvert.setOpportunityName(oppName);
        LeadStatus Leads= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Leadconvert.setConvertedStatus(Leads.MasterLabel); 
        Database.LeadConvertResult Leadconverts = Database.convertLead(Leadconvert);
        boolean isSuccessful = Leadconverts.isSuccess();
        if(isSuccessful){
            List<Lead> conleads=[SELECT Id,ConvertedOpportunityId,convertedAccountId  FROM Lead WHERE Id=:LeadIds[0].id limit 1]; 
            if(conleads.size()>0){
                owv.ContactId=String.valueOf(conleads[0].ConvertedAccountId);
                owv.OptyId=String.valueOf(conleads[0].ConvertedOpportunityId);
            }
            
        }
        return owv;
    }
    
}