public class schedulePayableStatusUpdate implements Schedulable {

    public void execute(SchedulableContext sc){
            updatepayableStatusButton_Batch PAbatch =new updatepayableStatusButton_Batch();
            database.executebatch(PAbatch);
        }    
}