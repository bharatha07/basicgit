global class batchXmlGenerator implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
         
       //return Database.getQueryLocator('select id from HPNBatch__c where createddate = today AND Status__c = \'Pending Payment\'');
       //Story SFDC-1699 : Changed return query.
       return Database.getQueryLocator('select id from HPNBatch__c where createddate = today AND Status__c = \'Pending Payment\' order by CreatedDate desc Limit 1');
    }
    public void execute(Database.BatchableContext bc, List<HPNBatch__c> records){
        xmlGenerator(records[0].id);
    }
    public void finish(Database.BatchableContext bc){
       
    }
    public static void xmlGenerator(string batchId){
        Map<Id,HPNBatch__c> batchList = new Map<Id,HPNBatch__c>();
        Map<Id,List<CBRChecks__c>> cbrChecksMap = new Map<Id,LIst<CBRChecks__c>>();
        Map<Id,List<Payable__c>> checkPayables = new Map<Id,List<Payable__c>>();
        Map<Id,Payable__c> payables = new Map<Id,Payable__c>();
        if(String.isNotBlank(batchId)){
            batchList = new Map<Id,HPNBatch__c>([select id,Name,Total_Void__c,Total_Pending_Payment__c,Total_Paid__c,Status__c,Number_of_Payments__c,Batch_Type__c,(select id,CheckNumber__c,Check_Number__c,Amount__c,CBR_PAY_TO__c,Check__c,Check_Type__c,Batch_ID__c,Status__c,CBR_PAY_TO__r.Name,CBR_PAY_TO__r.Address__c,CBR_PAY_TO__r.Address_2__c,CBR_PAY_TO__r.City__c,CBR_PAY_TO__r.Country__c,CBR_PAY_TO__r.State__c,CBR_PAY_TO__r.Zip_Code__c from CBRChecks__r) from HPNBatch__c where id =:batchId]);
            payables = new Map<Id,Payable__c>([select id,name,Asset_Blood_Volume__c,Account_ID_Mother__c,Provider_ID__r.name,Provider_ID__c,Account_ID_Mother__r.name,opportunity__r.Account.Name,Asset_Type_CB_CT__c,CB_Program_Amount__c,CT_Program_Amount__c,CB_Supplemental_Amount__c,CT_Supplemental_Amount__c,CBR_PAY_TO__c,CBR_PAY_TO__r.name,CBRChecks__c,Check_Amount__c,Check_Payment_Date__c,Provider_Name__c,Provider_ID__r.SCSS_Provider_Id__c,Asset_Account_Birthdatetime__c from Payable__c where Batch_ID__c =:batchId ]);
        }
        if(batchList!=null && !batchList.isEmpty()){
            for(HPNBatch__c batchRec:batchList.values()){
                cbrChecksMap.put(batchRec.id,batchRec.cbrchecks__r);
            }
        }
        if(payables!=null && !payables.isEmpty()){
            for(Payable__c pay:payables.values()){
                if(checkPayables!=null && checkPayables.containskey(pay.CBRChecks__c)){
                    List<Payable__c> tempList = checkPayables.get(pay.CBRChecks__c);
                    tempList.add(pay);
                    checkPayables.put(pay.CBRChecks__c,tempList);
                }
                else{
                    checkPayables.put(pay.CBRChecks__c,new List<Payable__c>{pay});
                }
            }
        }
         Attachment  fileRec = new Attachment ();
        XmlStreamWriter xmlFile = new XmlStreamWriter();
        if(batchList!=null && !batchList.isEmpty()){
            for(HPNBatch__c batchRec:batchList.values()){
                xmlFile.writeStartDocument('UTF-8','1.0');//Start of Doc
                xmlFile.writeStartElement(null,'File',null);//Start of file Tag
                //if(batchRec.Number_of_Payments__c!=null){
                if(cbrChecksMap.get(batchRec.id).size()>0){
                xmlFile.writeAttribute(null, null,'PmtRecCount' , String.valueof(cbrChecksMap.get(batchRec.id).size()));}
                xmlFile.writeAttribute(null, null,'ValidFlag' ,'true' );
                if(batchRec.Total_Pending_Payment__c!=null){
                xmlFile.writeAttribute(null, null,'PmtRecTotal' ,String.valueof(batchRec.Total_Pending_Payment__c) );}
                //PmtRecs Start
                if(cbrChecksMap.get(batchRec.id)!=null){
                    for(CBRChecks__c check:cbrChecksMap.get(batchRec.id)){
                        xmlFile.writeStartElement(null,'PmtRec',null);//Start of PmtRec
                        xmlFile.writeAttribute(null, null, 'PmtCrDr','C' );
                         xmlFile.writeAttribute(null, null, 'PmtMethod', 'CHK');
                         xmlFile.writeAttribute(null, null, 'DeliveryMethod','000' );
                         xmlFile.writeAttribute(null, null, 'ValidFlag', 'true');
                        xmlFile.writeStartElement(null,'Check',null);//Start of check tag
                        xmlFile.writeStartElement(null,'ChkNum',null);//Start of ChkNum tag
                        if(check.CheckNumber__c!=null){
                            xmlFile.writeCharacters(String.valueOf(check.CheckNumber__c));
                        }
                         xmlFile.writeEndElement();//End ChkNum tag
                        xmlFile.writeStartElement(null,'ChkDocNum',null);//Start of ChkNum tag
                        xmlFile.writeCharacters(Label.CbrCheckDocNum);
                         xmlFile.writeEndElement();//End ChkNum tag
                        xmlFile.writeEndElement();//End check tag
                        xmlFile.writeStartElement(null, 'OrgnrParty', null);//Start of OrgnrParty
                        xmlFile.writeStartElement(null, 'Name', null);//Start of Name
                        xmlFile.writeStartElement(null, 'Name1', null);//Start of Name1
                        xmlFile.writeCharacters(Label.CBRName);
                        xmlFile.writeEndElement();//End of Name1
                        xmlFile.writeEndElement();//End of Name
                        xmlFile.writeStartElement(null, 'PostAddr', null);//Start of PostAddr
                        
                        xmlFile.writeStartElement(null, 'Addr1', null);//Start of Addr1
                        xmlFile.writeCharacters(Label.CbrAddress1);
                        xmlFile.writeEndElement();//End of Addr1
                        
                        xmlFile.writeStartElement(null, 'Addr2', null);//Start of Addr2
                        xmlFile.writeCharacters(Label.CbrAddress2);
                        xmlFile.writeEndElement();//End of Addr2
                        
                        xmlFile.writeStartElement(null, 'City', null);//Start of City
                        xmlFile.writeCharacters(Label.CbrCity);
                        xmlFile.writeEndElement();//End of City
                        
                        xmlFile.writeStartElement(null, 'StateProv', null);//Start of StateProv
                        xmlFile.writeCharacters(Label.CbrStateProv);
                        xmlFile.writeEndElement();//End of StateProv
                        
                        xmlFile.writeStartElement(null, 'PostalCode', null);//Start of PostalCode
                        xmlFile.writeCharacters(Label.CbrPostalCode);
                        xmlFile.writeEndElement();//End of PostalCode
                        
                        xmlFile.writeStartElement(null, 'Country', null);//Start of Country
                        xmlFile.writeCharacters(Label.CbrCountry);
                        xmlFile.writeEndElement();//End of Country
                        
                        xmlFile.writeStartElement(null, 'CountryName', null);//Start of CountryName
                        xmlFile.writeCharacters(Label.CbrCountryName);
                        xmlFile.writeEndElement();//End of CountryName
                        
                        xmlFile.writeEndElement();//End of PostAddr
                        xmlFile.writeEndElement();//End of OrgnrParty
                        
                        xmlFile.writeStartElement(null, 'RcvrParty', null);//Start of RcvrParty
                        
                        xmlFile.writeStartElement(null, 'Name', null);//Start of Name
                        xmlFile.writeStartElement(null, 'Name1', null);//Start of Name1
                        if(check.CBR_PAY_TO__r.Name!=null){
                            xmlFile.writeCharacters(check.CBR_PAY_TO__r.Name);}
                        xmlFile.writeEndElement();//End of Name1
                        xmlFile.writeEndElement();//End of Name
                        
                        xmlFile.writeStartElement(null, 'PostAddr', null);//Start of PostAddr
                        
                        xmlFile.writeStartElement(null, 'Addr1', null);//Start of Addr1
                        if(check.CBR_PAY_TO__r.Address__c!=null){
                            xmlFile.writeCharacters(check.CBR_PAY_TO__r.Address__c);}
                        xmlFile.writeEndElement();//End of Addr1
                        
                        xmlFile.writeStartElement(null, 'Addr2', null);//Start of Addr2
                        if(String.isnotblank(check.CBR_PAY_TO__r.Address_2__c))
                        xmlFile.writeCharacters(check.CBR_PAY_TO__r.Address_2__c);
                        xmlFile.writeEndElement();//End of Addr2
                        
                        xmlFile.writeStartElement(null, 'City', null);//Start of City
                        if(String.isNotBlank(check.CBR_PAY_TO__r.City__c)){
                            xmlFile.writeCharacters(check.CBR_PAY_TO__r.City__c);}
                        xmlFile.writeEndElement();//End of City
                        
                        xmlFile.writeStartElement(null, 'StateProv', null);//Start of StateProv
                        if(String.isNotBlank(check.CBR_PAY_TO__r.State__c)){
                            xmlFile.writeCharacters(check.CBR_PAY_TO__r.State__c);}
                        xmlFile.writeEndElement();//End of StateProv
                        
                        xmlFile.writeStartElement(null, 'PostalCode', null);//Start of PostalCode
                        if(String.isNotblank(check.CBR_PAY_TO__r.Zip_Code__c)){
                            xmlFile.writeCharacters(check.CBR_PAY_TO__r.Zip_Code__c);}
                        xmlFile.writeEndElement();//End of PostalCode
                        
                        xmlFile.writeStartElement(null, 'Country', null);//Start of Country
                        xmlFile.writeCharacters('US');
                        xmlFile.writeEndElement();//End of Country
                        
                        xmlFile.writeStartElement(null, 'CountryName', null);//Start of CountryName
                        if(String.isNotBlank(check.CBR_PAY_TO__r.Country__c)){
                        xmlFile.writeCharacters(check.CBR_PAY_TO__r.Country__c);}
                        xmlFile.writeEndElement();//End of CountryName
                        
                        xmlFile.writeEndElement();//End of PostAddr
                        
                         xmlFile.writeEndElement();//End of RcvrParty
                        
                         xmlFile.writeStartElement(null, 'OrgnrDepAcctID', null);//Start of OrgnrDepAcctID
                        
                         xmlFile.writeStartElement(null, 'DepAcctID', null);//Start of DepAcctID
                        xmlFile.writeAttribute(null, null, 'AcctType','D' );
                        xmlFile.writeAttribute(null, null, 'AcctID', label.WFAccId);
                         xmlFile.writeStartElement(null, 'BankInfo', null);//Start of BankInfo
                        xmlFile.writeAttribute(null, null, 'BankIDType',label.WFBankIDType );
                        xmlFile.writeAttribute(null, null, 'BranchName', 'WELLS FARGO');
                        xmlFile.writeStartElement(null, 'BankID', null);//Start of BankID
                        xmlFile.writeCharacters(label.WFBankID);
                         xmlFile.writeEndElement();//End of BankID
                        
                        xmlFile.writeEndElement();//End of BankInfo
                        xmlFile.writeEndElement();//End of DepAcctID
                         xmlFile.writeEndElement();//End of OrgnrDepAcctID
                        
                        xmlFile.writeStartElement(null, 'PmtDetail', null);//Start of PmtDetail
                        if(checkPayables!=null && checkPayables.containskey(check.id) && checkPayables.get(check.id)!=null){
                            for(Payable__c pay:checkPayables.get(check.id)){
                                xmlFile.writeStartElement(null, 'InvoiceInfo', null);//Start of InvoiceInfo
                                if(pay.Asset_Blood_Volume__c!=null){
                                     xmlFile.writeAttribute(null, null, 'InvoiceNum',String.valueOf(pay.Asset_Blood_Volume__c) );
                                }
                                else{
                                     xmlFile.writeAttribute(null, null, 'InvoiceNum',null );
                                }
                                if(pay.Asset_Type_CB_CT__c=='Cord Blood'){
                                xmlFile.writeAttribute(null, null, 'TotalCurAmt', String.valueof(pay.CB_Supplemental_Amount__c > 0 ? pay.CB_Supplemental_Amount__c : pay.CB_Program_Amount__c));//Set the amount of each asset CB Supplement/program Amount
                                }
                                else{
                                  xmlFile.writeAttribute(null, null, 'TotalCurAmt', String.valueof(pay.CT_Supplemental_Amount__c > 0 ? pay.CT_Supplemental_Amount__c :pay.CT_Program_Amount__c));//Set the amount of each asset CT Supplement/program Amount   
                                }
                                xmlFile.writeAttribute(null, null, 'InvoiceType','IV' );
                                if(pay.Asset_Account_Birthdatetime__c!=null){
                                    xmlFile.writeAttribute(null, null, 'EffDt',pay.Asset_Account_Birthdatetime__c.format('yyyy-MM-dd'));}
                                
                                xmlFile.writeStartElement(null, 'Note', null);//Start of Note
                                xmlFile.writeAttribute(null, null, 'NoteType', 'PAT');
                                 xmlFile.writeStartElement(null, 'NoteText', null);//Start of NoteText
                                if(String.isNotBlank(pay.Account_ID_Mother__c)){
                                    xmlFile.writeCharacters(pay.Account_ID_Mother__r.name);}
                                
                                xmlFile.writeEndElement();//End of NoteText
                                xmlFile.writeEndElement();//End of Note
                                
                                xmlFile.writeStartElement(null, 'POInfo', null);//Start of POInfo   
                                xmlFile.writeAttribute(null,null,'POType','PRO');
                                
                                 xmlFile.writeStartElement(null, 'PONum', null);//Start of PONum
                                if(String.isNotBlank(pay.Provider_ID__r.SCSS_Provider_Id__c)){
                                    xmlFile.writeCharacters(pay.Provider_ID__r.SCSS_Provider_Id__c);}
                                xmlFile.writeEndElement();//End of PONum
                                
                                xmlFile.writeStartElement(null, 'Desc', null);//Start of Desc
                                if(String.isnotblank(pay.Provider_ID__c)){
                                     xmlFile.writeCharacters(pay.Provider_ID__r.name);//pay.Provider_Name__c
                                }
 
                                xmlFile.writeEndElement();//End of Desc
                                
                                xmlFile.writeEndElement();//End of POInfo
                                xmlFile.writeEndElement();//End of InvoiceInfo
                            }
                        }
                        
                        xmlFile.writeEndElement();//End of PmtDetail
                        
                        xmlFile.writeStartElement(null, 'PmtID', null);//Start of PmtID
                        xmlFile.writeCharacters(check.id);
                        xmlFile.writeEndElement();//End of PmtID
                        
                        xmlFile.writeStartElement(null, 'CurAmt', null);//Start of CurAmt
                        xmlFile.writeCharacters(String.valueOf(check.Amount__c));
                        xmlFile.writeEndElement();//End of CurAmt
                        
                        xmlFile.writeStartElement(null, 'CurCode', null);//Start of CurCode
                        xmlFile.writeCharacters('USD');
                         xmlFile.writeEndElement();//End of CurCode
                        
                        xmlFile.writeStartElement(null, 'ValueDate', null);//Start of ValueDate
                       xmlFile.writeCharacters(String.valueOf(system.today()));
                        xmlFile.writeEndElement();//End of ValueDate
                        xmlFile.writeEndElement();//End of PmtRec
                    }
                }
                //PmtRecs End
                xmlFile.writeStartElement(null,'FileInfoGrp',null);//FileInfoGrp Start
                xmlFile.writeAttribute(null, null,'FileDate' , String.valueof(system.today().year())+String.valueof(system.today().month())+String.valueof(system.today().day()));
                xmlFile.writeAttribute(null, null,'FileControlNumber' , batchRec.Name);
                 xmlFile.writeEndElement();//End of FileInfoGrp Tag
                xmlFile.writeEndElement();//End of file Tag
                xmlFile.writeEndDocument();//ending xml document
                String xmlStringxmlRes = xmlFile.getXmlString();
                 Blob fileBlob = Blob.valueof(xmlStringxmlRes);
                fileRec.Body = fileBlob;
                //fileRec.Name = batchRec.Name+'.xml';
                //Story SFDC-1699 : Changed name format for XML file
                DateTime dt = DateTime.now();
                String TimeStr = dt.format('hhmmss');
                String dateStr = dt.format('yyMMdd');
                fileRec.Name = 'cbrs.'+TimeStr+'0000'+dateStr+'.xml';
                fileRec.ParentId = batchRec.id;
                fileRec.Description = 'Send Request to WellsFargo ' +batchRec.Name;
               
                system.debug('xmlStringxmlRes--'+xmlStringxmlRes);
               
                
            }
            insert fileRec;
             xmlFile.close();
        }
        
    }//end of method
}