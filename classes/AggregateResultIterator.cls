global class AggregateResultIterator Implements Iterator<AggregateResult> { 
    AggregateResult [] results {get;set;} 
    Integer index {get;set;} 
    
    global AggregateResultIterator(DateTime startDateTime, DateTime endDateTime){ 
        index = 0; System.debug(startDateTime); System.debug(endDateTime);
        System.debug([SELECT Opportunity__c,CreatedDate,Primary__c FROM OpportunityContact__c WHERE CreatedDate >=: startDateTime AND CreatedDate <=: endDateTime  LIMIT 2000]);
        String query='SELECT Opportunity__c FROM OpportunityContact__c WHERE CreatedDate >=: startDateTime AND CreatedDate <=: endDateTime AND Primary__c = true GROUP BY Opportunity__c HAVING Count(Id) = 1';
        System.debug('Date  Start' + startDateTime);
        System.debug('Date  End' + endDateTime);
        System.debug('>>>>>>>>' + Database.query('SELECT Id,CreatedDate,Primary__c FROM OpportunityContact__c'));
        System.debug('>>>>>>>>' + Database.query(query));
        results = Database.query(query); 
        
    } 
    
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 

    global AggregateResult next(){ 
        return results[index++]; 
    } 
}