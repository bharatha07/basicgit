/**
* @File Name          : BatchToCreateHPNBatchRecords.cls
* @Description        : Batch to create to HPN check records group by Checks.
* @Author             : Teksystems
* @story              : SFDC-1105
* @Created date       : 10-Feb-2020 (Teksystems)
**/
public class BatchToCreateHPNBatchRecords implements Database.Batchable<sObject>,Database.Stateful {
    
    Public Map<Id,CBRChecks__c> checkid= new Map<Id,CBRChecks__c>();
    public double totalCheckAmount=0;
    Boolean chain3rdbatch=true;
    List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
    
    
    public BatchToCreateHPNBatchRecords(Map<Id,CBRChecks__c> checks, double checkamount){
        checkid.putAll(checks);
        system.debug('The Checkids are '+checkid);
        totalCheckAmount= checkamount;
        system.debug('The checkamount are '+totalCheckAmount);
    }
    public Database.QueryLocator Start(Database.BatchableContext bc){
        system.debug('Inside start');
        string query='select id,Name,Check__c,Amount__c,Check_Type__c,Status__c,HPN_Batch_ID__c from CBRChecks__c where HPN_Batch_ID__c=null and Status__c=\'Pending Payment\'';
        return Database.getQueryLocator(query);
    }   
    public void Execute(Database.BatchableContext bc, list<CBRChecks__c> checkList){
        system.debug('The Checks  records are--->'+checkList);
        system.debug('The Checks records are--->'+checkList.size());
        //Getting Che ck ID's and Total Amount
        for(CBRChecks__c eackChk:checkList){
            checkid.Put(eackChk.id,eackChk);
            totalCheckAmount+=eackChk.Amount__c;
        }
        system.debug('The total Check Amount'+totalCheckAmount);
        
    }
    
    public void Finish(Database.BatchableContext bc){
        
        List<String> errors = new List<String>();
        List<Payable__c> voidPayables= new  List<Payable__c>();
        string insertedBatchID='';
        Map<Id,List<Payable__c>> checkPayableMap = new Map<Id,List<Payable__c>>();
        List<HPNBatch__c> finalBatch= new List<HPNBatch__c>();
        List<Payable__c> finalPayablesToUpdate= new  List<Payable__c>();
        Integer totalPayables=0;
        //fetching Paybles for respective checks
        Map<Id,Payable__c> checkPayables= new Map<Id,Payable__c>([select id,name,Asset__c,Opportunity__c,Provider_ID__c,HPN_Provider_Agreement__c,CBRChecks__c from Payable__c where CBRChecks__c =:checkid.keySet() limit :limits.getLimitQueryRows()]);
        if(checkPayables!=null && !checkPayables.isEmpty()){
            for(Payable__c eachpayable:checkPayables.values()){
                if(checkPayableMap.containskey(eachpayable.CBRChecks__c)) { 
                    checkPayableMap.get(eachpayable.CBRChecks__c).add(eachpayable);
                }
                else{
                    checkPayableMap.put(eachpayable.CBRChecks__c, new List<Payable__c>{eachpayable});
                } 
            }
            system.debug('the CheckPayable Map'+checkPayableMap);
        }
        //Calculating Toatal Number Of payables
        for(List<Payable__c> eachpay:checkPayableMap.values()){
            totalPayables+=eachpay.size();
            
        }
        
        System.debug('The Total Payable Records are'+totalPayables);
        System.debug('The Total Check Amount '+totalCheckAmount);
        
        if(!checkid.isEmpty() && !checkid.isEmpty()){
            HPNBatch__c newBatch= new HPNBatch__c();
            newBatch.Number_of_Payments__c=totalPayables;
            newBatch.Total_Pending_Payment__c=totalCheckAmount;
            newBatch.Status__c='Pending Payment';
            newBatch.Batch_Type__c='HPN';
            newBatch.Total_Void__c=0;
            finalBatch.add(newBatch);
        }
        //Insert HPNBatch
        if(finalBatch!= null && !finalBatch.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(finalBatch,false);
            for (Database.SaveResult saveResult : saveResults) {	
                if (saveResult.isSuccess()) {	
                    insertedBatchID=saveResult.id;	
                }
            }
            for (integer i=0; i<saveResults.size(); i++) {
                string ErrDetail='';
                
                if (!saveResults.get(i).issuccess()) {
                    //Database.Error error  = ;
                    for (Database.Error e : saveResults.get(i).getErrors()) {
                        ErrDetail+=e.getMessage()+e.getStatusCode();
                        errors.add(e.getMessage());
                        system.debug('error..................'+e.getMessage());
                        
                    }
                    
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(saveResults.get(i).id, 'HPN Batch records creation Batch', 'Apex', ErrDetail, false, false);
                    cbrErrorLog.add(cbr);
                }
            }
            if(!cbrErrorLog.isEmpty()){
            Database.insert(cbrErrorLog, false);  
        }
            system.debug(errors);
            system.debug('error size'+errors.size());
        }
        
        //Fetching Checks and Updating
        for(CBRChecks__c eachChecks: checkid.values()){
            eachChecks.HPN_Batch_ID__c=insertedBatchID;
        }
        database.update(checkid.values(),false);
        
        //Fetching Payables and Updating
        for(List<Payable__c> eachpay:checkPayableMap.values()){
            for(Payable__c pay:eachpay){
                pay.Batch_ID__c=insertedBatchID;
                finalPayablesToUpdate.add(pay);
            }   
        }
        if(finalPayablesToUpdate!= null && !finalPayablesToUpdate.isEmpty()){
            database.update(finalPayablesToUpdate,false);
            
        }
        
        if(chain3rdbatch){
            database.executebatch(new batchXmlGenerator());
        }else{
            System.debug(' 3rd Batch could not start , check for 2nd Batchh to start ');
        }
        
    }
    
}