public class profilesToExcludeInNewContactButton {
    @AuraEnabled
    public static string getProfileInfo(){
        try{
            String profileId = UserInfo.getProfileId();
            return [SELECT Id, Name FROM Profile WHERE Id =:profileId limit 1]?.Name;
            //return profile.Name;
        }
        catch(Exception e){throw new AuraHandledException(e.getMessage());}
    }
}