public class TaskTriggerHandler {
    public static void handleAfterInsert(List<Task> TaskList)
    {
        //handler logic
        Date myDate = date.today();
        Boolean recordUpdated = false;
        List<Id> leadids = new List<Id>();
        List<Id> optyids = new List<Id>();
        List<lead> leadstoupdate = new List<lead>();
        List<lead> leadstoupdate1 = new List<lead>();
        List<Opportunity> Optystoupdate = new List<Opportunity>();
        set<id> tskset=new set<id>();
        set<id> optytask=new set<id>();
        Boolean emailType=false;
        if(Trigger.new!=null){
        for(Task tsk : (List <Task>) Trigger.new){
            leadids.add(tsk.WhoId);
            tskset.add(tsk.id);
            optyids.add(tsk.WhatId);
            optytask.add(tsk.id);
            if(tsk.TaskSubtype=='Email'){
            emailType=true;
            }
        }  
       }
       if(leadids.size()>0){
      system.debug('taskset'+tskset);
        for(Lead ld: [select Id, Name, Total_Email_Outbound__c, Last_Contact_Date__c,
                        (select id,ActivityDate, TaskSubtype, LastModifiedDate  from tasks Where (TaskSubtype  = 'Email' OR LastModifiedDate = Today) 
                        AND Status = 'Completed' AND id IN:tskset) 
                        from lead where Id IN :leadids]){
            recordUpdated = false;          
           // ld.Total_Email_Outbound__c = 0; 
           system.debug('sssss'+ld.tasks.size());        
            for(Task tsk : ld.tasks){
                if(tsk.TaskSubtype == 'Email' && emailType ){
                    System.debug('Total_Email_Outbound__c=='+ld.Total_Email_Outbound__c);
                    ld.Total_Email_Outbound__c = ld.Total_Email_Outbound__c + 1;
                   ld.Last_Contact_Date__c = myDate;
                   System.debug('Total_Email_Outbound__c=='+ld.Total_Email_Outbound__c);
                    recordUpdated = true;
                }
                  
              /*  if(tsk.LastModifiedDate == myDate){
                    ld.Last_Contact_Date__c = myDate;
                    recordUpdated = true;
                } 
                if(myDate!=null){
                     ld.Last_Contact_Date__c = myDate;
                    recordUpdated = true;
                }*/
            }
            if(recordUpdated){
                leadstoupdate.add(ld);
            }   
        }
        }
        emailType=false;
        
        if(leadstoupdate.size() > 0){
            update leadstoupdate;
        }
        if(optyids.size()>0){
        for (Opportunity Opty1: [select Id, Name,Total_Email_Outbound__c, Last_Contact_Date__c,
                               (select id,ActivityDate,TaskSubtype, LastModifiedDate from tasks Where (TaskSubtype  = 'Email' OR LastModifiedDate = Today) AND 
                               Status = 'Completed' AND id IN:optytask) from Opportunity where Id IN :optyids ]) {
                recordUpdated = false;  
               // Opty1.Total_Email_Outbound__c = 0;  
                for(task t2: Opty1.tasks){
                    if(t2.TaskSubtype == 'Email'){
                    Opty1.Total_Email_Outbound__c = Opty1.Total_Email_Outbound__c + 1;
                    Opty1.Last_Contact_Date__c = myDate;
                    recordUpdated = true;
                }
                /*if(t2.LastModifiedDate == myDate){
                    Opty1.Last_Contact_Date__c = myDate;
                    recordUpdated = true;
                }
                 if(myDate!=null){
                    Opty1.Last_Contact_Date__c= myDate;
                    recordUpdated = true;
                } */
               }
                if(recordUpdated)
                    Optystoupdate.add(Opty1);
        }
        }
        if(Optystoupdate.size() > 0)
            update Optystoupdate;
        
        /*
        Map<id,lead> leadMap = new Map<id,lead>([select id, Total_Email_Outbound__c from lead where id IN :leadids]);
        Map<id,lead> leadLTDate = new Map<id,lead>([select id, Last_Contact_Date__c from lead where id IN :leadids]);
        Map<id,Opportunity> OptyLTDate = new Map<id,Opportunity>([select id, Last_Contact_Date__c from Opportunity where id IN :optyids]);
        
        
        
        for (lead acc: [select Id, Name, Total_Email_Outbound__c,
                        (select id,ActivityDate from tasks Where TaskSubtype  = 'Email' AND Status = 'Completed' ) 
                        from lead where Id IN :leadids]) {
            for(task t: acc.tasks){
                            leadMap.get(acc.Id).Total_Email_Outbound__c = acc.tasks.size();
            }
            leadstoupdate.add(leadMap.get(acc.Id));
        }

        update leadstoupdate;
            
        for (lead acc1: [select Id, Name, Last_Contact_Date__c,
                        (select id,ActivityDate from tasks Where Status = 'Completed' AND LastModifiedDate = Today) 
                        from lead where Id IN :leadids]) {
                for(task t1: acc1.tasks){
                                leadLTDate.get(acc1.Id).Last_Contact_Date__c = myDate;
                }
                leadstoupdate1.add(leadLTDate.get(acc1.Id));
        }

        update leadstoupdate1;

        for (Opportunity Opty1: [select Id, Name, Last_Contact_Date__c,
                                (select id,ActivityDate from tasks Where Status = 'Completed' AND LastModifiedDate = Today) 
                                from Opportunity where Id IN :optyids and Status__c = 'Open' ]) {
                for(task t2: Opty1.tasks){
                                OptyLTDate.get(Opty1.Id).Last_Contact_Date__c = myDate;
                }
                Optystoupdate.add(OptyLTDate.get(Opty1.Id));
        }

        update Optystoupdate;
        */
    }
  /*   @AuraEnabled
    public static String getDeleteStatus(String taskId) {
        String valueToLabel = '';
       List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
         try {
            if(MyProflieName=='CBR System Administrator'){
                Task t1=[SELECT Id, Subject from Task where Id=:taskId] ;   
                delete t1;
                valueToLabel='true';
            }
            
        } catch (Exception e) { }
        return valueToLabel;      
    } */
    
    public static void preventDeletetask(List<Task> TaskList){
        String ProfileId = UserInfo.getProfileId();  
        List<Profile> profiles=Database.query('select id,name from Profile where '+System.Label.allowedPrflForTskDlt+' AND Id = :ProfileId');
        if(profiles.size() == 0) {
            for (Task a : TaskList){
                    a.addError('You can\'t delete this record');
                
            }
        } 
    }
   //Method to update type(custom and standard) and sub-type fields when an email is sent from opportunity
   public static void updateTypeFields(set<Id> taskIds){
       system.debug('newTasks----'+taskIds);
       List<Task> updateTasks = new List<Task>();
       
       if(taskIds!=null && !taskIds.isEmpty()){
          for(Task t:[select id,type,Task_Type__c,Task_Sub_Type__c from task where Id IN: taskIds]){
          system.debug('task ----'+t);
          system.debug('task id'+t.id);
             // if(String.isBlank(t.type) && String.isBlank(t.Task_Type__c) && String.isBlank(t.Task_Sub_Type__c) && String.isNotBlank(t.TaskSubtype) && t.TaskSubtype == 'Email'){
                 t.SkipValidation__c= true;
                  t.Type = 'Mail - Outbound';
                  t.Task_Type__c = 'Email';
                  t.Task_Sub_Type__c = 'Outbound';
                  updateTasks.add(t);
              //}
          }
              
       }
       
       if(updateTasks!=null && !updateTasks.isEmpty()){
          Database.update(updateTasks,false); 
       }
   }
    public Static void updateProviderContactDate(List<Task> newList){
        Map<Id,Date> providerIdDateMap = new Map<Id,Date>();
        List<Account> accList = new List<Account>();
        for(Task t:newList) {
            if(t.Status=='Completed' && (t.Task_Type__c =='Call Inbound' || t.Task_Type__c=='Call Outbound' || t.Task_Type__c == 'Mail - Outbound' || (t.Task_Type__c == 'Email' && t.Task_Sub_Type__c =='Outbound'))){
                providerIdDateMap.put(t.WhatId, t.LastModifiedDate.date());
            }		   
	   }
	   if(providerIdDateMap!=null && !providerIdDateMap.isEmpty()){
			accList = [select id,Last_Contact_Date__pc from account where recordtype.name ='Provider' AND Id IN:providerIdDateMap.keyset()];
			if(accList!=null && !accList.isEmpty()){
				for(Account acc:accList){
					acc.Last_Contact_Date__pc = providerIdDateMap.get(acc.id);
				}
				database.update(accList,false);
			}
	   }
	   
    }

}