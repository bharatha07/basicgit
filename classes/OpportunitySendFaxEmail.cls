/**********************************************************************************************************************************************
*Component Name: OpportunitySendFaxEmail
*Created Date : 30th August 2021
*Description : To send FAX email for opportunity where status to Enrolled/Stored.
*Created By : Bharath Avaldar(TekSystems)
*Story Number: 1955,2088
**************************************************************************************************************************************************/

public class OpportunitySendFaxEmail {
    
    public static void sendEmail(Map<Id,opportunity> optyMap){
        Map<Id,Opportunity_Provider__c> primaryOptyProvider=new Map<ID,Opportunity_Provider__c>();
        List<emailWrapper> emailfeilds= new List<emailWrapper>();
        system.debug('the entry optys--->'+optyMap);
        List<ID> optyIDS= new List<ID>();
        Map<Id,Opportunity_Provider__c> optyWithOptyProvider= new Map<Id,Opportunity_Provider__c>();
        Map<Id,OpportunityContact__c> motherOptyCon= new Map<Id,OpportunityContact__c>();
        Map<Id,OpportunityContact__c> babyOptyCon= new Map<Id,OpportunityContact__c>();
        List<OpportunityContact__c > optyConList= new  List<OpportunityContact__c >();
        Map<Id,String> emailAddress= new Map<Id,String>();
        string domain='@useitfax.com';
        
        //Fetching Opty provider Records for the Enrolled/Stored Opportunity
        if(optyMap!=null && !optyMap.isEmpty()){
            primaryOptyProvider=new Map<ID,Opportunity_Provider__c>([select id,ProviderCredential__c, Provider__c,Opportunity__c, Provider_Facility__c, Provider__r.FirstName, Provider__r.LastName,Provider_Facility__r.Facility_Fax__c from Opportunity_Provider__c where Primary_Provider__c =true and Provider__c !=null and Provider_Facility__c!=null and Opportunity__c  IN :optyMap.keyset()]);
            if(primaryOptyProvider!=null && !primaryOptyProvider.isEmpty()){
                for(Opportunity_Provider__c op:primaryOptyProvider.values()){
                    optyWithOptyProvider.put(op.Opportunity__c,op);// Hold key as opportunity ID and values as Opportunity_Provider Records
                }
            }
            //Fetching Opty Contact Records for the Enrolled/Stored Opportunity
            optyConList= new  List<OpportunityContact__c >([select id,name,Role__c,PersonAccount__c,Opportunity__c, PersonAccount__r.FirstName, PersonAccount__r.Lastname,PersonAccount__r.PersonBirthdate from OpportunityContact__c where Role__c IN ('Mother','Baby') and PersonAccount__c !=null and Opportunity__c IN :optyMap.keyset()]);
            if(optyConList!=null && !optyConList.isEmpty()){
                for(OpportunityContact__c eachrec:optyConList){
                    if(eachrec.Role__c=='Mother'){
                        motherOptyCon.put(eachrec.Opportunity__c, eachrec);
                    }
                    if(eachrec.Role__c=='Baby'){
                        babyOptyCon.put(eachrec.Opportunity__c, eachrec);
                    }
                }
            }
        }
        system.debug('the entry optyWithOptyProvider--->'+optyWithOptyProvider);
        system.debug('the entry motherOptyCon--->'+motherOptyCon);
        system.debug('the entry babyOptyCon--->'+babyOptyCon);
        //Fetchs Details of Opty provider and Opty Contact details and Assigning to Wrapper Class
        for(opportunity eachOpty:optyMap.values()){
            if(optyWithOptyProvider!=null && !optyWithOptyProvider.isEmpty()){
                if(optyWithOptyProvider.get(eachOpty.Id).Provider_Facility__r.Facility_Fax__c!=null){
                    emailWrapper eachWrapper= new emailWrapper();
                    string faxNumber=optyWithOptyProvider.get(eachOpty.Id).Provider_Facility__r.Facility_Fax__c;
                    string emailToAddress=optyWithOptyProvider.get(eachOpty.Id).ProviderCredential__c+faxNumber+domain; 
                    system.debug('the emailToAddress-->'+emailToAddress);
                    eachWrapper.opportunityID=eachOpty.id;
                    eachWrapper.primaryProvider=(optyWithOptyProvider.get(eachOpty.id).Provider__r.FirstName!=null?optyWithOptyProvider.get(eachOpty.id).Provider__r.FirstName:'No FirstName')+' '+optyWithOptyProvider.get(eachOpty.id).Provider__r.LastName;
                    eachWrapper.emailAddress=emailToAddress;
                    if(motherOptyCon!=null && !motherOptyCon.isEmpty()){
                        eachWrapper.individualName=(motherOptyCon.get(eachOpty.id).PersonAccount__r.FirstName!=null?motherOptyCon.get(eachOpty.id).PersonAccount__r.FirstName:'No FirstName')+' '+motherOptyCon.get(eachOpty.id).PersonAccount__r.LastName;
                        eachWrapper.motherDOB=motherOptyCon.get(eachOpty.id).PersonAccount__r.PersonBirthdate!=null?motherOptyCon.get(eachOpty.id).PersonAccount__r.PersonBirthdate.format():' ';
                    } 
                    emailfeilds.add(eachWrapper);
                    system.debug('The wrapper Class feild--->'+eachWrapper);
                    optyIDS.add(eachOpty.Id);
                }  
            }  
        }
        system.debug('The wrapper Class feild--->'+emailfeilds);
        system.debug('TheoptyIDSd--->'+optyIDS);
        //Calling future method to Send FAX emails
        if(!emailfeilds.isEmpty() && emailfeilds.size()>0){
            string finalOptyList= json.serialize(emailfeilds);
            if(String.isNotEmpty(finalOptyList)){
                system.debug('calling future');
                //FutureClassToSendOptyFAXEmails.sendOptyFAXEmails(finalOptyList,optyIDS); 
                OpportunitySendFaxEmailStorage.sendOptyFAXEmails(finalOptyList,optyIDS);
            }
        }
    }
    //Wrapper class to Hold opportunity Provider and Opportunity Contact Feilds
    public class emailWrapper{
        public string opportunityID;
        public string primaryProvider;
        public string individualName;
        public string motherDOB;
        public string emailAddress;
    }
}