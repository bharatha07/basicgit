@isTest() 
public class CordBloodTester {
     private static testMethod void testCustomization() {
        system.debug('**testColor Start test');     
	 	try {
            
            //create contactg
            Account tmpAccount = new Account();
         	tmpAccount.PersonDoNotCall = true;
            tmpAccount.LastName = 'test';
            tmpAccount.FirstName = 'test';
         	insert tmpAccount;
         
         	String AccountId = tmpAccount.Id;
            system.debug('**createAccount  Id=' + AccountId);
            
            String run1 = CordBloodValidateDial.blockRequest('account', AccountId, 'PersonDoNotCall');
            system.debug('**testColor  run1:' + run1);
            
            String run2 = CordBloodValidateDial.blockRequest('account', '222222222222', 'PersonDoNotCall');
            system.debug('**testColor  run2:' + run2);
         
     	}catch(Exception e){
            system.debug('Exception: '+ e.getStackTraceString());            
            system.debug('Exception: '+ e.getMessage());     
        }
     }
}