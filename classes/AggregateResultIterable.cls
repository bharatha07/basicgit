global class AggregateResultIterable implements Iterable<AggregateResult>{ 
    
    private DateTime startDateTime;
    private DateTime endDateTime;
    
    public AggregateResultIterable(DateTime startDateTime, DateTime endDateTime) {
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
    }
    
    global Iterator<AggregateResult> Iterator(){ 
        return new AggregateResultIterator(startDateTime, endDateTime); 
    } 
}