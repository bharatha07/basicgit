/**************************************************************************************************************************************
*Component Name : createPayableController 
*Developed By   : TEKsystems
*Description    : This class is controller for "Omit Payable" QuickAction button on Asset record page.
On click of this button,it will validate the asset record for below condtions, If all conditions
are satified then creates a payable record.
1) Intitially check if Asset already have a payable, Inorder to avoid duplicate payables for one Asset.
2) whether Asset is stored or not by Status Field.
3) Opportunity is not marked as NPP.
4) One active Delivering Provider should be availble on OpportunityProvider related to Asset.
5) Provider HPN flag Should be "Active"
*User Story     :  SFDC-1100
**********************************************************************************************************************************/

public class createPayableController {
    
    @auraenabled
    Public static validationWrapper validateRecord(string assetId){
        validationWrapper wrap= new validationWrapper();
        List<Opportunity_Provider__c> oppyProvider= new List<Opportunity_Provider__c>();
        set<id> providerID= new set<id>();
        List<Provider_Agreement__c> provAgrMap= new List<Provider_Agreement__c>();
        List<CBR_PAY_TO__c> activePayTo= new  List<CBR_PAY_TO__c>();
        List<OpportunityContact__c> opyContact = new List<OpportunityContact__c>();
        
        
        //Fetching Asset
        Asset ass= [select id,name,Opportunity__c,Opportunity__r.Adoption_Type__c,FreezeDate__c,Opportunity__r.Status__c,Opportunity__r.Program_Enrolled_in__c,Opportunity_Status__c,AccountId,Account.HPN_Flag__c,Status from Asset where  Opportunity__c!=null and Id=:assetId];
        system.debug('Inside controller asset'+ass);
        
        //Fetching Payable record the Asset
        List<Payable__c> payable=[select id,name,Asset__c,status__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Asset__c!=null and  Asset__r.Id=:assetId and  status__c NOT IN('Void','Omit','Paid') order by createddate DESC];
        System.debug('The payables are -->'+payable);
        //Fetching Opportunity Provider
            oppyProvider = [select id,Opportunity__c,Provider__c,Provider__r.Name,Provider__r.HPN_Flag__c,Delivering_Provider__c from Opportunity_Provider__c where Delivering_Provider__c =true  AND Opportunity__c =:ass.Opportunity__r.id];
            
            opyContact= [select id,name,PersonAccount__r.name,Role__c,Primary__c,Opportunity__r.Account.name from OpportunityContact__c where Role__c='Mother' and Opportunity__c =:ass.Opportunity__r.id];
       
            //Fetching Provider Agreement
            if(!oppyProvider.isEmpty()){
                provAgrMap = new List<Provider_Agreement__c>([select id,Provider__c,Pay_to_Group__c,Agreement__c,Agreement__r.CBR_PAY_TO__c,Agreement__r.Agreement_Start_Date__c,Agreement__r.Agreement_End_Date__c,Agreement__r.Special_Handling__c,Provider__r.Name,Provider__r.HPN_Flag__c,Active_HPNFlag__c from Provider_Agreement__c where  Provider__c =:oppyProvider[0].Provider__c And Active_HPNFlag__c=true]);  
                system.debug('the provideragreement are'+provAgrMap);
                
                //Fetching Active PayTo on Provider Agreement
                if(!provAgrMap.isEmpty()){
                    activePayTo = new List<CBR_PAY_TO__c>([select id,name,Provider_Agreement__c,Active__c,Address__c,Address_2__c,City__c,Country__c,State__c,Tax_ID__c,Zip_Code__c from CBR_PAY_TO__c where Active__c=true and Provider_Agreement__c=:provAgrMap[0].id]);
                    system.debug('The Pay To\'s are-->'+activePayTo);
                }
            }
        
        //Validating record values
        if(!payable.isEmpty() && (payable[0].status__c!='Void' || payable[0].status__c!='Omit' || payable[0].status__c!='Paid')){
            wrap.errorCheck=true;
            wrap.message='Payable record exist for this Asset'; 
            
        }
        else if(ass.Status!='Stored'){
            wrap.errorCheck=true;
            wrap.message= 'Asset is not Stored';
            
        }

        else if(ass.Opportunity__r.Program_Enrolled_in__c.contains('Newborn Possibilities Program')){
            wrap.errorCheck=true;
            wrap.message= 'Opportunity Program is NPP'; 
            
        }
        
        else if(oppyProvider.size()==0){
            wrap.errorCheck=true;
            wrap.message='No Active DeliveryProvider for this Opportunity';
        }
        else if(!oppyProvider[0].Provider__r.HPN_Flag__c){
            wrap.errorCheck=true;
            wrap.message= 'Provider HPN Flag is not Active';    
        }
        else if(provAgrMap.size()==0){
            wrap.errorCheck=true;
            wrap.message= 'No Active ProviderAgreement for the Provider';    
        }
        else if(provAgrMap.size()>0 && provAgrMap[0].Agreement__r.Agreement_Start_Date__c!=null){
            DateTime dT =ass.FreezeDate__c;
            Date freezedate = date.newinstance(dT.year(), dT.month(), dT.day());
            if((provAgrMap[0].Agreement__r.Agreement_End_Date__c==null && provAgrMap[0].Agreement__r.Agreement_Start_Date__c>freezedate) || (provAgrMap[0].Agreement__r.Agreement_End_Date__c!=null && (provAgrMap[0].Agreement__r.Agreement_Start_Date__c>freezedate ||  provAgrMap[0].Agreement__r.Agreement_End_Date__c<freezedate))){
                wrap.errorCheck=true;
                wrap.message= 'Asset FreezeDate not lies within Agreement Start and End Date';  
                
            }
            
            else{
                Payable__c pay= new Payable__c();
                
                pay.Provider_ID__c=oppyProvider[0].Provider__r.id;
                pay.Asset__c=assetId;
                pay.Opportunity__c=ass.Opportunity__r.id;
                pay.HPN_Provider_Agreement__c=provAgrMap[0].id;
                pay.Agreement__c=provAgrMap[0].Agreement__c;
                pay.Status__c=provAgrMap[0].Agreement__r.Special_Handling__c?'Special Handling':'Pending Accounting';
                if(!opyContact.isEmpty()){
                   pay.Account_ID_Mother__c=opyContact[0].PersonAccount__c;
                   pay.Patient_Name__c=ass.Opportunity__r.Adoption_Type__c!='N/A'?'N/A':opyContact[0].PersonAccount__r.name;
                }
                if(provAgrMap[0].Pay_to_Group__c==false){
                    if(activePayTo.size()>0){
                        pay.CBR_PAY_TO__c= activePayTo[0].id;
                    }                
                    else{
                        pay.CBR_PAY_TO__c=null;
                    }   
                }
                else{
                    if(provAgrMap[0].Pay_to_Group__c==true){
                        pay.CBR_PAY_TO__c=provAgrMap[0].Agreement__r.CBR_PAY_TO__c;
                    }
                    else{
                        pay.CBR_PAY_TO__c=null; 
                    }
                }
                
                insert pay;  
                wrap.errorCheck=false;
                wrap.message='Payable Record Created Successfully';
                return wrap;
            }
        }
        return wrap;
    }
    
    Public class validationWrapper{
        @auraenabled public string message;
        @auraenabled public Boolean errorCheck;
        
    }
}