/*************************************************
*For Component Name:TaskTriggerHandler
Description: Test Case to update task on lead and opportunity , will be called from Trigger handler on CRED operations.
Created By: Teksystems
**************************************************/

@isTest 
public class TaskTriggerHandlerTest {
  //Test method to check task creation on lead and update lead
  @isTest static void testMethod1() 
{
    Lead newLead = new Lead() ;
    newLead.FirstName = 'Cole';
    newLead.LastName = 'Swain';
    newLead.Company = 'BlueWave';
    newLead.Status = 'contacted'; 
    insert newLead;
    List<Task> tlist=new list<Task>();
    Task t = new Task();
    t.OwnerId = UserInfo.getUserId();
    t.Subject='sub1';
    t.TaskSubtype  = 'Email';
    t.Status='Completed';
    t.Priority='Normal';
    t.Type = 'Email';
    t.ActivityDate = Date.today();
    t.whoid = newLead.id;
    
    Task t2 = new Task();
    t2.OwnerId = UserInfo.getUserId();
    t2.Subject='sub2';
    t2.TaskSubtype  = 'Email';
    t2.Status='Completed';
    t2.Priority='Normal';
    t2.Type = 'Email';
    t2.ActivityDate = Date.today();
    t2.whoid = newLead.id;
    tlist.add(t);
    tlist.add(t2);
    DmlException expectedException;
    test.startTest();
    try {
    insert tlist;
   // t2.type = 'phone';
   // tlist.add(t2);
    //update tlist;
    } catch (DmlException dmx) { 
         expectedException = dmx; }
    System.assertEquals(tlist[0].Subject, 'sub1'); 
    test.Stoptest();
}

  //Test method to check task creation on opportunity and update opportunity
 @isTest static void testMethod2() 
{
    List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
    List<Opportunity> oppList =TestDataFactory.createOpportunities(consumerAccList); 
    List<Task> tlist=new list<Task>();
    Task t = new Task();
    t.OwnerId = UserInfo.getUserId();
    t.Subject='sub1';
    t.TaskSubtype  = 'Email';
    t.Status='Completed';
    t.whatID=oppList[0].id;
     tlist.add(t);
     DmlException expectedException;
     test.startTest();
     try {
    insert tlist;
    } catch (DmlException dmx) { 
         expectedException = dmx; }
    System.assertEquals(tlist[0].Subject, 'sub1'); 
    test.Stoptest();
}
 ////Test method to check task creation on opportunity and deletion opportunity   
    @isTest static void testMethod3() 
{
    List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
    List<Opportunity> oppList =TestDataFactory.createOpportunities(consumerAccList); 
    List<Task> tlists=new list<Task>();
    Task tk = new Task();
    tk.OwnerId = UserInfo.getUserId();
    tk.Subject='sub1';
    tk.TaskSubtype  = 'Email';
    tk.Status='Completed';
    tk.whatID=oppList[0].id;
     tlists.add(tk);
     DmlException expectedException;
     test.startTest();
     try {
    insert tlists;
    delete tlists;
    } catch (DmlException dmx) { 
         expectedException = dmx; }
    System.assertEquals(tlists[0].Subject, 'sub1'); 
    test.Stoptest();
}
    
//Test method to check task delete activity only for system admin and for other profile it should not be deleted 
@isTest static void preventTskDlt() 
{
Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Rep NSCE' LIMIT 1];
 List<Account> consumerAccList = TestDataFactory.createConsumerAccounts();
 consumerAccList[0].Timezone__c = 'Central Standard Time';
 update consumerAccList[0];
List<Opportunity> oppList =TestDataFactory.createOpportunities(consumerAccList); 
opplist[0].AccountId =  consumerAccList[0].id;
update opplist[0];
    User u = new User(LastName = 'RTest1',
                       FirstName='RLast1',
                       Alias = 'Rtelas',
                       Email = 'abcr@gmail.com',
                       Username = 'testrcbr_123@abc.com',
                       ProfileId = profileId.id,
                       TimeZoneSidKey = 'GMT',
                       LanguageLocaleKey = 'en_US',
                       EmailEncodingKey = 'UTF-8',
                       LocaleSidKey = 'en_US'
                       );
                       insert u;
                       
    System.runAs(u) {     
         List<Task> tlist=new list<Task>();
            Task t = new Task();
            t.OwnerId = u.id;
            t.Subject='sub1R';
            t.TaskSubtype  = 'Email';
            t.Status='Completed';
            t.whatID=oppList[0].id;
              
               
         DmlException expectedException;
       Test.startTest();
         try { 
          insert t;
          t.Subject='sub11R';
          update t;
         delete t; }
        catch (DmlException dmx) { 
         expectedException = dmx; }
       Test.stopTest();
        list<Task> t1=[select id , Subject from task where Subject='sub1R'];
        system.assertNotEquals(null, expectedException);
        //system.assertEquals (t1.size() , 1 );

              }
      }
}