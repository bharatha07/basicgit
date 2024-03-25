global class CordBloodValidateDial {
	webService static String blockRequest(String recordType, String recordId, String recordField) { 
    	
    	String SQL = 'Select ' + recordField + ' from ' + recordType + ' where id = \'' + recordId + '\' ';
        try{
            system.debug('**CordBloodValidateDial SQL:' + SQL);
            
            List <sObject> qry = Database.query(SQL);
            
            if ( qry.size() == 0)return null;

            system.debug('**CordBloodValidateDial ret:' + JSON.serialize(qry));
            //return JSON.serialize(qry);
            return JSON.serialize(qry[0]);
        
            
        }catch(Exception e){
          	system.debug('**CordBloodValidateDial Exception caught:' + e.getMessage());
     
        }
    
    	return null;
    
	}
    
   
}