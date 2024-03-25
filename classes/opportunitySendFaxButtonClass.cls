/**********************************************************************************************************************************************
*Component Name: opportunitySendFaxButtonClass
*Created Date : 27 November 2021
*Description : This Class contains enroll and stored fax email methods for sending emails for the opty.
*Created By : Bharath Avaldar(TekSystems)
*Story Number: SFDC-2198
*Test Class : FaxButtonControllerTest
**************************************************************************************************************************************************/
public class opportunitySendFaxButtonClass {
    
    public static void sendEmail(ID optyID,Boolean Enrollment, Boolean Storage){
        emailWrapper eachWrapper= new emailWrapper();
        Map<Id,opportunity> opty = new Map<Id,opportunity>();
        opportunity optyValues= new opportunity();
        Map<Id,Opportunity_Provider__c> optyWithOptyProvider= new Map<Id,Opportunity_Provider__c>();
        Map<Id,List<Asset>> optyAsset = new Map<Id,List<Asset>>();
        Map<Id,OpportunityContact__c> motherOptyCon= new Map<Id,OpportunityContact__c>();
        Map<Id,OpportunityContact__c> babyOptyCon= new Map<Id,OpportunityContact__c>();
        Map<Id,List<OpportunityContact__c>> optyConList = new Map<Id,List<OpportunityContact__c>>();
        Map<Id,Opportunity_Provider__c> primaryOptyProvider=new Map<ID,Opportunity_Provider__c>();
        List<Messaging.SingleEmailMessage> allMessage = new  List<Messaging.SingleEmailMessage>();
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        Map<Id,String> emailAddress= new Map<Id,String>();
        string domain='@useitfax.com';
        
        //Fetching Opty provider/Opty Contact and Asset  Records for the choosen Opportunity
        if(optyID!=null){
            opty = new Map<Id,opportunity>([select id,name,Status__c,Enrollment_Date__c,Storage_Date__c, Due_Date__c, of_CT_at_enrollment__c, of_CB_at_enrollment__c,Stored_CB__c,Stored_CT__c,
                                            (select id,name,Opportunity__c,BloodVolume__c,TotalCellCount__c from Assets__r where  Status ='Stored' and Opportunity__c!=null and Opportunity__r.Status__c='Stored' and Type__c ='Cord Blood'),
                                            (select id,ProviderCredential__c, Provider__c,Opportunity__c, Provider_Facility__c, Provider__r.FirstName, Provider__r.LastName,Provider_Facility__r.Facility_Fax__c from Opportunity_Providers__r where Primary_Provider__c =true and Provider__c !=null and Provider_Facility__c!=null),
                                            (select id,name,Role__c,PersonAccount__c,Opportunity__c, PersonAccount__r.FirstName, PersonAccount__r.Lastname,PersonAccount__r.PersonBirthdate from Account_Opportunities__r where Role__c IN ('Mother','Baby') and PersonAccount__c !=null)  from Opportunity where id = :optyID]);
            
            if(opty!=null && !opty.isEmpty()){
                for(opportunity eachopty:opty.values()){
                    optyAsset.put(eachopty.id,eachopty.Assets__r);
                    optyWithOptyProvider.put(eachopty.id,eachopty.Opportunity_Providers__r);
                    optyConList.put(eachopty.id,eachopty.Account_Opportunities__r);
                }
                system.debug('the optys are -->'+opty);
                system.debug('the assets are -->'+optyAsset);
                system.debug('the optyProvider are -->'+optyWithOptyProvider);
                system.debug('the optyContact are -->'+optyConList);
            }
            
            if(optyConList!=null && !optyConList.isEmpty()){
                for(OpportunityContact__c eachrec:optyConList.get(optyID)){
                    if(eachrec.Role__c=='Mother'){
                        motherOptyCon.put(eachrec.Opportunity__c, eachrec);
                    }
                    if(eachrec.Role__c=='Baby'){
                        babyOptyCon.put(eachrec.Opportunity__c, eachrec);
                    }
                }
            }
            //Fetchs Details of Opty provider and Opty Contact details and Assigning to Wrapper Class
            if(optyWithOptyProvider!=null && !optyWithOptyProvider.isEmpty() && optyWithOptyProvider.containsKey(optyID)){
                if(optyWithOptyProvider.get(optyID).Provider_Facility__r.Facility_Fax__c!=null){
                    string faxNumber=optyWithOptyProvider.get(optyID).Provider_Facility__r.Facility_Fax__c;
                    string emailToAddress=optyWithOptyProvider.get(optyID).ProviderCredential__c+faxNumber+domain; 
                    system.debug('the emailToAddress-->'+emailToAddress);
                    eachWrapper.opportunityID=optyID;
                    eachWrapper.primaryProvider=(optyWithOptyProvider.get(optyID).Provider__r.FirstName!=null?optyWithOptyProvider.get(optyID).Provider__r.FirstName:'No FirstName')+' '+optyWithOptyProvider.get(optyID).Provider__r.LastName;
                    eachWrapper.emailAddress=emailToAddress;
                    if(motherOptyCon!=null && !motherOptyCon.isEmpty() && motherOptyCon.containsKey(optyID)){
                        eachWrapper.individualName=(motherOptyCon.get(optyID).PersonAccount__r.FirstName!=null?motherOptyCon.get(optyID).PersonAccount__r.FirstName:'No FirstName')+' '+motherOptyCon.get(optyID).PersonAccount__r.LastName;
                        eachWrapper.motherDOB=motherOptyCon.get(optyID).PersonAccount__r.PersonBirthdate!=null?motherOptyCon.get(optyID).PersonAccount__r.PersonBirthdate.format():' ';
                    } 
                    system.debug('The wrapper Class feild--->'+eachWrapper);
                }  
            } 
            //enrollment Fax send
            If(opty!=null && !opty.isEmpty() && eachWrapper!=null){
                if(Enrollment){
                    system.debug('Inside Enrollment');
                    optyValues=opty.values();
                    Messaging.SingleEmailMessage enrollEmail=sendEnrollmentFax(optyValues,eachWrapper);
                    allMessage.add(enrollEmail);
                }
                //Storage Fax Send
                else if(Storage){
                    system.debug('Inside Storage');
                    optyValues=opty.values();
                    List<Messaging.SingleEmailMessage> storageEmail=sendStoredFax(optyValues,eachWrapper,optyAsset);
                    allMessage.addAll(storageEmail);   
                }
            }
        }   
        try{ 
            if(allMessage.size()>0){
                List<Messaging.SendEmailResult> result = Messaging.sendEmail(allMessage);
            }
            
        }
        catch(System.EmailException ex){
            string ErrDetail;
            ErrDetail = ex.getMessage();
            cbr_Error_Log__c cbr =UtilityClass.logErrors(null, ' Fax Email Notification for opportunity set to Enrolled/Stored from UI', 'Apex Error', ErrDetail, false, false);
            cbrErrorLog.add(cbr);
        }
        
        if(!cbrErrorLog.isEmpty()){
            Database.insert(cbrErrorLog, false);
        }
    }
    public static Messaging.SingleEmailMessage sendEnrollmentFax(opportunity optys, emailWrapper wrap){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'customercare@cordblood.com'];
        EmailTemplate Enrolltemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name='Send FAX Notification Enrollment'];
        String subject = Enrolltemplate.Subject;
        String htmlBody = Enrolltemplate.HtmlValue;
        String todaysDate=system.today().format();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        DateTime enrollmentDateTime=optys.Enrollment_Date__c!=null?optys.Enrollment_Date__c:null;
        string enrollmentDate = date.newinstance(enrollmentDateTime.year(), enrollmentDateTime.month(), enrollmentDateTime.day()).format();
        String optyDueDate=optys.Due_Date__c!=null?optys.Due_Date__c.format():' ';
        String cbCollection=optys.of_CB_at_enrollment__c>=1?'Yes':'No';
        String ctCollection=optys.of_CT_at_enrollment__c>=1?'Yes':'No';
        string eachHTML=htmlBody;
        if( owea.size() > 0 ) {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        
        eachHTML = eachHTML.replace('{!currentDate}',todaysDate);
        eachHTML = eachHTML.replace('{!primaryOptyproviderName}',wrap.primaryProvider!=null?wrap.primaryProvider:'');
        eachHTML = eachHTML.replace('{!MotherName}',wrap.individualName!=null?wrap.individualName:'');
        eachHTML = eachHTML.replace('{!MotherDOB}',wrap.motherDOB!=null?wrap.motherDOB:'');
        eachHTML = eachHTML.replace('{!opportunityEnrollement}',enrollmentDate);
        eachHTML = eachHTML.replace('{!optyDueDate}',optyDueDate);
        eachHTML = eachHTML.replace('{!CBCollection}',cbCollection);
        eachHTML = eachHTML.replace('{!CTCollection}',ctCollection);
        system.debug('the html '+eachHTML);
        message.setSubject(subject);
        message.setHtmlBody(eachHTML);
        message.setWhatId(optys.Id); //This is important for the merge fields in template to work
        message.toAddresses = new String[] {'bavaldar@teksystems.com',wrap.emailAddress};//optyWrapperMap.get(eachopy.id).emailAddress
            
            return message;
    }
    public static List<Messaging.SingleEmailMessage> sendStoredFax(opportunity optys, emailWrapper wrap, Map<Id,List<Asset>> optyAsset){
        
        List<Messaging.SingleEmailMessage> storageMessage = new  List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'customercare@cordblood.com'];
        EmailTemplate storagetemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name='Send FAX Notification Storage'];
        if(!optyAsset.isEmpty()  && optyAsset.containsKey(optys.Id)){
            for(Asset eachAsset:optyAsset.get(optys.id)){
                system.debug('the inLoopAsset-->'+eachAsset);
                String subject = storagetemplate.Subject;
                String htmlBody = storagetemplate.HtmlValue;
                String todaysDate=system.today().format();
                DateTime storageDateTime=optys.Storage_Date__c!=null?optys.Storage_Date__c:null;
                string storageDate = storageDateTime!=null?date.newinstance(storageDateTime.year(), storageDateTime.month(), storageDateTime.day()).format():'No Collectcion Date';
                String optyDueDate=optys.Due_Date__c!=null?optys.Due_Date__c.format():' ';
                String cbCollection=optys.Stored_CB__c>=1?'Yes':'No';
                String ctCollection=optys.Stored_CT__c>=1?'Yes':'No';
                string volumeCollected=string.valueOf(eachAsset.BloodVolume__c!=null?eachAsset.BloodVolume__c:0.0);
                string totalCellCount=String.valueOf(eachAsset.TotalCellCount__c!=null?eachAsset.TotalCellCount__c:0.0);
                string storedHTML=htmlBody;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                storedHTML = storedHTML.replace('{!currentDate}',todaysDate);
                storedHTML = storedHTML.replace('{!MotherName}',wrap.individualName!=null?wrap.individualName:'');
                storedHTML = storedHTML.replace('{!StorageDate}',storageDate);
                storedHTML = storedHTML.replace('{!CordBloodCollection}',cbCollection);
                storedHTML = storedHTML.replace('{!CordTissueCollection} ',ctCollection);
                storedHTML = storedHTML.replace('{!Volumecollected}',volumeCollected);
                storedHTML = storedHTML.replace('{!Total cell count}',totalCellCount);
                system.debug('the html '+storedHTML);
                message.setSubject(subject);
                message.setHtmlBody(storedHTML);
                message.setWhatId(optys.Id); //This is important for the merge fields in template to work
                message.toAddresses = new String[] {'bavaldar@teksystems.com',wrap.emailAddress};//wrap.emailAddress
                storageMessage.add(message);
            }
        }
        system.debug('the storage msg-->'+storageMessage);
        return storageMessage;
    }
    public class emailWrapper{
        public string opportunityID;
        public string primaryProvider;
        public string individualName;
        public string motherDOB;
        public string emailAddress;
    }
}