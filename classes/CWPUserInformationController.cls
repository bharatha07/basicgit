/**************************************************************************************************************************************
* ComponentName : CWPUserInformationController
* CreatedBy : TEKsystems
* Description :US-595- If there is a open or enrolled opportunity related to current active account then we enable 'Inactivate button'
US-960- If current account is active and primary account of opportunity with status Enrolled or stored then 'Login as Client' is enabled.
US-961- If current account is inactive and primary account of opportunity with status enrolled or stored then 'Activate Login' button is enabled.
US-103 - Generate random password and update Temporary Passwd and Password Expiry date on account

***************************************************************************************************************************************/
global with sharing class CWPUserInformationController{
    public Boolean loginButton {get;set;}//This boolean is set to true if a current account is Active primary Account of opp whose status is enrolled or stored 
    public Boolean activeLoginButton {get;set;}//This boolean is set to true if a current account is inActive primary Account of opp whose status is enrolled or stored 
    public Boolean inactiveLoginButton {get;set;}//This boolean is set to true if current account is active and related to opportunity with status enrolled or open
    public Account acc {get;set;}
    public String accId {get;set;}
    public Boolean loginWhenActive;
    public Boolean resetPasswordButton{get;set;}
    public Boolean updateCognitoinfo{get;set;}                 // For story 1091
    public Boolean checkResetPWButton;
    public static string accountEmail;
    public CWPUserInformationController(ApexPages.StandardController controller){
        acc = new Account();
        //accountEmail = null;
        accId = ApexPages.currentPage().getParameters().get('id');
        acc = [Select Id,User_Name__pc,CWP_Activation_Date__pc,CWP_Last_Login_Date__pc,Temporary_Password__pc,Client_Flag__pc,PersonEmail,
               Active__pc,SCSS_Contact_Id__c,CWP_Temporary_Password_Expiration__pc,Cognito_Account_Status__pc,IsPersonAccount From Account Where Id=:accId];
        loginButton = false;
        accountEmail = acc.PersonEmail;
        inactiveLoginButton = false;
        loginWhenActive = false;
        resetPasswordButton = false;
        checkResetPWButton = false;
        checkLoginButton();
        
        //This will enable the update cognito information button when client flag is ture.   
        /*if(acc.Client_Flag__pc==true){
            updateCognitoinfo=true;
        }
        else{
            updateCognitoinfo=false; 
        }*/
        //story-SFDC-1702 making update cognito information button to always enable
        updateCognitoinfo=true;
        
    }
    public void checkLoginButton(){
        List<OpportunityContact__c> oppContactList = [Select id,PersonAccount__c,Opportunity__c,Opportunity__r.StageName,Opportunity__r.Status__c,Opportunity__r.AccountId,PersonAccount__r.Active__pc,Primary__c,PersonAccount__r.Client_Flag__pc from OpportunityContact__c where PersonAccount__c =:accId];
        // AND Primary__c = TRUE
        if(oppContactList!=null && !oppContactList.isEmpty()){
            Set<String> loginStatus = new Set<String>{'Enrolled','Stored','Pending'};
                Set<String> inActiveStatus = new Set<String>{'Enrolled','Open'};
                    for(OpportunityContact__c oppContact:oppContactList){
                        if(loginStatus.contains(oppContact.Opportunity__r.Status__c) && oppContact.Primary__c == true){
                            loginWhenActive = true;//when current account is primary account related to enrolled or stored opportunity then this boolean is set to true. This variable is used to enable and disable 'Login as Client' button on click of 'Activate Login' or 'Inactivate login' buttons. 
                            
                            //If current account is active primary account related to enrolled or stored opp then we enable login button 
                            if(oppContact.PersonAccount__r.Active__pc == true){
                                loginButton = true;
                            }
                            //else 'Activate login' buttion is enabled
                            else{
                                activeLoginButton = true;
                            }
                        }
                        //If open or enrolled opty is related to current active account then Inactivate button is enabled 
                        if(inActiveStatus.contains(oppContact.Opportunity__r.Status__c) && oppContact.PersonAccount__r.Active__pc == true){
                            inactiveLoginButton = true;
                        }
                        if(oppContact.Opportunity__r.StageName != 'Closed Lost' && (inActiveStatus.contains(oppContact.Opportunity__r.Status__c) || loginStatus.contains(oppContact.Opportunity__r.Status__c)) ){
                            checkResetPWButton = true;
                            if(oppContact.PersonAccount__r.Active__pc == true && oppContact.PersonAccount__r.Client_Flag__pc){
                                resetPasswordButton = true;
                            }
                            
                        }
                    }//End of for loop
        }
    }
    
    
    //This method is called on click of 'Activate Login' button
    public PageReference activateLoginButton(){
        system.debug('loginWhenActive-----'+loginWhenActive);
        if(loginWhenActive == true){
            System.debug('loginWhenActive========='+loginWhenActive);
            loginButton = true;
        }
        if(checkResetPWButton == true){
            resetPasswordButton = true;
        }
        activeLoginButton = false;
        inactiveLoginButton = true; 
        acc.Active__pc = true;
        update acc;
        
        return null;
    }
    //This method is called on click of 'Inactivate Login' button
    public PageReference inactiveLoginBtn(){
        activeLoginButton = true;
        loginButton = false;
        inactiveLoginButton = false; 
        resetPasswordButton = false;
        acc.Active__pc = false;
        update acc;
        
        return null;
    }
    public Account getCWPUserInformation(){
        String accId = ApexPages.currentPage().getParameters().get('id');
        return [Select Id,User_Name__pc,CWP_Activation_Date__pc,Active__pc,CWP_Last_Login_Date__pc,Temporary_Password__pc,CWP_Temporary_Password_Expiration__pc,Cognito_Account_Status__pc,Client_Flag__pc  From Account Where id =: accId ];
        
    }
    
    //method to generate a random passwd with length specified in the custom label called password length.
    //This method will also set the Temporary Passwd expiration field to 30 days from created date.
    //This will navigate to different url for reset password- SFDC-105 
  /*  public pageReference generateRandomPasswd() {
        PageReference pageRef1 = new PageReference('');
        Organization org = [SELECT id, Name FROM Organization];
        if(org!=null){
            String orgId = String.valueOf(org.Id);
            if(orgId.equals(Label.SfdcUATOrgId)){
                pageRef1 = new PageReference(Label.Reset_PWDLink_UAT);
            }else if(orgId.equals(Label.SfdcPRODOrgId)){
                pageRef1 = new PageReference(Label.Reset_PWDLink_PROD);
            } 
            pageRef1.setRedirect(true);
        }
        return pageRef1;   
    } */

    
    
    global static void generateRandomPasswd(){
        String accountId = ApexPages.currentPage().getParameters().get('id');
        Account accRecc = [select id,personEmail from account where id =:accountId];
        HttpRequest req = new HttpRequest();
        Http http = new Http();        
        String resetpwurl = Label.ResetPWUrl;
        resetpwurl = resetpwurl +accRecc.personEmail+'&Id='+accountId;
        req.setEndpoint(resetpwurl);
        req.setMethod('POST');
        HTTPResponse resp = http.send(req);
        resp.getStatus();

    }
    /*************************************************************************************************
     * @description This method is used to navigate to sites for cognito
     * @param - NONE
     * @story - SFDC-1091
     * @return pageReference 
     * @date - 14-AUG-2020 (Teksystems)
     */  
    public pageReference updateCognitoInfo() { 
        PageReference pageRefCong = new PageReference('');
        Organization org = [SELECT id,IsSandbox,Name FROM Organization];
        String orgId = String.valueOf(org.Id);
        if(org!=null){
        if(org.isSandbox==true && orgId.equals(Label.SfdcUATOrgId)){
            pageRefCong = new PageReference(Label.Update_Cognito_Information+'emailId='+acc.PersonEmail+'&Id='+acc.id);
        }else if(orgId.equals(Label.SfdcPRODOrgId)){
            pageRefCong = new PageReference(Label.Update_Cognito_Information_Prod+'emailId='+acc.PersonEmail+'&Id='+acc.id);
        }
        }
        pageRefCong.setRedirect(true);
        return pageRefCong;
    }
    
   
}