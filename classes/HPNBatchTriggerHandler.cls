/******************************************************************************************************************************
*Component Name: HPNBatchTriggerHandler
*Created Date : 11-FEB-2021
*Description : Trigger logic for HPNBatch events
*Created By : Teksystems
*******************************************************************************************************************************/

public class HPNBatchTriggerHandler {
    public static void updateBatchName(List<HPNBatch__c> batchRecords){
        Integer batchSize=0;
        map<Integer,String> suffixmap= new map<Integer,String>{1 =>'A', 2 =>'B', 3 =>'C', 4 =>'D', 5 =>'E', 6 =>'F', 7 =>'G', 8 =>'H', 9 =>'I', 10 =>'J',11=>'K',12=>'L',13=>'M',14=>'N',
                                                                15 =>'O', 16 =>'P', 17 =>'Q', 18 =>'R', 19 =>'S', 20 =>'T', 21 =>'U', 22 =>'V', 23 =>'W', 24 =>'X',25=>'Y',26=>'Z'};
        List<HPNBatch__c> hpnBatchhistory= new  List<HPNBatch__c>([SELECT id,name FROM HPNBatch__c where CreatedDate=today ]);
        batchSize=hpnBatchhistory.size();
        Date dToday = Date.today();
        String batchName = dToday.month() +''+ dToday.day() +''+ dToday.year()+''+suffixmap.get(batchSize+1);
        HPNBatch__c eachBatch=batchRecords[0];
        eachBatch.Name=batchName;
        system.debug('the name is'+eachBatch.Name);
    }
    
}