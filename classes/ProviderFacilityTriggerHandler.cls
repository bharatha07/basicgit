/******************************************************************************************************************************
*Component Name: ProviderFacilityTriggerHandler
*Created Date :
*Description : Restrict to allow more than one primary facility on provider 
*Created By : (TekSystems)
*******************************************************************************************************************************/
public class ProviderFacilityTriggerHandler {
    
    public static void DupPrimaryProvFachandler(List<Provider_Facility__c> Provfacility,map<id,Provider_Facility__c> oldMap) {
              set<Id>accIds =new set<Id>();
            Id providerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
            for(Provider_Facility__c pf : Provfacility) {
                system.debug('Provfacility>>>>'+Provfacility);
                if(pf.Provider__c != Null && pf.Primary__c==true && (oldMap == null || (oldMap!=null && !oldMap.isEmpty() && oldMap.get(pf.id).Primary__c != pf.Primary__c))) {
                    accIds.add(pf.Provider__c);
                    system.debug('accIds>>>>'+accIds);
                }
            }
        if(!accIds.isEmpty()){
            map<id,Provider_Facility__c> pflist=new map<id,Provider_Facility__c>([Select Id,Primary__c From Provider_Facility__c Where Provider__c IN:accIds AND Primary__c = True]);
            system.debug('pflisttttt>>>'+pflist);
            for(Provider_Facility__c prov:Provfacility){
                system.debug('pflist.size>>'+pflist.size());
                system.debug('prov>>>>'+prov.id);
                system.debug('pflistout.containskey>>>'+pflist.containskey(prov.id));
                if(pflist.size() > 0 && !pflist.containskey(prov.id)){
                    system.debug('pflist.containskey>>>'+pflist.containskey(prov.id));
                    system.debug('my test sample');
                    prov.addError('You cannot add more than one primary facility for this Account'); 
                }
            }
    }
        }
    }