@isTest(SeeAllData=true) 
private class  SSOTester{   
    
    private static testMethod void testSearch() {
 
        try {
         
            Apex_UserInfo.saveCurrUserSSOInfo('agentid=4456','pwd=45466','extension=4545887');
            Apex_UserInfo.getCurrUserSSOInfo();
   
        } finally {
           
        }
    }
}