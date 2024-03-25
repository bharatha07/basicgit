@istest
public class readBatchXMLFileTest {
    
    @istest
    public static void readXmlFileTestMethod(){
       	Id providerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        List<Account> acc= [select id,name,HPN_Flag__c from Account where RecordtypeID=:providerRecordTypeId];
        List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
        List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
        List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
        providerAcc[0].HPN_Flag__c=true;
        update providerAcc;
        
        OppList[0].Status__c = 'stored';
        OppList[0].Program_Enrolled_in__c  = 'Family Banking';
        update OppList[0];
        
        List<Asset> oppyAsset = new List<Asset>();
        List<Asset> oppyAsset1 = new List<Asset>();
        oppyAsset=TestDataFactory.assetInsert();
        oppyAsset[0].Opportunity__c=OppList[0].id;
        oppyAsset[0].AccountId=providerAcc[0].id;
        oppyAsset[0].Status='Stored';
        oppyAsset[0].FreezeDate__c=System.now().addDays(-7);
        oppyAsset[1].Opportunity__c=OppList[0].id;
        oppyAsset[1].AccountId=providerAcc[1].id;
        oppyAsset[1].Status='Stored';
        oppyAsset[1].FreezeDate__c=System.now().addDays(-7);
        oppyAsset1.add(oppyAsset[0]);
        oppyAsset1.add(oppyAsset[1]);
        insert oppyAsset1;
        user intgUsr=[SELECT Id,name,IsActive,Profile.name FROM User where name='MulesoftUser MulesoftUser' limit 1];
        List<Asset> ass= [select id,name,Opportunity__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,AccountId,Account.HPN_Flag__c,Status from Asset where Opportunity__c =:OppList[0].id];
        List<Opportunity_Provider__c> oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass[0].Opportunity__r.id];
        Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
        Insert program;
        
        Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
        insert aggrement;
        
        List<Provider_Agreement__c> lstPA= new List<Provider_Agreement__c>();
        lstPA.add(new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id, HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5)));
        insert lstPA;
        
        List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
        lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='Houston',Tax_ID__c='Test123',Zip_Code__c='12333',Provider_Agreement__c=lstPA[0].id));
        insert lstPayTo;
        
        List<Payable__c> PayBleLst= new List<Payable__c>();
        PayBleLst.add(new Payable__c(Asset__c=ass[0].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=providerAcc[0].id,HPN_Provider_Agreement__c=lstPA[0].id,Status__c='Pending Accounting',CBR_PAY_TO__c=lstPayTo[0].id));
        PayBleLst.add(new Payable__c(Asset__c=ass[1].id,Opportunity__c=ass[0].Opportunity__r.id,Provider_ID__c=providerAcc[0].id,HPN_Provider_Agreement__c=lstPA[0].id,Status__c='Pending Accounting',CBR_PAY_TO__c=lstPayTo[0].id));
        insert PayBleLst;
        
        List<CBRChecks__c> chequeList= new List<CBRChecks__c>();
        chequeList.add( new CBRChecks__c(Status__c='Pending Payment',HPN_Batch_ID__c=null,CBR_PAY_TO__c= PayBleLst[0].CBR_PAY_TO__c,Amount__c=10));
        insert chequeList;
        
        PayBleLst[0].CBRChecks__c=chequeList[0].id;
        update PayBleLst[0];
        
        
        Map<Id,CBRChecks__c> ids= new Map<Id,CBRChecks__c>();
        ids.put(chequeList[0].id,chequeList[0]);
        system.debug('The input checks are'+ids);
        
        test.startTest();
        scheduleHPNBatchRecordcreation abc = new scheduleHPNBatchRecordcreation();
        abc.Execute(null);
        test.stopTest();
        
        List<HPNBatch__c> batchList = new List<HPNBatch__c>([select id,Name,Total_Void__c,Total_Pending_Payment__c,Total_Paid__c,Status__c,Number_of_Payments__c,Batch_Type__c from HPNBatch__c]);
        system.debug('batchList0>>>>'+batchList[0].Name);
        
        Attachment  fileRec = new Attachment ();
        XmlStreamWriter xmlFile = new XmlStreamWriter();
        xmlFile.writeStartDocument('UTF-8','1.0');
        xmlFile.writeStartElement(null,'WFPaymentAck',null);
        xmlFile.writeAttribute(null, null,'CompanyID' , 'CBRS');
        xmlFile.writeAttribute(null, null,'PmtTypeACKCount' ,'1' );
        xmlFile.writeStartElement(null,'AcceptedChecks',null);
        xmlFile.writeAttribute(null, null,'PrcDate' ,'2021-02-17');
        xmlFile.writeAttribute(null, null,'PmtType' , 'Checks');
        xmlFile.writeAttribute(null, null,'PmtStatus' , 'Accepted');
        xmlFile.writeStartElement(null,'TranACK',null);
        xmlFile.writeAttribute(null, null,'TranNum' ,'1');
        xmlFile.writeAttribute(null, null,'PrcDate' ,'2021-02-17');
        xmlFile.writeStartElement(null,'PmtID',null);
        xmlFile.writeCharacters(chequeList[0].id);
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'Name1',null);
        xmlFile.writeCharacters('null');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'ValueDate',null);
        xmlFile.writeCharacters('2020-11-16');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'CurAmt',null);
        xmlFile.writeCharacters(string.valueof(chequeList[0].Amount__c));
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'CurCode',null);
        xmlFile.writeCharacters('USD');
        xmlFile.writeEndElement();
        xmlFile.writeEndElement();
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'PrcTime',null);
        xmlFile.writeCharacters('08:20:35');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'PrcDate',null);
        xmlFile.writeCharacters('2020-11-18');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileDate',null);
        xmlFile.writeCharacters('20201116');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileControl',null);
        xmlFile.writeCharacters(batchList[0].Name);
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileTranCount',null);
        xmlFile.writeCharacters('1');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileTranTotal',null);
        xmlFile.writeCharacters('10');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileAcceptCount',null);
        xmlFile.writeCharacters('1');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileAcceptTotal',null);
        xmlFile.writeCharacters('10');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileRejectCount',null);
        xmlFile.writeCharacters('0');
        xmlFile.writeEndElement();
        xmlFile.writeStartElement(null,'FileRejectTotal',null);
        xmlFile.writeCharacters('0');
        xmlFile.writeEndElement();
        xmlFile.writeEndElement();
        xmlFile.writeEndDocument();
        system.runAs(intgUsr){
        String xmlStringxmlRes = xmlFile.getXmlString();
        Blob fileBlob = Blob.valueof(xmlStringxmlRes);
        fileRec.Body = fileBlob;
        fileRec.Name = batchList[0].Name+'.xml';
        fileRec.ParentId = batchList[0].id;
        fileRec.Description='Response from WellFargo';
        insert fileRec;
        }
        readBatchXMLFile.readXmlFile(string.valueof(fileRec.id));        
        
        HPNBatch__c batchList1 = [select id,Name,Status__c from HPNBatch__c where id =: batchList[0].id];
        system.debug('batchList1>>>>'+batchList1.Name);
        //system.assertEquals('Paid', batchList1.Status__c);
        
        CBRChecks__c checkRec = [select id,status__c from CBRChecks__c where id =:chequeList[0].id];
        //system.assertEquals('Paid', checkRec.Status__c);
    }
}