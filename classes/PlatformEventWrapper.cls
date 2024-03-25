public class PlatformEventWrapper{
    public class FacilityKitUpdateEvent{
        public String FacilityId;   
     }
    
    public class AXOpportunityPrimaryEvent{
        public String AxContactId;  
        public String AxOpportunityId;  
     }
    
    public class OpportunityContactBillToUpdate{
        public String AccountID;    
        public String OpportunityID;    
     }
     
    public class AxCustomerUpdateEvent{
        public String AxConsumerId;    
           
     }
     public class SendOpportunityStoredToAXEvent{
        public String AxOpportunityId;    
           
     }
     public class SendOpportunityEnrolledToAXEvent{
        public String AxOpportunityId;    
           
     }
     public class SendOpportunityClosedToAXEvent{
        public String AxOpportunityId;    
           
     }
    public class sendFacilityKitContact{
        public String axFacilityId;
    }
    public class sencABOEvent{
        public String axOrderId;
    }
    public class sendIDMClosedCase{
        public String sfdcCaseId;
    }
    public class sendAssetComponentID{
        public String id;
    }
    public class sendAssetID{
        public String id;
    }
}