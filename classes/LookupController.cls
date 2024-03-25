public with sharing class LookupController {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String objectName, List<sObject> excludeItemsList, String whereClause, 
                                                     List<String> searchableFields, List<String> fieldsToQuery, String orderBy, String rowLimit, 
                                                     List<String> additionalFieldsToQuery) {
        system.debug(searchKeyWord);
        system.debug(objectName);
        system.debug(whereClause);
        system.debug(fieldsToQuery);
        system.debug(searchableFields);
        system.debug(excludeItemsList);
        
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > (); 		
        List<string> lstExcludeitems = new List<string>();
		if(ExcludeItemsList!=null) {
            for(sObject item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }
        }                                                        
        
        
        String searchableFieldsCondition = '';
        
        if(searchableFields!=null && searchableFields.size()>0){
            for(String str: searchableFields){
                searchableFieldsCondition = searchableFieldsCondition + str + ' LIKE: searchKey and ';
            }
        }
        
        String searchQuery = 'select Id';
        if(fieldsToQuery!=null && fieldsToQuery.size()>0){
            searchQuery = searchQuery+','+String.join(fieldsToQuery, ',');
        }
            
        if(additionalFieldsToQuery!=null && additionalFieldsToQuery.size()>0){
            searchQuery = searchQuery+','+String.join(additionalFieldsToQuery, ',');
        }
        
        searchQuery = searchQuery + ' from '+ objectName;
        String sQuery = '';
        if(whereClause!=null && whereClause!=''){
            if(searchKeyWord!=null && searchKeyWord!=''){
                
                sQuery = searchQuery + ' where '+ whereClause + ' and '+ searchableFieldsCondition+' Id NOT IN : lstExcludeitems order by '+ orderBy+' limit '+rowLimit;   
                
            }else{
                
                sQuery = searchQuery + ' where '+ whereClause+' and Id NOT IN : lstExcludeitems order by '+ orderBy+' limit '+rowLimit ;
                
            }
        }
        else{
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT  and exclude already selected records  
            sQuery =  searchQuery + ' where '+searchableFieldsCondition+' Id NOT IN : lstExcludeitems order by '+ orderBy+' limit '+rowLimit;
        }        
        system.debug(sQuery);
        return Database.query(sQuery);                        
    }           
}