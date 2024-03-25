public class UtilityClass {
    
    public static cbr_Error_Log__c logErrors(string RecordId ,string businessProcess,string errorType, string errorDetail,boolean notifyAdmin,boolean isInsert ){
        cbr_Error_Log__c errLog =new cbr_Error_Log__c();
        errLog.cbr_Record_Id__c=RecordId;
        errLog.cbr_Business_Process__c=businessProcess;
        errLog.cbr_Error_Detail__c=errorDetail;
        errLog.cbr_Notify_Admin__c=notifyAdmin;
        errLog.cbr_Error_Type__c=errorType;
        if(isInsert){
            insert errLog;
        }
        return errLog;
    }
}