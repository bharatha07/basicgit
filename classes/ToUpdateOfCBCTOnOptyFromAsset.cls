/*************************************************************************************************
* @description This class will check for the count of asset type and update the opty based on Of_cb_c and Of_ct__c
* @param - 
* @story - SFDC-1668
* @Author -Teksystems
* @date - 01-May-2021 (Teksystems)
*/
public class ToUpdateOfCBCTOnOptyFromAsset {
    
    @InvocableMethod(label='AssetInvokeAbleMethod')
    public static void AssetList(List<Id> Assets)
    {
        Map<id,Map<String,List<Asset>>> optyAsstStrngMap = new Map<id,Map<String,List<Asset>>>();
        Map<id,opportunity> oppMap = new Map<id,opportunity>();
        set<id> AssetOptyid = new set<id>();
        List<Opportunity> OptyListToUpdate = new List<Opportunity>();
        if(!Assets.isEmpty()){
            for(id optty : assets){
               AssetOptyid.add(optty) ;
            }
        oppMap = new Map<Id,Opportunity>([select id,of_CB__c,of_CT__c from opportunity where id IN :AssetOptyid]);
        for(Asset EachAsset : [select id,Type__c, Status,CreatedDate, Opportunity__c, Opportunity__r.of_CB__c, Opportunity__r.of_CT__c from asset where Opportunity__c IN :AssetOptyid]){
            if( optyAsstStrngMap.containskey(EachAsset.Opportunity__c)){
                map<string,list<asset>> assStrngMap = optyAsstStrngMap.get(EachAsset.Opportunity__c);
                if(assStrngMap != null && assStrngMap.containskey(EachAsset.Type__c)){
                    assStrngMap.get(EachAsset.Type__c).add(EachAsset);
                }else{
                    assStrngMap.put(EachAsset.Type__c,new list<Asset>{EachAsset});
                }
                optyAsstStrngMap.put(EachAsset.Opportunity__c, assStrngMap);
            }else{
                list<asset> astLst = new list<asset>();
                astLst.add(EachAsset);
                optyAsstStrngMap.put(EachAsset.Opportunity__c, new map<string,list<asset>>{EachAsset.Type__c=>astLst});
            }
        }
    }
        if(!optyAsstStrngMap.isEmpty()){
            for(id optyid:oppMap.keyset()){
                opportunity opp = oppMap.get(optyid);
                map<string,list<asset>> asstMap = optyAsstStrngMap.get(optyid);
                if(asstMap!=null && !asstMap.isEmpty()){
                Integer cbStoredAssets = asstMap.get('Cord Blood') != null ? asstMap.get('Cord Blood').size() : 0;
                system.debug('cbStoredAssets>>>>'+cbStoredAssets);
                Integer ctStoredAssets = asstMap.get('Cord Tissue') != null ? asstMap.get('Cord Tissue').size() : 0;
                    if(opp.of_CT__c != string.valueOf(ctStoredAssets) && ctStoredAssets > 0){
                        opp.of_CT__c = string.valueOf(ctStoredAssets);
                    }else{
                        opp.of_CT__c = string.valueOf(ctStoredAssets);
                    }
                    if(opp.of_CB__c != string.valueOf(cbStoredAssets) && cbStoredAssets > 0){
                        opp.of_CB__c = string.valueOf(cbStoredAssets);
                    }else{
                        opp.of_CB__c = string.valueOf(cbStoredAssets);
                    }
                }
                OptyListToUpdate.add(opp);
                //AssetOptyid.add(opp.id);
            }
        }
        if(!OptyListToUpdate.isEmpty()){
          database.update(OptyListToUpdate);
        }
    }
    
}