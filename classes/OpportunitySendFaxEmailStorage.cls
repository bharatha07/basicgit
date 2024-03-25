/**********************************************************************************************************************************************
*Component Name: OpportunitySendFaxEmailStorage
*Created Date : 30th August 2021
*Description : This Class contains Future method fro sending emails for the opty sent from the OpportunitySendFaxEmail Apex class.
*Created By : Bharath Avaldar(TekSystems)
*Story Number: 1955,2088
**************************************************************************************************************************************************/

public class OpportunitySendFaxEmailStorage {   
    @future
    public static void sendOptyFAXEmails(string jsonString,List<Id> optyIDS){
        List<OpportunitySendFaxEmail.emailWrapper> emailWrapperList = new List<OpportunitySendFaxEmail.emailWrapper>((List<OpportunitySendFaxEmail.emailWrapper>)Json.deserialize(jsonString,List<OpportunitySendFaxEmail.emailWrapper>.class)); 
        system.debug('the email asset list--->'+emailWrapperList);
        Map<String,OpportunitySendFaxEmail.emailWrapper> optyWrapperMap= new  map<String,OpportunitySendFaxEmail.emailWrapper>();
        OrgWideEmailAddress[] owea;
        Map<String,EmailTemplate> listEmailTemplate= new Map<String,EmailTemplate>();
        Map<Id,Opportunity> enrolledOpty= new Map<Id,Opportunity>();
        Map<Id,List<Asset>> oppyAssertMap = new Map<Id,List<Asset>>();
        Map<Id,Opportunity> storedOpty= new Map<Id,Opportunity>();
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        List<Messaging.SingleEmailMessage> allMessage = new  List<Messaging.SingleEmailMessage>();
        //Logic to store wrapper class feilds with Opty IDs
        if(emailWrapperList!=null && !emailWrapperList.isEmpty()){
            Map<Id,opportunity> optyMap= new Map<Id,opportunity>();
            for(OpportunitySendFaxEmail.emailWrapper eachrec:emailWrapperList){
                optyWrapperMap.put(eachrec.opportunityID,eachrec);
            }
            system.debug('The each wrapper recrd-->'+optyWrapperMap);
            owea = [select Id from OrgWideEmailAddress where Address = 'customercare@cordblood.com'];
            
            //Logic to store template in map
            for(EmailTemplate template : [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name IN ('Send FAX Notification Enrollment','Send FAX Notification Storage')]){
                if(template.Description.Contains('Enrolled')){
                    listEmailTemplate.put('Enrolled',template);
                }
                else{
                    listEmailTemplate.put('Stored',template);
                }
            }
            //Logic to get opportunity and asset feilds required for email Templates
            optyMap= new Map<Id,opportunity>([select id,name,Status__c,Enrollment_Date__c,Storage_Date__c, Due_Date__c, of_CT_at_enrollment__c, of_CB_at_enrollment__c,Stored_CB__c,Stored_CT__c,(select id,name,Opportunity__c,BloodVolume__c,TotalCellCount__c from Assets__r where  Status ='Stored' and Opportunity__c!=null and Opportunity__r.Status__c='Stored' and Type__c ='Cord Blood')  from Opportunity where id IN:optyIDS]);
            if(optyMap!=null && !optyMap.isEmpty()){
                for(opportunity oppyRec:optyMap.values()){
                    oppyAssertMap.put(oppyRec.id,oppyRec.Assets__r);
                }
            }
            if(!optyMap.isEmpty()){
                for(opportunity eachopy:optyMap.values()){
                    if( eachopy.Status__c=='Enrolled'){
                        String subject = listEmailTemplate.get(eachopy.Status__c).Subject;
                        String htmlBody = listEmailTemplate.get(eachopy.Status__c).HtmlValue;
                        String todaysDate=system.today().format();
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        DateTime enrollmentDateTime=eachopy.Enrollment_Date__c!=null?eachopy.Enrollment_Date__c:null;
                        string enrollmentDate = date.newinstance(enrollmentDateTime.year(), enrollmentDateTime.month(), enrollmentDateTime.day()).format();
                        String optyDueDate=eachopy.Due_Date__c!=null?eachopy.Due_Date__c.format():' ';
                        String cbCollection=eachopy.of_CB_at_enrollment__c>=1?'Yes':'No';
                        String ctCollection=eachopy.of_CT_at_enrollment__c>=1?'Yes':'No';
                        string eachHTML=htmlBody;
                        //message.setReplyTo('no-reply@company.com');
                        if( owea.size() > 0 ) {
                            message.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        
                        eachHTML = eachHTML.replace('{!currentDate}',todaysDate);
                        eachHTML = eachHTML.replace('{!primaryOptyproviderName}',optyWrapperMap.get(eachopy.id).primaryProvider!=null?optyWrapperMap.get(eachopy.id).primaryProvider:'');
                        eachHTML = eachHTML.replace('{!MotherName}',optyWrapperMap.get(eachopy.id).individualName!=null?optyWrapperMap.get(eachopy.id).individualName:'');
                        eachHTML = eachHTML.replace('{!MotherDOB}',optyWrapperMap.get(eachopy.id).motherDOB!=null?optyWrapperMap.get(eachopy.id).motherDOB:'');
                        eachHTML = eachHTML.replace('{!opportunityEnrollement}',enrollmentDate);
                        eachHTML = eachHTML.replace('{!optyDueDate}',optyDueDate);
                        eachHTML = eachHTML.replace('{!CBCollection}',cbCollection);
                        eachHTML = eachHTML.replace('{!CTCollection}',ctCollection);
                        system.debug('the html '+eachHTML);
                        message.setSubject(subject);
                        message.setHtmlBody(eachHTML);
                        message.setWhatId(eachopy.Id); //This is important for the merge fields in template to work
                        message.toAddresses = new String[] {optyWrapperMap.get(eachopy.id).emailAddress};
                            allMessage.add(message);
                    }
                    else if(eachopy.Status__c=='Stored'){
                        if(!oppyAssertMap.isEmpty()  && oppyAssertMap.containsKey(eachopy.Id)){
                            List<Asset> assetList=oppyAssertMap.get(eachopy.id);
                            for(Asset eachAsset:assetList){
                                String subject = listEmailTemplate.get(eachopy.Status__c).Subject;
                                String htmlBody = listEmailTemplate.get(eachopy.Status__c).HtmlValue;
                                String todaysDate=system.today().format();
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                DateTime storageDateTime=eachopy.Storage_Date__c!=null?eachopy.Storage_Date__c:null;
                                string storageDate = storageDateTime!=null?date.newinstance(storageDateTime.year(), storageDateTime.month(), storageDateTime.day()).format():'No Collectcion Date';
                                String optyDueDate=eachopy.Due_Date__c!=null?eachopy.Due_Date__c.format():' ';
                                String cbCollection=eachopy.Stored_CB__c>=1?'Yes':'No';
                                String ctCollection=eachopy.Stored_CT__c>=1?'Yes':'No';
                                string volumeCollected=string.valueOf(eachAsset.BloodVolume__c!=null?eachAsset.BloodVolume__c:0.0);
                                string totalCellCount=String.valueOf(eachAsset.TotalCellCount__c!=null?eachAsset.TotalCellCount__c:0.0);
                                string storedHTML=htmlBody;
                                //message.setReplyTo('no-reply@company.com');
                                if( owea.size() > 0 ) {
                                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                storedHTML = storedHTML.replace('{!currentDate}',todaysDate);
                                storedHTML = storedHTML.replace('{!MotherName}',optyWrapperMap.get(eachopy.id).individualName!=null?optyWrapperMap.get(eachopy.id).individualName:'');
                                storedHTML = storedHTML.replace('{!StorageDate}',storageDate);
                                storedHTML = storedHTML.replace('{!CordBloodCollection}',cbCollection);
                                storedHTML = storedHTML.replace('{!CordTissueCollection} ',ctCollection);
                                storedHTML = storedHTML.replace('{!Volumecollected}',volumeCollected);
                                storedHTML = storedHTML.replace('{!Total cell count}',totalCellCount);
                                system.debug('the html '+storedHTML);
                                message.setSubject(subject);
                                message.setHtmlBody(storedHTML);
                                message.setWhatId(eachopy.Id); //This is important for the merge fields in template to work
                                message.toAddresses = new String[] {optyWrapperMap.get(eachopy.id).emailAddress};
                                    allMessage.add(message);
                            }
                        }
                        
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
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, ' Fax Email Notification for opportunity set to Enrolled/Stored', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
            }
            
            if(!cbrErrorLog.isEmpty()){
                Database.insert(cbrErrorLog, false);
            }
        }
        
    }       
}