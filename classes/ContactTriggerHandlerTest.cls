/******************************************************************************************************************************
*Component Name: ContactTriggerHandlerTest
*Created Date :07-OCT-2020 (Teksystems)
*Description : Test Class for ContactTriggerHandler
*Created By : TekSystems
*******************************************************************************************************************************/
@isTest
public class ContactTriggerHandlerTest {
    /*************************************************************************************************
     * @description This test method is used to test the  publish platform event for new contcat payement profile creation
     * @param - None
     * @story - SFDC-1235
     * @return Void
     * @date - 07-OCT-2020 (Teksystems)
 */
    @isTest static void FacConPFeventTestM1(){
    Test.startTest();
     List<Account> facilityAccountList = TestDataFactory.createFacilityAccounts();  
        facilityAccountList[0].Kit_Stocking__c=true;
        update facilityAccountList;
  
    List<Contact> conList = new List<Contact>();
      conList.add(new Contact(FirstName='testFirst',LastName='testlast',AccountId=facilityAccountList[0].id,Email='t444@abc.com',Phone='+1 818-845-3223',Facility_Role__c='L&D Hospitalist'));   
    Insert conList;
    
   // Facility_Kit_Update_Event__e consumerevent = new Facility_Kit_Update_Event__e (Facility_Id__c =facilityAccountList[0].id);
   // Database.SaveResult saveResult = EventBus.publish(consumerevent );
    List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        PlatformEventWrapper.FacilityKitUpdateEvent facWrp=new PlatformEventWrapper.FacilityKitUpdateEvent();
        CBR_Message_Event__e cbrEvt=new CBR_Message_Event__e();
        cbrEvt.EventType__c='Facility Kit Update Event';
                   
         facWrp.FacilityId=facilityAccountList[0].id;
         cbrEvt.EventData__c=JSON.serialize(facWrp);
         cbrEvtList.add(cbrEvt);
        
        List<Database.SaveResult> saveResults = EventBus.publish(cbrEvtList);
    Test.StopTest();
    System.assertEquals(true, saveResults[0].isSuccess());
   }

}