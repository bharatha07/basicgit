/**********************************************************************************************************************************************
*Component Name: CBRChecksTriggerHandler
*Created Date : 24th March 2021
*Description : Checks logic to excute from trigger events
*Created By : Bharath Avaldar(TekSystems)
**************************************************************************************************************************************************/
public class CBRChecksTriggerHandler{
    
    public static void recalculateVoidChecks(Map<Id,CBRChecks__c> newMap, Map<Id,CBRChecks__c> oldMap){
        Set<Id> voidCheckIDS = new Set<Id>();
        List<HPNBatch__c> finalBatches = new List<HPNBatch__c> ();
        Map<id,Double> batchCheckamounts= new Map<id,Double>();
        Map<id,HPNBatch__c> batchRecords= new Map<id,HPNBatch__c>();
        for(CBRChecks__c eachChk:newMap.values()){
            if(String.isNotBlank(eachChk.Status__c) && eachChk.Status__c <> oldMap.get(eachChk.Id).Status__c && eachChk.Status__c=='Void' && oldMap.get(eachChk.Id).Status__c=='Paid'){
                voidCheckIDS.add(eachChk.id);
            }
        }
        system.debug('The void checks are--->'+voidCheckIDS);
        if(!voidCheckIDS.isEmpty()){
            List<AggregateResult> obj = [SELECT HPN_Batch_ID__c,SUM(Amount__c) sum FROM CBRChecks__c where ID IN:voidCheckIDS  group by HPN_Batch_ID__c limit 2000];
            system.debug('The obj-->'+obj);
            for(AggregateResult eachagr : obj)
            {
                batchCheckamounts.put(String.valueOf(eachagr.get('HPN_Batch_ID__c')),(Decimal)eachagr.get('sum'));
            }  
        }
         system.debug('The batchCheckamounts--->'+batchCheckamounts);
        if(!batchCheckamounts.isEmpty()){
            batchRecords=new Map<id,HPNBatch__c>([select id,Name,Total_Paid__c,Total_Void__c,Status__c from HPNBatch__c where id IN :batchCheckamounts.keyset() and Status__c='Paid']);
            for(HPNBatch__c eachbatch: batchRecords.values()){
                if(batchCheckamounts.containskey(eachbatch.id)){
                    decimal totalvoid=eachbatch.Total_Void__c==null?0:eachbatch.Total_Void__c;
                    totalvoid+=batchCheckamounts.get(eachbatch.id);
                    eachbatch.Total_Void__c=totalvoid;
                    eachbatch.Total_Paid__c=eachbatch.Total_Paid__c!=null?eachbatch.Total_Paid__c-batchCheckamounts.get(eachbatch.id):eachbatch.Total_Paid__c;
                    finalBatches.add(eachbatch);
                }
            }
        }
       system.debug('The final Batch records are -->'+finalBatches); 
        If(finalBatches.size()>0){
            database.update(finalBatches,false);
        }
    }
}