/*************************************************************************************************
* @description This Batch job is to create check records group by PAY TO.
* @param - 
* @story - SFDC-1485
* @Author -Teksystems
* @date - 08-FEB-2021 (Teksystems)
*/
public class BatchToCreateCheckRecords implements Database.Batchable<sObject>,Database.Stateful{
    
    public map<id,CBRChecks__c> cbrCheckMap  = new map<id,CBRChecks__c>();
    Boolean chain2ndbatch=true;
    public dateTime assetFreezTime = System.now().addDays(-7);
    string payableID= system.label.Payable_ID;
    
    List<String> paybleIds = system.label.payable_id.split(',');
    //string finalpayableID=String.escapeSingleQuotes(payableID);
    date createdfrom=date.valueOf(system.label.CreatedDateFrom);  
    date CreatedTo=date.valueOf(system.label.CreateddateTO);
    date AssetFreeze=date.valueOf(system.label.AssetFreezeDate);
    string query='';
    public Database.QueryLocator Start(Database.BatchableContext bc){
        system.debug('The is-->'+paybleIds);
        if(Test.isRunningTest()){
            query=query+'select id,CB_Program_Amount__c,CT_Program_Amount__c,CB_Supplemental_Amount__c,CT_Supplemental_Amount__c,CBR_PAY_TO__c,Asset_Type_CB_CT__c,Status__c,CreatedDate from Payable__c where  Status__c=\'Pending Accounting\' AND CBRChecks__c = Null AND CreatedDate =Last_N_days:14 AND Asset__r.FreezeDate__c <=:assetFreezTime';
        }
        else if((paybleIds!=null || !paybleIds.isEmpty()) && paybleIds[0]!='null'){
            query='select id,Name, CB_Program_Amount__c,CreatedBy.name,Asset__r.Freeze_Date__c,Asset__r.SerialNumber, Opportunity__c, CT_Program_Amount__c,CB_Supplemental_Amount__c,CT_Supplemental_Amount__c,CBR_PAY_TO__c,Asset_Type_CB_CT__c,Status__c,CreatedDate from Payable__c where  (Status__c=\'Pending Accounting\' AND CBRChecks__c =Null AND CreatedDate<=:CreatedTo and Asset__r.Freeze_Date__c<:AssetFreeze) or ((id In:paybleIds) and Status__c=\'Pending Accounting\' AND CBRChecks__c = Null)';
            system.debug('the query'+query);
        }
        
        else{
            query='select id,Name, CB_Program_Amount__c,CreatedBy.name,Asset__r.Freeze_Date__c,Asset__r.SerialNumber, Opportunity__c, CT_Program_Amount__c,CB_Supplemental_Amount__c,CT_Supplemental_Amount__c,CBR_PAY_TO__c,Asset_Type_CB_CT__c,Status__c,CreatedDate from Payable__c where  Status__c=\'Pending Accounting\' AND CBRChecks__c =Null AND  CreatedDate<=:CreatedTo and Asset__r.Freeze_Date__c<:AssetFreeze';
        }
        return Database.getQueryLocator(query);
        
    }    
    public void Execute(Database.BatchableContext bc, list<Payable__c> paybleLst){
        system.debug('The payablist-->'+paybleLst);
        set<id> checkIds = new set<id>();
        string ErrDetail;
        List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
        for(Payable__c payble : paybleLst){
            if(cbrCheckMap.containsKey(payble.CBR_PAY_TO__c)){
                
                CBRChecks__c cheque = cbrCheckMap.get(payble.CBR_PAY_TO__c);
                if(payble.Asset_Type_CB_CT__c =='Cord Blood'){
                    cheque.Amount__c += payble.CB_Supplemental_Amount__c > 0 ? payble.CB_Supplemental_Amount__c : payble.CB_Program_Amount__c;
                    system.debug('CBAmount>>>>'+cheque.Amount__c);
                }
                else if(payble.Asset_Type_CB_CT__c =='Cord Tissue'){
                    cheque.Amount__c +=  payble.CT_Supplemental_Amount__c > 0 ? payble.CT_Supplemental_Amount__c : payble.CT_Program_Amount__c;
                    system.debug('CTAmount>>>>'+cheque.Amount__c);
                }
                cbrCheckMap.put(payble.CBR_PAY_TO__c,cheque);
            }
            else if(payble.CBR_PAY_TO__c != Null){
                CBRChecks__c cbrChecks = new CBRChecks__c();
                cbrChecks.CBR_PAY_TO__c =payble.CBR_PAY_TO__c;
                cbrChecks.Check_Type__c = 'HPN';
                cbrChecks.Payment_Date__c = system.today();
                cbrChecks.Status__c = 'Pending Payment';
                if(payble.Asset_Type_CB_CT__c  == 'Cord Blood'){
                    cbrChecks.Amount__c = payble.CB_Supplemental_Amount__c > 0 ? payble.CB_Supplemental_Amount__c : payble.CB_Program_Amount__c;
                    system.debug('CBAmount<<<>>>>'+cbrChecks.Amount__c);
                }
                else if(payble.Asset_Type_CB_CT__c  == 'Cord Tissue'){
                    cbrChecks.Amount__c = payble.CT_Supplemental_Amount__c > 0 ? payble.CT_Supplemental_Amount__c : payble.CT_Program_Amount__c;
                    system.debug('CTAmount<<<>>>>'+cbrChecks.Amount__c);
                }
                cbrCheckMap.put(payble.CBR_PAY_TO__c,cbrChecks); 
            }
        }
        if(!cbrCheckMap.isEmpty()){
            for (Database.upsertResult upsertResult : database.upsert(cbrCheckMap.values(),false)) {
                if(upsertResult.issuccess()){
                    checkIds.add(upsertResult.id);
                }
                else{
                    for (Database.Error e : upsertResult.getErrors()) {
                        ErrDetail+=e.getMessage()+e.getStatusCode();
                        system.debug('error..................'+e.getMessage());
                    }
                }
            }
        }
        map<id,CBRChecks__c> mapCheque = new map<id,CBRChecks__c>();
        system.debug('cbrCheckMap>>>>'+cbrCheckMap);
        for(CBRChecks__c cbrCheque : [select id,CBR_PAY_TO__c from CBRChecks__c where id IN : checkIds]){
            mapCheque.put(cbrCheque.CBR_PAY_TO__c , cbrCheque);
        }
        if(!mapCheque.isEmpty()){
            for(Payable__c pay : paybleLst){
                if(mapCheque.containskey(pay.CBR_PAY_TO__c)){
                    CBRChecks__c updateCheque = mapCheque.get(pay.CBR_PAY_TO__c);
                    pay.CBRChecks__c = updateCheque.id;
                }
                
            }
        }
        for (Database.saveResult paybleupdate : database.update(paybleLst,false)) {
            if(!paybleupdate.issuccess()){
                for (Database.Error e : paybleupdate.getErrors()) {
                    ErrDetail+=e.getMessage()+e.getStatusCode();
                    system.debug('error..................'+e.getMessage());
                }
            }
            
        }
        cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'CheckrecordsCreation', 'Apex', ErrDetail, false, false);
        cbrErrorLog.add(cbr);
        if(!cbrErrorLog.isEmpty()){
            Database.insert(cbrErrorLog, false);  
        }
    }
    public void Finish(Database.BatchableContext bc){
        
        if(chain2ndbatch){
            Map<Id,CBRChecks__c> ids= new Map<Id,CBRChecks__c>();
            BatchToCreateHPNBatchRecords hPNbatch = new BatchToCreateHPNBatchRecords(ids,0);
            database.executeBatch(hPNbatch);
        }else{
            System.debug('2nd Batch could not start , check for 1st batch to start ');
        }
        
        
        
    }
}