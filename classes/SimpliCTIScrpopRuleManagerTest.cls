@isTest() 
public class SimpliCTIScrpopRuleManagerTest {
private static testMethod void testSearch() {
        system.debug('**testMethod Start test');
        // ANI to search on
        string ActiveDnis = '2222';
        string inActiveDnis = '3333';
       string aMatch = '444555';
        string lMatch = '555666';
        string cMatch = '666777';
        string alMatch = '777888';
        string acMatch = '888999';
        string alcMatch = '111222';
   
        try {

            //-------------- S1 string aMatch = '444555';
            //create Account
            Account aAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            aAccount.Phone = aMatch;
            aAccount.Name = 'test';
            insert aAccount;
            String aAccountId = aAccount.Id;
            system.debug('**createAccount  Id=' + aAccountId);
            
            Account atempAccount = [SELECT ID FROM Account WHERE Id = :aAccountId];
            if(atempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo atempAccount = null');
            
            }
            system.debug('*********IsItATaskWithInfo 1');
            //--------------S3 string lMatch = '555666';
            //create Lead
            Lead lLead = new Lead();
            lLead.FirstName = 'testLead';
            lLead.LastName = 'testLead';
            lLead.Status = 'In Progress';
            lLead.Phone = lMatch;
            lLead.Company = 'test';
            insert lLead;
            String lLeadId = lLead.Id;
            system.debug('**createLead  Id=' + lLeadId);
            
            
            
            Lead ltempLead = [SELECT ID FROM Lead WHERE Id = :lLeadId];
            if(ltempLead == null)
            {
                system.debug('*********IsItATaskWithInfo ltempLead = null');
            
            }
            system.debug('*********IsItATaskWithInfo 2');
            //--------------S5 string cMatch = '666777';
            //create contact
            Contact cContact = new Contact();
            cContact.FirstName = 'test';
            cContact.LastName = 'test';
            cContact.Phone = cMatch;
            insert cContact;
            String cContactId = cContact.Id;
            system.debug('**createContact  Id=' + cContactId);
            
            
            
            Contact ctempConcat = [SELECT ID FROM Contact WHERE Id = :cContactId];
            if(ctempConcat == null)
            {
                system.debug('*********IsItATaskWithInfo ctempContact = null');
            
            }
            system.debug('*********IsItATaskWithInfo 3');
            
            //--------------S2 string alMatch = '777888';
            //create Account
            Account alAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            alAccount.Phone = alMatch;
            alAccount.Name = 'test';
            insert alAccount;
            String alAccountId = alAccount.Id;
            system.debug('**createAccount  Id=' + alAccountId);
            
            Account altempAccount = [SELECT ID FROM Account WHERE Id = :alAccountId];
            if(altempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo altempAccount = null');
            
            }
            
            //create Account
            Account al2Account = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            al2Account.Phone = alMatch;
            al2Account.Name = 'test';
            insert al2Account;
            String al2AccountId = al2Account.Id;
            system.debug('**createAccount  Id=' + al2AccountId);
            
            Account al2tempAccount = [SELECT ID FROM Account WHERE Id = :al2AccountId];
            if(altempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo al2tempAccount = null');
            
            }
            
            //create Lead
            Lead alLead = new Lead();
            alLead.FirstName = 'testLead';
            alLead.LastName = 'testLead';
            alLead.Status = 'In Progress';
            alLead.Phone = alMatch;
            alLead.Company = 'test';
            insert alLead;
            String alLeadId = alLead.Id;
            system.debug('**createLead  Id=' + alLeadId);
            
            Lead altempLead = [SELECT ID FROM Lead WHERE Id = :alLeadId];
            if(altempLead == null)
            {
                system.debug('*********IsItATaskWithInfo altempLead = null');
            
            }
            
            Contact alContact = new Contact();
            alContact.FirstName = 'test2';
            alContact.LastName = 'test2';
            alContact.Phone = alMatch;
            insert alContact;
            String alContactId = alContact.Id;
            system.debug('**createContact  Id=' + alContactId);
            
            Contact altempConcat = [SELECT ID FROM Contact WHERE Id = :alContactId];
            if(altempConcat == null)
            {
                system.debug('*********IsItATaskWithInfo altempConcat = null');
            
            }
            
            //--------------S4 string acMatch = '888999';
            //create Lead
            Lead aclLead = new Lead();
            aclLead.FirstName = 'testLead';
            aclLead.LastName = 'testLead';
            aclLead.Status = 'In Progress';
            aclLead.Phone = acMatch;
            aclLead.Company = 'test';
            insert aclLead;
            String aclLeadId = aclLead.Id;
            system.debug('**createLead  Id=' + aclLeadId);
            
            Lead acltempLead = [SELECT ID FROM Lead WHERE Id = :aclLeadId];
            if(acltempLead == null)
            {
                system.debug('*********IsItATaskWithInfo acltempLead = null');
            
            }
            
            //create Lead
            Lead acl2Lead = new Lead();
            acl2Lead.FirstName = 'testLead';
            acl2Lead.LastName = 'testLead';
            acl2Lead.Status = 'In Progress';
            acl2Lead.Phone = acMatch;
            acl2Lead.Company = 'test';
            insert acl2Lead;
            String acl2LeadId = acl2Lead.Id;
            system.debug('**createLead  Id=' + acl2LeadId);
            
            Lead acl2tempLead = [SELECT ID FROM Lead WHERE Id = :acl2LeadId];
            if(acl2tempLead == null)
            {
                system.debug('*********IsItATaskWithInfo acl2tempLead = null');
            
            }
            
            Contact aclContact = new Contact();
            aclContact.FirstName = 'test2';
            aclContact.LastName = 'test2';
            aclContact.Phone = acMatch;
            insert aclContact;
            String aclContactId = aclContact.Id;
            system.debug('**createContact  Id=' + aclContactId);
            
            Contact acltempConcat = [SELECT ID FROM Contact WHERE Id = :aclContactId];
            if(acltempConcat == null)
            {
                system.debug('*********IsItATaskWithInfo acltempConcat = null');
            
            }
            
            //--------------S6 string alcMatch = '111222'
            
            //create contact
            Contact a11cContact = new Contact();
            a11cContact.FirstName = 'test';
            a11cContact.LastName = 'test';
            a11cContact.Phone = alcMatch;
            insert a11cContact;
            String a11cContactId = a11cContact.Id;
            system.debug('**createContact  Id=' + a11cContactId);
            
            Contact a11ctempConcat = [SELECT ID FROM Contact WHERE Id = :a11cContactId];
            if(a11ctempConcat == null)
            {
                system.debug('*********IsItATaskWithInfo 11ctempContact = null');
            
            }
            
            //create contact
            Contact a22cContact = new Contact();
            a22cContact.FirstName = 'test';
            a22cContact.LastName = 'test';
            a22cContact.Phone = alcMatch;
            insert a22cContact;
            String a22cContactId = a22cContact.Id;
            system.debug('**createContact  Id=' + a22cContactId);
            
            Contact a22ctempConcat = [SELECT ID FROM Contact WHERE Id = :a22cContactId];
            if(a22ctempConcat == null)
            {
                system.debug('*********IsItATaskWithInfo a22ctempContact = null');
            
            }
            
            //---------------------------------------------------------------------
            
          
            //create Active Campaign
            Campaign tCampaign= new Campaign();
            tCampaign.IsActive = true;
            tCampaign.Name = 'test';
            insert tCampaign;
            String CampaignId = tCampaign.Id;
            system.debug('**createCampaign Id=' + CampaignId);
            
            Campaign tempCampaign = [SELECT ID FROM Campaign WHERE Id = :CampaignId];
            if(tempCampaign == null)
            {
                system.debug('*********IsItATaskWithInfo tempCampaign= null');
            
            }
            system.debug('*********IsItATaskWithInfo 7');
            //create InActive Campaign
            Campaign tCampaign2= new Campaign();
            tCampaign2.IsActive = true;
            tCampaign2.Name = 'test';
            insert tCampaign2;
            String CampaignId2 = tCampaign2.Id;
            system.debug('**createCampaign Id=' + CampaignId2);
            
            Campaign tempCampaign2 = [SELECT ID FROM Campaign WHERE Id = :CampaignId2];
            if(tempCampaign2 == null)
            {
                system.debug('*********IsItATaskWithInfo tempCampaign2= null');
            
            }
            
             PageReference pageRef = Page.AdvancedScreenPopClient;
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('params', 'meta_original_ani=' + alcMatch);
            ApexPages.currentPage().getParameters().put('params', 'meta_original_ani=12341234');
            
            SimpliCTIScrpopRuleManager controller = new SimpliCTIScrpopRuleManager();
            controller.initSearch();
            
            
            Id [] fixedSearchResults;
      
            fixedSearchResults = new Id[]{aAccountId,CampaignId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run1 = SimpliCTIScrpopRuleManager.search('params=meta_ani=' + aMatch);
            system.debug('**testMethod  run1:' + run1);
            
            
            fixedSearchResults = new Id[]{lLeadId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run2 = SimpliCTIScrpopRuleManager.search('params=meta_original_ani=' + lMatch);
            system.debug('**testMethod run2' + run2);
            
            
            fixedSearchResults = new Id[]{cContactId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run3 = SimpliCTIScrpopRuleManager.search('params=meta_ani=' + cMatch);
            system.debug('**testMethod run3' + run3);
            
            
            fixedSearchResults = new Id[]{aclLeadId,acl2LeadId,aclContactId};
            Test.setFixedSearchResults(fixedSearchResults);
            String run4 = SimpliCTIScrpopRuleManager.search('params=meta_ani=' + acMatch);
            system.debug('**testMethod run4' + run4);

        } 
        catch(Exception e)
        {
          system.debug('**testMethod Exception caught:' + e.getMessage());
        }
        finally {

        }
    }
}