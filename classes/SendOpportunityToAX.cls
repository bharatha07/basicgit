/******************************************************************************************************************************
*Component Name: SendOpportunityToAX
*Created Date : 16-DEC-2020
* @story - SFDC-1372
*Description : To send the opty details to AX.
*Created By : 
*******************************************************************************************************************************/
public class SendOpportunityToAX {

    public String oppId {get;set;}
    public SendOpportunityToAX(ApexPages.StandardController controller){
        
        oppId = ApexPages.currentPage().getParameters().get('id');
        
    }
    
    public PageReference sendOptyToAX(){
        list<Opportunity> oppStat = [SELECT id,Status__c From Opportunity where id =:oppId limit 1];
        if(oppStat[0].Status__c == 'Enrolled'){
            string url =label.Send_Opty_to_AX_Enrolled+oppid;
            PageReference pageRefCong = new PageReference(url);
            pageRefCong.setRedirect(true);
            return pageRefCong;
        }
        else if(oppStat[0].Status__c == 'Stored'){
            string url =label.Send_Opty_to_AX_Stored+oppid;
            PageReference pageRefCong = new PageReference(url);
            pageRefCong.setRedirect(true);
            return pageRefCong;
        }
        else if(oppStat[0].Status__c == 'Closed_Lost'){
            string url =label.Send_Opty_to_AX_Closed+oppid;
            PageReference pageRefCong = new PageReference(url);
            pageRefCong.setRedirect(true);
            return pageRefCong;
        }
        else{
            
            PageReference pageRefCong = new PageReference('/'+oppId);
            pageRefCong.setRedirect(true);
            return pageRefCong;
        }
        
    }
}