//before insert and update trigger on tasks
trigger Task_Trigger on Task (before insert, before update, after insert, after update, after delete, after undelete) {

    if (trigger.isBefore){
        //gather all whoIds to look up contact and account information
        List<Id> taskWhoIds = New List <Id>();
        for (Task a : trigger.New){
            if (a.whoId != null) {
                taskWhoIds.add(a.whoid);
            }
        }
        
        //Query and cast custom metadata to maps to use for subject contains search
        //based on contains criteria update the activity type based on custom metadata criteria
        //one map for prospect and another for subscriber activities
        Map<Decimal,Activity_Criteria__mdt> activityProspectCriteria = new Map<Decimal,Activity_Criteria__mdt>();
        Map<Decimal,Activity_Criteria__mdt> activitySubscriberCriteria = new Map<Decimal,Activity_Criteria__mdt>();
        Activity_Criteria__mdt[] isnTeamList = [SELECT   Process_Order__c, Search_Subject_For__c, Update_Activity_Type_To__c, Use_For_Prospect__c
                                                FROM   Activity_Criteria__mdt 
                                                ORDER BY Process_Order__c ASC];
        for (Activity_Criteria__mdt a : isnTeamList) {
            if (a.Use_For_Prospect__c) {
                activityProspectCriteria.put(a.Process_Order__c,a);
            } else {
                activitySubscriberCriteria.put(a.Process_Order__c,a);
            }
        } 
        
        //create a map of task record types to assign based on contact status
        Map<String,Id> taskRecordTypes = new Map<String,Id>{};
            for (RecordType r : [SELECT Id, Name, sObjectType FROM RecordType WHERE sObjectType = 'Task']) {
                taskRecordTypes.put(r.Name,r.Id);
            }
        
        //create a map of id to associated contact
        Map<Id,Contact> taskContactsMap = New Map <Id,Contact>([SELECT  Id, Name, Account_ISN_Status__c, Account_Team__c, AccountId,  Site_Name2__c,  IsProspect__c,  PS_Account_Only__c, 
                                                                (SELECT Id, OpportunityId, Opportunity.Team__c FROM OpportunityContactRoles WHERE Opportunity.IsClosed = FALSE ORDER BY Opportunity.LastActivityDate Desc Limit 1)
                                                                FROM   Contact 
                                                                WHERE   Id IN :taskWhoIds]);
        
        //loop through tasks in trigger and assign activity types based on subject
        //and record type based on contact status
        for (Task a : trigger.New) {
            if (a.Activity_Type__c == NULL) {
                if (taskContactsMap.containsKey(a.WhoId)) {
                    if (taskContactsMap.get(a.WhoId).IsProspect__c == False) {
                        boolean stopCheck = FALSE;
                        for (integer i=0; i < activitySubscriberCriteria.size(); i++) { 
                            if (!stopCheck) {
                                if ((a.subject).contains(activitySubscriberCriteria.get(i).Search_Subject_For__c)){
                                    a.Activity_Type__c = activitySubscriberCriteria.get(i).Update_Activity_Type_To__c;
                                    stopCheck = TRUE;
                                }
                            }
                        }
                        a.RecordTypeId = taskRecordTypes.get('Subscriber Tasks');
                    }
                    else if (taskContactsMap.get(a.WhoId).IsProspect__c == True) {
                        boolean stopCheck = FALSE;
                        for (integer i=0; i < activityProspectCriteria.size(); i++) { 
                            if (!stopCheck) {
                                if ((a.subject).contains(activityProspectCriteria.get(i).Search_Subject_For__c)){
                                    a.Activity_Type__c = activityProspectCriteria.get(i).Update_Activity_Type_To__c;
                                    stopCheck = TRUE;
                                }
                            }
                        }
                        a.RecordTypeId = taskRecordTypes.get('Prospect Tasks');
                    }
                }
            }
            //complete additional fields that are required by default through UI
            if (a.WhatId == null && taskContactsMap.containsKey(a.whoid)) {
                if (!taskContactsMap.get(a.whoid).OpportunityContactRoles.isEmpty()) {
                    a.WhatId = taskContactsMap.get(a.whoid).OpportunityContactRoles[0].OpportunityId;
                } else {
                    a.WhatId = taskContactsMap.get(a.whoid).AccountId;
                }
            }
            if (a.Site__c == null && taskContactsMap.containsKey(a.whoid) && taskContactsMap.get(a.whoid).Site_Name2__c != null) {
                a.Site__c = taskContactsMap.get(a.whoid).Site_Name2__c;
            }
            if (a.Activity_Type__c != null && a.Activity_Type__c.left(2).isNumeric()) {
                Integer p = Integer.valueOf(a.Activity_Type__c.left(2));
                a.Points__c = p;
            }
            if (a.Team__c == null) {
                if (a.user_activity_team_override__c == true) {
                    a.Team__c = a.User_Team__c;
                } else if (taskContactsMap.containsKey(a.whoid) && !taskContactsMap.get(a.whoid).OpportunityContactRoles.isEmpty()) {
                    a.Team__c = taskContactsMap.get(a.whoid).OpportunityContactRoles[0].Opportunity.Team__c;
                } else if (taskContactsMap.containsKey(a.whoid)) {
                    a.Team__c = taskContactsMap.get(a.whoid).Account_Team__c;
                }
            } 
        } 
    }
    
    if (trigger.isAfter){
        
        List<Task> triggerTasks = Trigger.IsDelete ? Trigger.Old : Trigger.New;
        List<Id> triggerContacts = New List<Id>();
        List<Id> triggerAccounts = New List<Id>();
        
        for(Task t : triggerTasks){
            if(t.WhoID != null && t.whatid != null){
                triggerContacts.add(t.whoid);
                triggerAccounts.add(t.AccountID);
            }
        }              
        
        if(triggerContacts.size()>0){
            
            List<Contact> contactsWithTasks = [select id, Last_Activity_Type__c, LastActivityDate, Last_Call_Type__c, Last_Call_Date__c, Last_Mail_Letter_Date__c, Last_Engagement__c, 
                                               (Select Task.id, Task.Subject, Task.ActivityDate, Task.Activity_Type__c 
                                                FROM Contact.Tasks 
                                                Where Task.ActivityDate != NULL AND Task.IsDeleted = False  AND Task.Status = 'Completed' ORDER BY Task.ActivityDate DESC)
                                               FROM Contact 
                                               WHERE Id in : triggerContacts];
            
            Map<Id,Map<String,Task>> contactActivityMap = new Map<Id,Map<String,Task>>{};
                
                for (Contact c : contactsWithTasks) {
                    contactActivityMap.put(c.Id, new Map<String,Task>());
                    for (Task t : c.Tasks) {
                        if (!contactActivityMap.get(c.Id).containsKey(t.Activity_Type__c)) {
                            contactActivityMap.get(c.Id).put(t.Activity_Type__c,t);
                        }
                        if (!contactActivityMap.get(c.Id).containsKey('lastCall') && (t.Activity_Type__c == '02 - Left Voicemail' || t.Activity_Type__c == '04 - Spoke with Contact/Lead')) {
                            contactActivityMap.get(c.Id).put('lastCall',t);
                        }
                        if (!contactActivityMap.get(c.Id).containsKey('lastEngagement') && (t.Activity_Type__c == '01 - Send Email' || t.Activity_Type__c == '04 - Spoke with Contact/Lead')) {
                            contactActivityMap.get(c.Id).put('lastEngagement',t);
                        }
                    }
                }
            
            List<Contact> ContactsToUpdate = New List<contact>();
            
            for(contact c : contactsWithTasks){
                String lastCallType = contactActivityMap.get(c.Id).containsKey('lastCall') ? contactActivityMap.get(c.Id).get('lastCall').Activity_Type__c : null;
                Date lastCallDate = contactActivityMap.get(c.Id).containsKey('lastCall') ? contactActivityMap.get(c.Id).get('lastCall').ActivityDate : null;
                Date lastMailLetterDate = contactActivityMap.get(c.Id).containsKey('02 - Mail Letter') ? contactActivityMap.get(c.Id).get('02 - Mail Letter').ActivityDate : null;
                Date lastEngagementDate = contactActivityMap.get(c.Id).containsKey('lastEngagement') ? contactActivityMap.get(c.Id).get('lastEngagement').ActivityDate : null;
                
                if(!c.Tasks.isempty()){
                    c.Last_Activity_Type__c = c.Tasks[0].Activity_Type__c;
                    c.Last_Call_Type__c = lastCallType;
                    c.Last_Call_Date__c = lastCallDate;
                    c.Last_Mail_Letter_Date__c = lastMailLetterDate;
                    c.Last_Engagement__c = lastEngagementDate;
                }
                else if(c.Tasks.isempty()){
                    c.Last_Activity_Type__c = null;
                    c.Last_Call_Type__c = lastCallType;
                    c.Last_Call_Date__c = lastCallDate;
                    c.Last_Mail_Letter_Date__c = lastMailLetterDate;
                    c.Last_Engagement__c = lastEngagementDate;
                }
                ContactsToUpdate.add(c);
            }
            if(ContactsToUpdate.size() > 0){
                update ContactsToUpdate;
            }
        }    
        
        if(triggerAccounts.size()>0){
            
            List<Account> accountsWithTasks = [select id, Last_Activity_Type__c, 
                                               (Select Task.id, Task.ActivityDate, Task.Activity_Type__c
                                                FROM Account.Tasks
                                                Where Task.IsDeleted = False AND Task.Status = 'Completed' 
                                                ORDER BY Task.ActivityDate DESC limit 1) 
                                               FROM Account
                                               WHERE id in : triggerAccounts];
            
            List<Account> AccountsToUpdate = New List<Account>();
            for(Account a : accountsWithTasks){
                if(!a.Tasks.isempty()){
                    a.Last_Activity_Type__c = a.Tasks[0].Activity_Type__c;
                }
                else if(a.Tasks.isempty()){
                    a.Last_Activity_Type__c = null;
                }
                AccountsToUpdate.add(a);
            }
            if(AccountsToUpdate.size()>0){
                update AccountsToUpdate;
            }
        }
    }
    
}