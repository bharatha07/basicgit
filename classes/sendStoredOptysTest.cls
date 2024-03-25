/******************************************************************************************************************************
*Component Name: sendStoredOptysTest
*Created Date :1/18/2021
*Description : Test Class for sendStoredOptys
*Created By : 
*******************************************************************************************************************************/
@isTest
public class sendStoredOptysTest {

    @isTest static void sendStoredOptysTestMet(){
        List<CBR_Message_Event__e> cbrEvtList = new List<CBR_Message_Event__e>();
        List<sendStoredOptys.msgInfo> msg= new  List<sendStoredOptys.msgInfo>();
        sendStoredOptys.msgInfo msg1= new sendStoredOptys.msgInfo();
        msg1.msgEventType='AX Opportunity Primary Event';
        msg1.payload='test';
        msg1.msgId='a4T0r0000007TB4EAM';
        msg.add(msg1);
        test.startTest();
        sendStoredOptys.sendStoredOpty(msg);
        test.stopTest();
        
    }
    
}