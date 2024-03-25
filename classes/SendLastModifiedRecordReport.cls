/******************************************************************************************************************************
*Component Name: SendLastModifiedRecordReport
*Created Date : 07-DEC-2020
* @story - SFDC-1342
*Description : To send the count of records modified today on daily basis.
*Created By : 
*******************************************************************************************************************************/
global class SendLastModifiedRecordReport implements Schedulable {    
    global void execute(SchedulableContext sc) {
        //List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        try{          
            list<string> allemailbody= new list<string>{'Hello, <br/><br/> Please find the below record count modified today.<br/>'};
                
            List_Of_Objects__c objectList = List_Of_Objects__c.getInstance('Object List');
            String fieldName = objectList.Objects__c;
            String[] sobjects = fieldName.split(',');
            Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(sobjects);
            for (Schema.DescribeSObjectResult eachObject:descResult){
                string objectname=eachObject.getName();
                String query = 'select count() from '+objectname+' where lastmodifieddate=yesterday LIMIT 49999';
                integer count=Database.countQuery(query);
                string emailbody = objectname+' records: '+count+'';
                allemailbody.add(emailbody);
            }
            allemailbody.add('Thank You.<br/>Admin');
            String body=string.join(allemailbody,'<br/><br/>');
                      
            
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();    
            Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
            email.setHtmlBody(body);
            User_Email_Details__c userEmail = User_Email_Details__c.getInstance('Email Address');
            String EmailAddress = userEmail.Emails__c;
            String[] toAddresses = EmailAddress.split(',');
            email.setToAddresses(toAddresses);
            email.setSenderDisplayName('Salesforce');
            email.setSubject('Records Modified Today');
            lstMsgs.add(email);
            
            
            if(!lstMsgs.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMsgs);
            }        
            
            
            
        } catch(Exception ex){
            string emailErrorMessage=ex.getStackTraceString()+ex.getMessage(); 
            system.debug('emailErrorMessage>>>>'+emailErrorMessage);
            //cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Record Modified Everyday', 'Apex', emailErrorMessage, false, false);
            //cbrErrorLog.add(cbr);
            //database.insert(cbrErrorLog,false);
        }
    }
}