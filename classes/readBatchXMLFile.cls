public class readBatchXMLFile {
    @future
    public static void readXmlFile(String fileId){
        Attachment responseXmlFile = [select Id,parentid,name,body from attachment where Id =:fileId limit 1];
        String xmlString = responseXmlFile.body.tostring();
        XmlStreamReader reader = new XmlStreamReader(xmlString);
        wrapperclass responseInfo = new wrapperclass();
        List<String> checkIdsList = new List<String>();
        //readBatchXMLFile.readXmlFile('00P54000003A2Li');
        //test record id 00P54000003A2Li
        while(reader.hasNext()){
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TranACK') {
                while(reader.hasNext()){
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()=='PmtID'){
                        reader.Next();
                        checkIdsList.add(reader.getText());
                        
                    }
                    if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'TranACK'){
                        break;
                    }
                    reader.next();
                }
            }
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'FileControl') {
                reader.Next();
                responseInfo.batchName=reader.getText();
            }
            
            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'FileAcceptTotal') {
                reader.Next();
                responseInfo.processedAmount=reader.getText();
            }
           
            reader.next();
        }
        responseInfo.checkIds= checkIdsList;
        system.debug('responseInfo---'+responseInfo);
        updatebatchChecksAndPayables(responseInfo);
    }
    public class wrapperclass{
        public String checksCount;
        public List<String> checkIds;
        public String batchName;
        public string processedAmount;
    }
    public static void updatebatchChecksAndPayables(wrapperclass responseInfo){
        list<CBRChecks__c> lstChecks = new list<CBRChecks__c>();
        list<Payable__c> lstPayable = new list<Payable__c>();
        HPNBatch__c batch = [select id,name,Status__c,Total_Paid__c,Paid_Date__c from HPNBatch__c where name=:responseInfo.batchName LIMIT 1];
        if(batch != Null){
            batch.Status__c ='Paid';
            batch.Paid_Date__c=system.today();
            if(responseInfo.checksCount !=null){
            batch.Number_of_Payments__c=integer.valueOf(responseInfo.checksCount);
                }
            batch.Total_Paid__c=decimal.valueOf(responseInfo.processedAmount);
            try{
                update batch; 
            }
            catch(exception ex){
                system.debug('HPNBatch Error--'+ ex.getMessage() + ':' + ex.getStackTraceString());
            } 
        }
           
        for(string recordId : responseInfo.checkIds){
            CBRChecks__c cbr = new CBRChecks__c(id=Id.valueof(recordId));
            cbr.Status__c='Paid';
            lstChecks.add(cbr);
        }
        
        if(!lstChecks.isEmpty()){
            database.update(lstChecks, false);
        }
        
        for(Payable__c payAbleRec: [select id,Status__c,CBRChecks__c,Transaction_Amount__c,CT_Supplemental_Amount__c,CT_Program_Amount__c,CB_Program_Amount__c,CB_Supplemental_Amount__c,Asset_Type_CB_CT__c from Payable__c where CBRChecks__c IN : responseInfo.checkIds and Status__c !='Void']){
            payAbleRec.Status__c = 'Paid';
            if(payAbleRec.Asset_Type_CB_CT__c == 'Cord Blood'){
                if(payAbleRec.CB_Supplemental_Amount__c> 0){
                    payAbleRec.Transaction_Amount__c = payAbleRec.CB_Supplemental_Amount__c;
                }else{
                    payAbleRec.Transaction_Amount__c = payAbleRec.CB_Program_Amount__c;
                }
            }else{
                if(payAbleRec.CT_Supplemental_Amount__c> 0){
                    payAbleRec.Transaction_Amount__c = payAbleRec.CT_Supplemental_Amount__c;
                }else{
                    payAbleRec.Transaction_Amount__c = payAbleRec.CT_Program_Amount__c;
                }
            }
            lstPayable.add(payAbleRec);
        }
        if(!lstPayable.isEmpty()){
            database.update(lstPayable, false);
        }
    }
}