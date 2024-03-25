/*
    Name : NewOpportunityController
    Author : Pari
    Date : March 1 2019
    Description : This Controller create new opportunity from Account
    User Story : CBRSFDC8-755
    Verson      User Story         Date          ModifiedBy
    2.0         SFDC-982         June 19 2020   Tejaswini
    2.1          SFDC - 1154        Aug 27      Tejaswini
*/

global class NewOpportunityController{
    public Boolean disablePicklist {get;set;}
    public Id accId {get;set;}
    public String primarySource {get;set;}
    public Boolean isError;
    public Opportunity oppObject {get;set;}
    public List<SelectOption> LeadSourceVal {get; set;}
    public String fromPage;
    public NewOpportunityController(ApexPages.StandardController controller) {
        accId = ApexPages.currentPage().getParameters().get('accId');
        fromPage = ApexPages.currentPage().getParameters().get('from');
        primarySource = ApexPages.currentPage().getParameters().get('primarySource');
        disablePicklist = false; 
        Account acc = [Select Id,Name,Lead_Assignment__pc,Primary_Source__pc,First_Touch_Code__pc,Last_Touch_Code__pc,utm_source_FT__pc,utm_medium_FT__pc,utm_campaign_FT__pc,utm_campaign_LT__pc,utm_medium_LT__pc,utm_source_LT__pc,MQL_Score__pc From Account Where Id=:accId];
        oppObject = new Opportunity(); 
        oppObject.Primary_Source__c = acc.Primary_Source__pc;
        oppObject.Lead_Assignment__c  = acc.Lead_Assignment__pc;
        oppObject.Lead_Source_Code__c = acc.First_Touch_Code__pc;
        oppObject.Opty_Source_Code__c = acc.Last_Touch_Code__pc;
        oppObject.Lead_UTM_Source__c = acc.utm_source_FT__pc;
        oppObject.Lead_UTM_Medium__c = acc.utm_medium_FT__pc;
        oppObject.Lead_UTM_Campaign__c = acc.utm_campaign_FT__pc;
        oppObject.Opty_UTM_Campaign__c = acc.utm_campaign_LT__pc;
        oppObject.Opty_UTM_Medium__c = acc.utm_medium_LT__pc;
        oppObject.Opty_UTM_Source__c = acc.utm_source_LT__pc;
        oppObject.MQL_Score__c = acc.MQL_Score__pc;
        if(String.isNotBlank(acc.Last_Touch_Code__pc) && acc.Last_Touch_Code__pc !='SFDC'){
            recursiveClass.createCampaignInfluence = true;
        }
        if(String.isNotBlank(primarySource)){
            oppObject.Primary_Source__c = 'I\'m a Current Client'; 
        }
        oppObject.AccountId = accId;
        LeadSourceVal = new List < SelectOption > (); 
            if(UserInfo.getProfileId() == Label.CSS_Profile_Id || UserInfo.getUserRoleId() == Label.CSS_RoleId || UserInfo.getProfileId() == Label.Client_Services_Special){
                oppObject.StageName = 'Marketing Qualified';
                oppObject.LeadSource = 'CSS Client Referral';//SFDC-1787 Changed Client Referral to CSS Client Referral
                LeadSourceVal.add(new SelectOption('CSS Client Referral','CSS Client Referral'));//SFDC-1787 Changed Client Referral to CSS Client Referral
                disablePicklist = true;
            }
            else{
                oppObject.StageName = 'Building Genuine Rapport';
                LeadSourceVal.add(new SelectOption('Phone','Phone'));
                LeadSourceVal.add(new SelectOption('Chat','Chat'));
                LeadSourceVal.add(new SelectOption('Email','Email'));
                LeadSourceVal.add(new SelectOption('Direct Referral','Direct Referral'));
            }
    }
    public PageReference  saveOpportunity(){
            system.debug('test page 1 debug');
            Boolean noError = false;
            oppObject.Name = 'Test';
            oppObject.CloseDate= System.today();
                try{
                    insert oppObject;
                    
                }catch(Exception ex){
                    noError = true;
                }
        pagereference pr = new pagereference('/' + oppObject.id);
        return pr;
    }
    //Check  opportunity status In(open or enrolled)
    @AuraEnabled
    webservice static String checkOpportunityOnContact(Id accId){
        List<OpportunityContact__c> ocrList = new List<OpportunityContact__c>();
        Boolean createOpty = false; //If any of oppcontact's role is mother then this flag is set to true.
        Set<String> oppStatus = new Set<String>{'Open','Enrolled','Stored'};
        //Query on OpportunityContactRole Objectwith Person Account id
        ocrList = [Select Id,Opportunity__c,PersonAccount__c, Opportunity__r.Status__c,Role__c,Primary__c  From OpportunityContact__c Where PersonAccount__c =:accId];
        //If opportunity contact roles are present then we add status of opportunity related to that OCR to OCROppStatus.
        Set<String> OCROppStatus = new Set<String>();
        if(ocrList !=null && !ocrList.isEmpty()){
            for(OpportunityContact__c ocr:ocrList){
                OCROppStatus.add(ocr.Opportunity__r.Status__c);
                if((ocr.Role__c == 'Mother') && (ocr.Opportunity__r.Status__c == 'Open' || ocr.Opportunity__r.Status__c == 'Enrolled')){
                    createOpty = true;//If createOpty is true then user cannot create opportunity
                }
            }
        }
        //if there are no opportunitycontactRoles then opportunity can be created for current contact
        else{
            return 'CreateOpp';
        }
        
        if(createOpty == false){
            if(OCROppStatus!=null && !OCROppStatus.isEmpty()){
            /* if(OCROppStatus.containsAll(oppStatus) || (OCROppStatus.contains('Stored') && (OCROppStatus.contains('Open') || OCROppStatus.contains('Enrolled')))){
                    return 'CurrentClientOpp';//When Opp status with stored and open or enrolled
                }
                else*/
                if(OCROppStatus.contains('Stored')){
                    return 'CurrentClientOpp';//When Opp status is only stored
                }
                else if((OCROppStatus.contains('Open') || OCROppStatus.contains('Enrolled'))){
                    return 'CreateOpp';//When opp status is open or enrolled
                }
                else{
                    return 'CreateOpp';
                }
            }
            else{
                return 'CreateOpp';
            }
        }
        else{
            return 'OpenOrEnrollOpp';
        }
        
    }
}