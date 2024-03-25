public class ScheduleProviderAgreement implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
        ProviderAgreement_Batch PAbatch =new ProviderAgreement_Batch();
        database.executebatch(PAbatch);
        
    }
    
}