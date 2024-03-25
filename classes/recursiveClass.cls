/**
 * @File Name          : recursiveClass.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Created By   : Tejaswini
 * @Last Modified On   : 6/22/2020, 5:08:09 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    6/21/2020         Tejaswini     Initial Version
**/
public class recursiveClass {
    public static Boolean conUpdateFromCI = false;//This boolean is used to avoid recursion when contact is updated when a new campaignInfluence record is created
    public static Boolean createCampaignInfluence = false;//This flag is set to true if new opty is created from new button on Account then we set this flag to true so after insert trigger of opty contact create campaign influence
    public static Boolean emailUpdateToPFevent = false;//This flag is used to avoid recurssion when platform event is publish for email changes.
    public static Boolean accOwnerUpdate = false; //This is created for SFDC - 1045
    public static Boolean accDupEmail = false; //This is created for SFDC - 1081
    public static Boolean createQuoteonOpty = false; //This is created for SFDC - 1065
    public static Boolean cusUpdatePfevent = false; //This is created for SFDC - 1088
    public static Boolean facConPfevent = false; //This is created for SFDC - 1235
    public static Boolean axCus2Pfevent= false; //This is created for SFDC - 1200
    public static Boolean optyConPfevent = false; //This is created for SFDC - 1236 and 1196
    public static Boolean optystoredPfevent = false; //This is created for SFDC - 1199
    public static Boolean optyenrolledPfevent = false; //This is created for SFDC - 1152
     public static Boolean optyEnrolledOLE = false;
     public static Boolean optyClosedToAX = false;//This is created for SFDC - 1366
     public static Boolean OleEnrolled = false;//This boolean is used for 1317 story
     public static boolean oppPrimaryChangeABO = false;//this boolean created because when primary is changed multiple events are created for same record
    public static boolean optyProviderPayable = false;//This is created for SFDC-1537
     public static Boolean optySendFaxEmail=false;//This is created for SFDC-2088
    public static Boolean optyProviderSendFaxEmail=false;//This is created for SFDC-2134
    
   
}