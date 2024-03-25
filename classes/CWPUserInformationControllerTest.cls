/**************************************************************************************************************************************
* ComponentName : CWPUserInformationControllerTest
* CreatedBy : TEKsystems
* Description : Test class for CWPUserInformationController
***************************************************************************************************************************************/
@isTest
public class CWPUserInformationControllerTest{
    @TestSetup
    public static void dataSetup(){
        Id consumerRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Account acc = new Account();
        acc.RecordtypeId = consumerRecordTypeId;
        acc.FirstName = 'TestFN';
        acc.LastName = 'TestLN';
        acc.Due_Date__pc = system.today();
        acc.Active__pc = true;
        acc.PersonBirthDate = system.today().addDays(-2);
        
        
        insert acc;
        
        Opportunity oppObj1 = New Opportunity();
        oppObj1.AccountId = acc.Id;
        oppObj1.name = 'Test1';
        oppObj1.Requested_Shipping_Method__c = 'Courier';
        oppObj1.closeDate = system.today();
        oppobj1.Due_Date__c =  system.today().addDays(80);
        oppobj1.StageName = 'Ask for sale';
        oppobj1.Signature_Required__c = true;
        oppobj1.Shipping_Method__c = 'Priority Overnight';
        oppobj1.Saturday_Delivery__c = true;
        oppobj1.of_Babies__c = 'Twins';
        oppobj1.Requested_Shipping_Date__c = null;
        Insert oppObj1;
        
        
    } 
    @isTest
    public static void unitTest1(){
        Test.StartTest();
        Opportunity opp = [select id,Shipping_Method__c,Requested_Shipping_Method__c from opportunity];
        system.debug('opp shipping method'+opp.Shipping_Method__c);
        system.debug('opp Requested_Shipping_Method__c '+opp.Requested_Shipping_Method__c);
        OpportunityContact__C oppContact = [Select id,Opportunity__c,PersonAccount__c,Role__c,Primary__c from OpportunityContact__C];
        Account accRec = [Select Id,User_Name__pc,CWP_Activation_Date__pc,CWP_Last_Login_Date__pc,Temporary_Password__pc,
                       Active__pc,SCSS_Contact_Id__pc From Account Limit 1];
        PageReference pageRef = Page.CWPUserInformationPage;
        pageRef.getParameters().put('id', String.valueOf(accRec.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(accRec);
        CWPUserInformationController cwpController = new CWPUserInformationController(sc);
        system.assertEquals(true,cwpController.inactiveLoginButton);
        cwpController.activateLoginButton();
        system.assertEquals(true,cwpController.inactiveLoginButton);
        system.assertEquals(false,cwpController.loginWhenActive);
        system.assertEquals(false,cwpController.activeLoginButton);

        cwpController.inactiveLoginBtn();
        system.assertEquals(false,cwpController.inactiveLoginButton);
        system.assertEquals(false,cwpController.loginWhenActive);
        system.assertEquals(true,cwpController.activeLoginButton);

        //cwpController.generateRandomPasswd();
        cwpController.updateCognitoInfo();
        Account accUpdated = [Select id,Temporary_Password__pc,CWP_Temporary_Password_Expiration__pc from Account];
        //system.assertEquals(Integer.valueOf(System.Label.passwordLength),accUpdated.Temporary_Password__pc.length());
        //system.assertEquals(accUpdated.CWP_Temporary_Password_Expiration__pc,system.today().addDays(30));
        Test.StopTest();
    }
     @isTest
    public static void unitTest2(){
        Test.StartTest();
        Opportunity opp = [select id,Shipping_Method__c,Requested_Shipping_Method__c,status__c from opportunity];
        opp.status__c = 'Enrolled';
        update opp;
        system.debug('opp shipping method'+opp.Shipping_Method__c);
        system.debug('opp Requested_Shipping_Method__c '+opp.Requested_Shipping_Method__c);
       OpportunityContact__C oppContact = [Select id,Opportunity__c,PersonAccount__c,Role__c,Primary__c from OpportunityContact__C];
        Account accRec = [Select Id,User_Name__pc,CWP_Activation_Date__pc,CWP_Last_Login_Date__pc,Temporary_Password__pc,
                       Active__pc,SCSS_Contact_Id__pc From Account Limit 1];
        PageReference pageRef = Page.CWPUserInformationPage;
        pageRef.getParameters().put('id', String.valueOf(accRec.Id));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(accRec);
        CWPUserInformationController cwpController = new CWPUserInformationController(sc);
        system.assertEquals(true,cwpController.loginButton);
        cwpController.getCWPUserInformation();
        cwpController.activateLoginButton();
        system.assertEquals(true,cwpController.inactiveLoginButton);
        system.assertEquals(true,cwpController.loginWhenActive);
        system.assertEquals(false,cwpController.activeLoginButton);
        Test.StopTest();
    }
    @isTest
    public static void unitTest3(){
        Test.StartTest();
        Opportunity opp = [select id,Shipping_Method__c,Requested_Shipping_Method__c,status__c from opportunity];
        opp.status__c = 'Enrolled';
        update opp;
        system.debug('opp shipping method'+opp.Shipping_Method__c);
        system.debug('opp Requested_Shipping_Method__c '+opp.Requested_Shipping_Method__c);
        OpportunityContact__C oppContact = [Select id,Opportunity__c,PersonAccount__c,Role__c,Primary__c from OpportunityContact__C];
        Account accRec = [Select Id,User_Name__pc,CWP_Activation_Date__pc,CWP_Last_Login_Date__pc,Temporary_Password__pc,
                       Active__pc,SCSS_Contact_Id__pc From Account Limit 1];
        accRec.Active__pc = false;
        update accRec;
        PageReference pageRef = Page.CWPUserInformationPage;
        pageRef.getParameters().put('id', String.valueOf(accRec.Id));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(accRec);
        CWPUserInformationController cwpController = new CWPUserInformationController(sc);
        system.assertEquals(true,cwpController.activeLoginButton);
        Test.StopTest();
    } 
}