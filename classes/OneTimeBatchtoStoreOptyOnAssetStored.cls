/*************************************************************************************************
* @description This Batch job is to fetch enrolled optys for yesterday and check for stored assets in order to make opty as stored.
* @param - 
* @story - SFDC
* @Author -Teksystems
* @date - 28-Apr-2021 (Teksystems)
*/
public class OneTimeBatchtoStoreOptyOnAssetStored implements Database.Batchable<sObject>,Database.Stateful{
    public  map<id,map<string,list<asset>>> optyAssetMap = new map<id,map<string,list<asset>>>();
    public map<id,list<Asset>> storedltstAsset =  new map<id,list<Asset>>();
    public list<String> Opportunityids = System.label.OpportunityList.split(',');
    public Database.QueryLocator Start(Database.BatchableContext bc){
        string query='';	
        query +='select id,Opportunity__c,Type__c,Status,FreezeDate__c,Associated_Sample__c  from Asset where Opportunity__r.Status__c =\'Enrolled\''+ 
            ' and Opportunity__c !=null ';
        if(!Test.isRunningTest()){
            query +='and Opportunity__c IN: Opportunityids';
        }
        query +=' order by FreezeDate__c asc';
        return Database.getQueryLocator(query);
    }   
    public void Execute(Database.BatchableContext bc, list<Asset> assetLst){
        map<id,DateTime> frezedateTime= new map<id,DateTime>();
        set<ID> optyIds = new set<ID>();
        set<id> optyAssetid = new set<id>();
        list<Opportunity> optyUpdtList1 = new list<Opportunity>();
        for(Asset assT : assetLst){
            if(storedltstAsset.containskey(assT.Opportunity__c)){
                storedltstAsset.get(assT.Opportunity__c).add(assT); 
            }else {
                storedltstAsset.put(assT.Opportunity__c, new list<Asset>{assT});
            }
            if((assT.status == 'Stored' || assT.Status=='Non-processed') && optyAssetMap.containsKey(assT.Opportunity__c)){
                map<string,list<Asset>> assetMap = optyAssetMap.get(assT.Opportunity__c);
                if(assetMap != Null && assetMap.containskey(assT.Type__c)){ 
                    assetMap.get(assT.Type__c).add(assT);
                }else{
                    assetMap.put(assT.Type__c,new list<asset>{assT});
                }
                if(frezedateTime.get(assT.Opportunity__c)==null){
                            frezedateTime.put(assT.Opportunity__c,assT.FreezeDate__c);
                        }
            }else{
                list<asset> assLst = new list<asset>();
                assLst.add(assT);
                if(assT.status == 'Stored' || assT.Status=='Non-processed'){
                    optyAssetMap.put(assT.Opportunity__c, new map<string,list<asset>>{assT.Type__c=>assLst});
                }
                
                frezedateTime.put(assT.Opportunity__c,assT.FreezeDate__c);
            }
            
        }
        if(!optyAssetMap.isEmpty()){
            for(asset assets  : assetlst){
                opportunity opty = new opportunity(id=assets.Opportunity__c);
                if(optyAssetMap.containskey(assets.Opportunity__c)){
                    map<string,list<asset>> asstMap = optyAssetMap.get(assets.Opportunity__c);
                    if(asstMap!=null && !asstMap.isEmpty()){
                        Integer cbStoredAssets = asstMap.get('Cord Blood') != null ? asstMap.get('Cord Blood').size() : 0;
                        system.debug('cbStoredAssets>>>>'+cbStoredAssets);
                        Integer ctStoredAssets = asstMap.get('Cord Tissue') != null ? asstMap.get('Cord Tissue').size() : 0;
                        system.debug('ctStoredAssets>>>'+ctStoredAssets);
                        Integer storedAssets = cbStoredAssets + ctStoredAssets ;
                        if(storedAssets ==storedltstAsset.get(assets.Opportunity__c).size() && !optyAssetid.contains(assets.Opportunity__c)){
                            system.debug('>>>>>Smpletest');
                            if(storedltstAsset.get(assets.Opportunity__c).size()==1 && assets.Status =='Non-processed'){
                                //Not processing anything.
                            }else{
                            opty.Status__c='Stored';
                            
                            if(frezedateTime.containskey(assets.Opportunity__c)){
                                opty.Storage_Date__c=frezedateTime.get(assets.Opportunity__c);
                                system.debug('opty.Storage_Date__c---'+opty.Storage_Date__c);
                            }
                            
                            
                            if(asstMap.containsKey('Cord Blood')){
                                list<Asset> cbAss = asstMap.get('Cord Blood');
                                system.debug('size of assets----'+cbAss.size());
                                opty.of_CB__c=string.valueOf(cbAss.size());
                                system.debug('cb----'+opty.of_CB__c);
                                system.debug('cb stored----'+opty.Stored_CB__c);
                            }else{
                                opty.of_CB__c='0';
                            }
                            if(asstMap.containsKey('Cord Tissue')){
                                list<Asset> ctAss = asstMap.get('Cord Tissue');
                                system.debug('size of ct assets---'+ctAss);
                                opty.of_CT__c=string.valueOf(ctAss.size());
                            }else{
                                opty.of_CT__c='0';
                            }
                            optyUpdtList1.add(opty);
                            optyAssetid.add(assets.Opportunity__c);
                        }
                        }
                    }
                    
                    
                }
                
            }
        }
        if(!optyUpdtList1.isEmpty()){
            List<Database.SaveResult> saveResults = database.update (optyUpdtList1,false);
            List<cbr_Error_Log__c> cbrErrorLog = new List<cbr_Error_Log__c>();
            string ErrDetail;
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        ErrDetail +=err.getStatusCode()+err.getMessage()+ '\n';   
                    }
                    
                    system.debug('erromessgae'+ErrDetail);
                    
                }       
            }
            if(string.isNotBlank(ErrDetail)){
                cbr_Error_Log__c cbr =UtilityClass.logErrors(null, 'Store opty on all Asset stored for Merge created Assets', 'Apex Error', ErrDetail, false, false);
                cbrErrorLog.add(cbr);  
            }
            
            if(!cbrErrorLog.isEmpty()){
                Database.insert(cbrErrorLog, false);
            }
            system.debug('>>>>>>'+cbrErrorLog);
        }
    }
    public void Finish(Database.BatchableContext bc){
        
    } 
    
    
}