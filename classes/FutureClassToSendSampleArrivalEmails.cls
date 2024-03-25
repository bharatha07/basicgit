public class FutureClassToSendSampleArrivalEmails {
    @future
    public static void sendSampleArrivalEmails(string jsonString){
        List<Asset> emailAsset = new List<Asset>((List<Asset>)Json.deserialize(jsonString,List<Asset>.class)); 
        system.debug('the email asset list--->'+emailAsset);
        EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name='Sample Arrival'];
        system.debug('the email template'+template);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'customercare@cordblood.com'];
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        String subject = template.Subject;
        String htmlBody = template.HtmlValue;
        List<Messaging.SingleEmailMessage> allMessage = new  List<Messaging.SingleEmailMessage>();
        if(!emailAsset.isEmpty()){
            for(Asset ast:emailAsset){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                //message.setTargetObjectId(ast.id); 
                //message.setSenderDisplayName('CBR Team'); 
                message.setReplyTo('no-reply@company.com');
                if( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                //message.setUseSignature(false); 
                //message.setBccSender(false); 
                //message.setSaveAsActivity(false); 
                //message.setTemplateID(template.Id); 
                htmlBody = htmlBody.replace('{!Asset.Opportunity_PrimaryContact_FirstName__c}',ast.Opportunity_PrimaryContact_FirstName__c);
                system.debug('the html '+htmlBody);
                message.setSubject(subject);
                message.setHtmlBody(htmlBody);
                message.setWhatId(ast.Id); //This is important for the merge fields in template to work
                message.toAddresses = new String[] {string.valueof(ast.Primary_Contact_Email__c)};
                    allMessage.add(message);
            }
            
            try{    
                List<Messaging.SendEmailResult> result = Messaging.sendEmail(allMessage);
            }
            catch(System.EmailException ex){
                string ErrDetail;
                ErrDetail = ex.getMessage();
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Email Notification for Sample Arrival at Lab', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);
            }
            
            if(!cbrErrorLog.isEmpty()){
                Database.insert(cbrErrorLog, false);
            }
        }
    }
    
}