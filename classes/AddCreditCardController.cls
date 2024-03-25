public class AddCreditCardController {
	@AuraEnabled
    public static Account getAccountDetail(String accId){
        String fieldList = getFieldList();
        
        String qry = 'Select '+fieldList+' From Account Where Id=:accId';
        List<Account> accList = new List<Account>();
        accList = database.query(qry);
        if(accList.size()>0){
            return accList[0];
        }else{
            return null;
        }
    }
    public static String getFieldList(){
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String apiNames = '';
        for(string apiName : r.fields.getMap().keySet()){
            apiNames += apiName+',';
        }
        apiNames = apiNames.removeEnd(',');
        return apiNames;
    }
}