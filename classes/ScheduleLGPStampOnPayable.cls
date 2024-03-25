global class ScheduleLGPStampOnPayable implements Schedulable {

    global void execute(SchedulableContext sc){

            BatchToUpdateLGPAccountOnPayables stampLGP =new BatchToUpdateLGPAccountOnPayables(2);
            database.executebatch(stampLGP);
        }    
}