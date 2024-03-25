/**********************************************************************************************************************************************
*Component Name: ProviderAgreementHandler
*Created Date : 22/02/2021
*Description : This class is for ProviderAgreementTrigger.
*Created By : 
**************************************************************************************************************************************************/
public class ProviderAgreementHandler {
    public static void validateProviderExistsOrNot(List<Provider_Agreement__c> provderAgreeList){
        set<Id> providerIds = new set<Id>();
        map<id,list<Provider_Agreement__c>> proderAgreeProviderMap = new map<id,list<Provider_Agreement__c>>();
        date dt = system.today();
        for(Provider_Agreement__c eachRecord : provderAgreeList){
            if(eachRecord.Provider__c !=null){
                providerIds.add(eachRecord.Provider__c);
            }   
        }
        if(!providerIds.isEmpty()){
            for(Provider_Agreement__c providerAgremnt : [Select id,Provider__c,Active_HPNFlag__c,HPN_End_Date__c,HPN_Start_Date__c from Provider_Agreement__c where Provider__c IN : providerIds AND HPN_Start_Date__c!=null and Active_HPNFlag__c=true]){
                if(proderAgreeProviderMap.containskey(providerAgremnt.Provider__c)){
                    proderAgreeProviderMap.get(providerAgremnt.Provider__c).add(providerAgremnt); 
                }
                else{
                     proderAgreeProviderMap.put(providerAgremnt.Provider__c,new list<Provider_Agreement__c>{providerAgremnt}); 
                }
            }
        }
        if(!proderAgreeProviderMap.isEmpty()){
            for(Provider_Agreement__c provdAgreemnt : provderAgreeList){
                if(proderAgreeProviderMap.containskey(provdAgreemnt.Provider__c)){
                    if(proderAgreeProviderMap.get(provdAgreemnt.Provider__c).size()>0){
                        provdAgreemnt.addError('This Provider is already associated with active agreement');
                    }
                }
            }
        }
        
    }
}