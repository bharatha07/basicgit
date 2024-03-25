/**
 * @File Name          : oppContactRoleCreatebatch_Schedule.cls
 * @Description        : Scheduler to execute oppContactRoleCreatebatch class
 * @Author             : Tejaswini(TEKsystems)
 * @Created date       : 6/3/2020
**/
global class oppContactRoleCreatebatch_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        oppContactRoleCreatebatch batch = new oppContactRoleCreatebatch(false,true);
        Database.executeBatch(batch);
    }
}