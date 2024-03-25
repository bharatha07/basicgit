/**************************************************************************************************************************************
*Component Name : CaseCreateCusBtnController 
*Developed By   : TEKsystems
*Description    : This class is controller for "New Case" create button on opportunity page.
                  On click of this button,it will give option  to create new case record on opportunity.
*User Story     :  US-1140
**********************************************************************************************************************************/

public class CaseCreateCusBtnController {
   @AuraEnabled
    public static Map<String,String> getCaseRecordType(String sObjectName) {
        Map<String,String> valueToLabel = new Map<String,String>();
        try {
            if (!String.isBlank(sObjectName)) {
                for(RecordTypeInfo info: Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfos()) {
                   if(info.isAvailable() && (info.getName() != 'Master' && info.getName().trim() != '')) {                           
                        valueToLabel.put(info.getRecordTypeId(), info.getName());
                    }
                }
            }         
        } catch (Exception e) { }
        return valueToLabel;      
    }
}