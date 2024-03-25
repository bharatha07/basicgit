public class cbr_m_CustomLookupController {
@AuraEnabled
    public static list<Account> CustomLooup(String Name,String RecordTypeID){
        list<account> accLst;
        if(String.isNotBlank(Name)){
           string nameSearch='%'+Name+'%'; 
            accLst =[select id,name,recordtype.name from account where name like : nameSearch and recordtypeId=:RecordTypeID LIMIT 10];
        }
        return accLst;
    }
}