/*************************************************************************************************
* @description This method to update the No of primary quote count on quote.
* @param - Trigger List
* @story - SFDC-1969
* @return Void
* @date - 06-SEP-2021 (Teksystems)
*/
public class quoteTriggerHandler {
    public static boolean isTrue=false;
    public static void noOfPrimaryQuotes(list<SBQQ__Quote__c> quoteList){
        map<id,SBQQ__Quote__c> quoteOldMap = (map<id,SBQQ__Quote__c>)Trigger.oldmap;
        set<id> optyIds = new set<Id>();
        map<id,integer> primarySize = new map<id,integer>();
        for(SBQQ__Quote__c quote : quoteList){
            if(trigger.isInsert){
                optyIds.add(quote.SBQQ__Opportunity2__c);
            }
            else if(trigger.isUpdate && quoteOldMap.get(quote.id).SBQQ__Primary__c != quote.SBQQ__Primary__c){
                optyIds.add(quote.SBQQ__Opportunity2__c);
            }
        }
        if(!optyIds.isEmpty()){
            for(aggregateResult agr : [select count(id) recrdCount, SBQQ__Opportunity2__c optyId from SBQQ__Quote__c where SBQQ__Opportunity2__c IN : optyIds 
                                       and SBQQ__Primary__c =true group by SBQQ__Opportunity2__c] ){
                                           integer  size =(integer)agr.get('recrdCount');
                                           id  rcId =(Id)agr.get('optyId');
                                           primarySize.put(rcId,size);
                                           system.debug('primarySize---'+primarySize);
                                       }
        }
        if(!optyIds.isEmpty()){
            system.debug('isTrue--'+isTrue);
            for(SBQQ__Quote__c quote : quoteList){
                system.debug('quoteList---'+quoteList);
                system.debug('quoteListsize---'+quoteList.size());
                if(quote.SBQQ__Primary__c == true){
                    integer noOfPrimary = primarySize.containskey(quote.SBQQ__Opportunity2__c) ? primarySize.get(quote.SBQQ__Opportunity2__c) : 1;
                    quote.No_of_primary_quote__c= noOfPrimary;
                    system.debug('primarySize'+primarySize.get(quote.SBQQ__Opportunity2__c));
                    isTrue=true;
                    system.debug('No_of_primay_quote__ccc'+quote.No_of_primary_quote__c);
                }
                else if (isTrue == false && quote.SBQQ__Primary__c == false){
                    system.debug('primarySize else'+primarySize.get(quote.SBQQ__Opportunity2__c));
                    quote.No_of_primary_quote__c=0;
                    system.debug('elseNo_of_primary_quote__ccc'+quote.No_of_primary_quote__c);
                }
            }
        }
    }
    
}