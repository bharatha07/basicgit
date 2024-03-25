public class casetriggerhelper{
    
    public static void sendClosedIDMCase(Map<Id,case> newMap, Map<Id,case> oldMap){
        Id testResultId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Test Results').getRecordTypeId();
        List<Message__c> msgList = new List<Message__c>();
        
        for(case c:newMap.values()){
            if(c.recordtypeId == testResultId && c.Status == 'Closed' && c.Type == 'IDM - Test Results Letter' && ( oldMap==null || (oldMap!=null && oldMap.get(c.Id).status!=c.status)) ){
                Message__c msgRec=new Message__c();
                msgRec.Event_Type__c='send closed IDM case';
                PlatformEventWrapper.sendIDMClosedCase caseIdWrp=new PlatformEventWrapper.sendIDMClosedCase();
                caseIdWrp.sfdcCaseId=c.id;
                msgRec.Payload__c=JSON.serialize(caseIdWrp);
                msgRec.status__c = 'New';
                msgRec.Direction__c = 'outbound';
                msgList.add(msgRec);  
            }
        }
        
        if(!msgList.isEmpty()){
            List<Database.SaveResult> saveResults = database.insert(msgList,false);
            system.debug('punlish list ::'+msgList);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event for opty stored.1199');
                    // recursiveClass.facConPfevent= true;
                } else {
                    string ErrDetail='Error returned for opty stored.1199';
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Send Closed IDM Case Event', 'Apex Event', ErrDetail, false, false);
                    system.debug('cbrutility'+cbr);
                    cbrErrorLog.add(cbr);
                    system.debug('cbrutilityList'+cbrErrorLog);
                    
                }       
            }
            Database.insert(cbrErrorLog, false);
            system.debug('>>>>>>'+cbrErrorLog);
            
        }
    }
    /*************************************************************************************************
* @description This method is used show error message to the users while deleting the Case record.
* @param - Trigger List
* @story - SFDC-1405
* @return Void
* @date - 12-AUG-2021 (Teksystems)
*/
    public static void stopDeletingCase(List<Case> deleteLst){
        if(!deleteLst.isEmpty()){
            for(Case delLst : deleteLst){
                delLst.addError('Case cannot be deleted');
            }
        }
    }
}