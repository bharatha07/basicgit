public class CBRPayToHandler {
    
    public static void updateCityStateCountry(List<CBR_PAY_TO__c> payToList){
        Set<string> payToIdszipCode = new Set<string>();
        Map<string,US_Zipcode__c> zipCodeMap = new Map<string,US_Zipcode__c>();
        map<id,CBR_PAY_TO__c> oldMapCBR = (map<id,CBR_PAY_TO__c>) trigger.oldMap;
        for(CBR_PAY_TO__c payTo:payToList){
            if(payTo.Zip_Code__c != null && trigger.isInsert){
                payToIdszipCode.add(payTo.Zip_Code__c);
            }
            else if(trigger.isUpdate && ((oldMapCBR.get(payTo.id).Zip_Code__c != payTo.Zip_Code__c) || (oldMapCBR.get(payTo.id).State__c != payTo.State__c) ||
                                         (oldMapCBR.get(payTo.id).Country__c != payTo.Country__c) || (oldMapCBR.get(payTo.id).City__c != payTo.City__c))){
                                             payToIdszipCode.add(payTo.Zip_Code__c);
                                         }
        }
        if(!payToIdszipCode.isEmpty()){
            for(US_Zipcode__c zipUs:[select id,Name,City__c,Country__c,State__c from US_Zipcode__c where Name IN:payToIdszipCode]){
                zipCodeMap.put(zipUs.Name,zipUs);
            }
        }
        
        if(!payToIdszipCode.isEmpty()){
            for(CBR_PAY_TO__c payTo:payToList){
                if(zipCodeMap.containskey(payTo.Zip_Code__c)){
                    US_Zipcode__c zip = zipCodeMap.get(payTo.Zip_Code__c);
                    payTo.State__c = zip.State__c;
                    payTo.Country__c = zip.Country__c;
                    payTo.City__c = zip.City__c;
                }
                else if(zipCodeMap.get(payTo.Zip_Code__c)==null){
                    payTo.Zip_Code__c.addError('An invalid zip code has been entered');
                }
            }
        }
    }
    
    public static void updatePayableStatus(List<CBR_PAY_TO__c> CbrPayToList){
        Set<id> payTOIDs= new Set<id>();
        List<Payable__c> allPayables = new List<Payable__c>();
        Map<id,CBR_PAY_TO__c> pACbrPayto= new  Map<id,CBR_PAY_TO__c>();
        if(CbrPayToList!=null && !CbrPayToList.isEmpty()){
            for(CBR_PAY_TO__c eachPayTO:CbrPayToList){
                // As a part of SFDC-1737 
                // consider cbrpayto with provider agreement as Null
                if(eachPayTO.Address__c!=null && eachPayTO.City__c!=null && eachPayTO.State__c!=null && eachPayTO.Country__c!=null && eachPayTO.Zip_Code__c!=null && eachPayTO.Tax_ID__c!=null && eachPayTO.Active__c==true && eachPayTO.Provider_Agreement__c==null){
                    system.debug('inside agreement Cbr payto');
                    payTOIDs.add(eachPayTO.Id);
                }
                // As a part of SFDC-1737 
                // consider cbrpayto associated with provider agreement and payto group as False
                if(eachPayTO.Address__c!=null && eachPayTO.City__c!=null && eachPayTO.State__c!=null && eachPayTO.Country__c!=null && eachPayTO.Zip_Code__c!=null && eachPayTO.Tax_ID__c!=null && eachPayTO.Active__c==true && eachPayTO.Provider_Agreement__c!=null && eachPayTO.Provider_Agreement__r.Pay_to_Group__c==false){
                    system.debug('inside Provider agreement Cbr payto');
                    pACbrPayto.put(eachPayTO.Provider_Agreement__c, eachPayTO);
                }
            } 
        }
        system.debug('Provider agreement Cbr payto--->'+pACbrPayto);
        if(payTOIDs!=null && !payTOIDs.isEmpty()){
            for(Payable__c eachPayables:[select id,name,Status__c,CBR_PAY_TO__c from Payable__c where Status__c='Needs Attention' and CBR_PAY_TO__c IN: payTOIDs]){
                eachPayables.Status__c='Pending Accounting';
                eachPayables.Declined_Reason__c='';
                allPayables.add(eachPayables);
            }
        }
        if(!pACbrPayto.isEmpty()){
            for(Payable__c eachPayable:[select id,name,Status__c,Declined_Reason__c,CBR_PAY_TO__c,HPN_Provider_Agreement__c from Payable__c where Status__c='Needs Attention' and Declined_Reason__c!=null and HPN_Provider_Agreement__c IN:pACbrPayto.keyset()]){
                eachPayable.Status__c='Pending Accounting';
                eachPayable.Declined_Reason__c='';
                if(eachPayable.CBR_PAY_TO__c==null){
                    eachPayable.CBR_PAY_TO__c=pACbrPayto.get(eachPayable.HPN_Provider_Agreement__c).id;
                }
                allPayables.add(eachPayable);
            }
        }
        
        If(allPayables.size()>0){
            database.update(allPayables,false);
        }
    }  
}