/******************************************************************************************************************************
*Component Name: ProviderFacilityTest
*Created Date :
*Description : Test Class for ProviderFacilityTriggerHandler
*Created By : (TekSystems)
*******************************************************************************************************************************/
@isTest
public class ProviderFacilityTriggerHandlerTest {
@isTest static void testUnit(){
    list<Account> ProviderAccountList= TestDataFactory.createProviderAccounts();
    list<Provider_Facility__c> provfac= new list<Provider_Facility__c>();
    Provider_Facility__c pf=new Provider_Facility__c();
    pf.provider__c=ProviderAccountList[0].id;
   pf.primary__c=true;
    provfac.add(pf);
    
    Provider_Facility__c pf1=new Provider_Facility__c();
    pf1.provider__c=ProviderAccountList[0].id;
   pf1.primary__c=false;
    provfac.add(pf1);
     database.insert(provfac,false);
     //System.assertEquals(provfac.size()>0,true);
}
}