@isTest
public class KitsInfoTest {
@isTest static void KitsInfoTestMethod(){
    List<Account> accLstFac = TestDataFactory.createFacilityAccounts();
      List<Account> accLstPro = TestDataFactory.createProviderAccounts();
    Test.startTest();
    kitsInfo.orderKits(accLstFac[0].id, 1);
    kitsInfo.getKitList(accLstFac[0].id);
    Test.stopTest();
}
}