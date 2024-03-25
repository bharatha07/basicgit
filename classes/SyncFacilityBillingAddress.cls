public class SyncFacilityBillingAddress {
    @InvocableMethod
    public static void updateBillingAddress(List<Id> facilityID){
        
        set<Id> allProviderIDS= new set<Id>();
        List<Account> finalProviders= new  List<Account>();
        
        List<Provider_Facility__c> allPRvFacility =[select id,Primary__c, Provider__c, Facility__c, Facility__r.BillingCity, Facility__r.BillingCountry, Facility__r.BillingCountryCode, Facility__r.BillingPostalCode,
                                                    Facility__r.BillingState, Facility__r.BillingStateCode, Facility__r.BillingStreet  from Provider_Facility__c where Primary__c=true and Provider__c!=null and Facility__c=:facilityID[0] ];
        if(allPRvFacility!=null || !allPRvFacility.isEmpty()){
            
            for(Provider_Facility__c eachrec:allPRvFacility){
                allProviderIDS.add(eachrec.Provider__c);
            }
            
            If(allProviderIDS!=null || !allProviderIDS.isEmpty()){
                for(Account eachAccount:[select id,BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet from Account where RecordType.Name='Provider' and ID IN :allProviderIDS]){
                    eachAccount.BillingCity=allPRvFacility[0].Facility__r.BillingCity;
                    eachAccount.BillingCountry=allPRvFacility[0].Facility__r.BillingCountry;
                    eachAccount.BillingCountryCode=allPRvFacility[0].Facility__r.BillingCountryCode;
                    eachAccount.BillingPostalCode=allPRvFacility[0].Facility__r.BillingPostalCode;
                    eachAccount.BillingState=allPRvFacility[0].Facility__r.BillingState;
                    eachAccount.BillingStateCode=allPRvFacility[0].Facility__r.BillingStateCode;
                    eachAccount.BillingStreet=allPRvFacility[0].Facility__r.BillingStreet ;
                    finalProviders.add(eachAccount);
                }
            }
        }
        if(finalProviders.size()>0){
            update finalProviders;
        }
    }
}