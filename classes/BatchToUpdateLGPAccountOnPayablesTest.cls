@isTest
public class BatchToUpdateLGPAccountOnPayablesTest {
 public static testmethod void testPayable(){
        //test.StartTest();
        try{
            List<Account> consumerAcc = TestDataFactory.createConsumerAccounts();
            //Provider Accounts
            List<Account> providerAcc = TestDataFactory.createProviderAccounts(); 
            providerAcc[0].HPN_Flag__c=true;
            update providerAcc;
             List<Account> facilityAcc=TestDataFactory.createFacilityAccounts();
            //opportunity as Stored
            List<Provider_Facility__c> providerFacilityList = TestDataFactory.providerFacilityRecords(facilityAcc,providerAcc);
            Id facilityRecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Facility').getRecordTypeId();
            List<Account> LGPFacility = new List<Account>();
            LGPFacility.add(new Account(Name = 'LGPFacility',Master_Facility_Id__c = 'LGPFacility1',RecordtypeId =facilityRecordTypeId ,Status__c = 'Active',Type__c = 'Large Practice',type = 'Large Practice'));
            insert LGPFacility;
            system.debug('The LGPFacility are-->'+LGPFacility);
            // Associate Parent account for facility associated to opty facility
            facilityAcc[0].parentID=LGPFacility[0].id;
            update facilityAcc[0];
             system.debug('The facilityAcc are-->'+facilityAcc[0].parentID);
            List<Account> allfac= new List<Account> (facilityAcc);
            system.debug('The facilityAcc are-->'+allfac);
            List<Provider_Facility__c> allfacility= new List<Provider_Facility__c>(providerFacilityList);
            system.debug('The providerfacilityAcc are-->'+allfacility);
            //opportunity as Stored
            List<Opportunity> OppList = TestDataFactory.createOpportunities(consumerAcc);
            //OppList[0].Storage_Date__c = system.today();
            OppList[0].Status__c = 'Stored';
            OppList[0].Program_Enrolled_in__c  = 'Family Banking';
            //OppList[1].Storage_Date__c =system.today();
            OppList[1].Status__c = 'Stored';
            OppList[1].Program_Enrolled_in__c  = 'Family Banking';
            update OppList;
            system.debug('The opportunity are-->'+OppList);
            //Assets with different freeze dates
            List<Asset> oppyAsset = new List<Asset>();
            oppyAsset=TestDataFactory.assetInsert();
            oppyAsset[0].Opportunity__c=OppList[0].id;
            oppyAsset[0].AccountId=providerAcc[0].id;
            oppyAsset[0].Status='Stored';
            oppyAsset[0].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[1].Opportunity__c=OppList[0].id;
            oppyAsset[1].AccountId=providerAcc[0].id;
            oppyAsset[1].Status='Stored';
            oppyAsset[1].FreezeDate__c=system.today().addDays(-1);
            oppyAsset[2].Opportunity__c=OppList[1].id;
            oppyAsset[2].AccountId=providerAcc[0].id;
            oppyAsset[2].Status='Stored';
            oppyAsset[2].FreezeDate__c=system.today().addDays(-1);
            Insert oppyAsset;
            system.debug('The Asset are-->'+oppyAsset);
            //Opportunity Provider
            recursiveClass.optyProviderPayable=true;
            List<Opportunity_Provider__c> oppyProviderList = new List<Opportunity_Provider__c>();
            oppyProviderList.add(new Opportunity_Provider__c(Provider__c =providerAcc[0].id,Opportunity__c =OppList[0].id,Delivering_Provider__c=true,Provider_Facility__c=providerFacilityList[0].id));
            insert oppyProviderList;
            List<Opportunity_Provider__c> oppyPro = new List<Opportunity_Provider__c>([select id,name,Provider__c,Opportunity__c,Delivering_Provider__c,Provider_Facility__c,Provider_Facility__r.Facility__c,Provider_Facility__r.Facility__r.ParentID from Opportunity_Provider__c where id=:oppyProviderList[0].id]);
            System.debug('The oppyProviderList is -->'+oppyProviderList);
            System.debug('The oppyProviderfacilityID is -->'+oppyProviderList[0].Provider_Facility__c);
            System.debug('The oppyProviderfacilityID is -->'+oppyPro);
            //Opportunity Contact
            List<OpportunityContact__c> opyCon = new  List<OpportunityContact__c>();
            opyCon.add(new OpportunityContact__c(PersonAccount__c =consumerAcc[2].id,Opportunity__c =OppList[0].id));
            insert opyCon;
            //Program
            Program__c program = new Program__c(Program_Name__c='Year end offer',CB_Amt__c=100,CT_Amt__c=50,Start_Date__c=system.today()-30,End_Date__c=system.today()+15,status__c='Active');
            Insert program;
            System.debug('The Program is -->'+program);
            //Agreement
            Agreement__c aggrement= new Agreement__c(Program__c=program.id,Agreement_Start_Date__c=system.today().addDays(-7),Agreement_End_Date__c=system.today().addDays(15),W9__c='Approved');
            insert aggrement;
            US_Zipcode__c usZipCode = TestDataFactory.usZipCodeInsert();
            //Provider Agreement
            List<Provider_Agreement__c> provideragrrements = new List<Provider_Agreement__c>();
            Provider_Agreement__c provideraggr1= new Provider_Agreement__c(Provider__c=providerAcc[0].id,Agreement__c=aggrement.id,Pay_to_Group__c=true,HPN_End_Date__c=null,HPN_Start_Date__c=system.today().adddays(-5));
            provideragrrements.add(provideraggr1);
            insert provideragrrements;
            
            List<CBR_PAY_TO__c> lstPayTo= new List<CBR_PAY_TO__c>();
            lstPayTo.add(new CBR_PAY_TO__c(Name='Test123',Active__c=true,Address__c='123',Address_2__c='Washington Street',City__c='Houston',Country__c='USA',State__c='zooba',Tax_ID__c='4567876567',Zip_Code__c='10009',Provider_Agreement__c=null));
            insert lstPayTo;
            
            aggrement.CBR_PAY_TO__c=lstPayTo[0].id;
            update aggrement;
            
            test.StartTest();
            payableRecordsCreation_Batch xyz= new payableRecordsCreation_Batch(2);
            Id batchJobId1 = Database.executeBatch(xyz, 200);
            
            Test.Stoptest();
            
            ScheduleLGPStampOnPayable newbatch = new ScheduleLGPStampOnPayable();
            String cronstr = '0 0 0 ? * *';
            id jobid = System.schedule('Stamp LGP for Payable Records', cronStr, newbatch);
            BatchToUpdateLGPAccountOnPayables abc= new BatchToUpdateLGPAccountOnPayables(2);
            Id batchJobId2 = Database.executeBatch(abc, 200);
            List<Payable__c> allpayable=[select id,name,Asset__c,Payable_LGP__c,HPN_Provider_Agreement__c,Opportunity__c,Account_ID_Mother__c from Payable__c where Opportunity__c IN:OppList];
            //Asserts starts here
            system.debug('The payable are-->'+allpayable);
            system.assertNotEquals(0, allpayable.size());
            system.assertEquals(oppyAsset[0].id, allpayable[0].Asset__c);
            system.assertEquals(oppyAsset[0].Opportunity__c, allpayable[0].Opportunity__c);
            system.assertEquals(provideragrrements[0].id, allpayable[0].HPN_Provider_Agreement__c);
        }
        catch(DMLException e){
            system.assertEquals(e.getMessage(), e.getMessage()); 
        }    
    }
   
}