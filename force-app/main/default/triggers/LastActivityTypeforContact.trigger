trigger LastActivityTypeforContact on Task (before insert, before update, after insert, after update, after undelete, after delete) {
    
    //Trigger Manual Override is a Custom Setting that is Admin controlled
    //it cann be enabled so that records can be mass updated or inserted
    //and avoiding running the trigger to prevent errors or validation checks
    triggerManualOverride__c[] tmo = [select Name, TriggerDisabled__c FROM triggerManualOverride__c WHERE Name = 'testClassRun' Limit 1];
    
    isTrigger__c isTrigger = isTrigger__c.getInstance();
    isTrigger.triggerOn__c = true;
    upsert isTrigger;
    
    if ((tmo.size() > 0 && tmo[0].TriggerDisabled__c == false) || tmo.size() == 0) {
    
        if(trigger.isBefore){
            //everything inside a try block to catch any errors and provide user with message
            try {
                //list to house all the WhoIds from the tasks in trigger
                List<Id> contactnameids = New List <Id>();
                //map to hold the contact object with WhoId as key
                Map<Id,Contact> cMap = New Map <Id,Contact>();
                //loop through all tasks and add WhoIds to contactnameids list
                for(Task a : Trigger.New){ 
                    contactnameids.add(a.whoid);
                }
                //build list to populate cMap
                List<Contact> contactsForMap = [SELECT Id, Name, Account_ISN_Status__c, Account_Team__c, AccountId, Site_Name2__c, IsProspect__c FROM Contact WHERE Id IN :contactnameids];
                //put all contacts from contactsForMap List into map
                cMap.putAll(contactsForMap);
                //loop through tasks in trigger
                for (Task a : Trigger.New) {
                    if (a.Activity_Type__c == NULL) {
                        if (cMap.containsKey(a.WhoId)) {
                            //updates specific to subscribers
                            if (cMap.get(a.WhoId).IsProspect__c == False) {
                                if ((a.subject).contains('Email:') || (a.subject).contains('Mail merge')) { 
                                    a.Activity_Type__c = '00 - No Points (inbound email, received voicemail, email to subscriber)';
                                } 
                                else if ((a.subject).contains('New Contact')) { 
                                    a.Activity_Type__c = '01 - Find Contact';
                                } 
                            }
                            //updates specific to prospects
                            else if (cMap.get(a.WhoId).IsProspect__c == True) {
                                if ((a.subject).contains('Email:')) { 
                                    a.Activity_Type__c = '02 - Send Email';
                                } 
                                else if ((a.subject).contains('New Contact')) { 
                                    a.Activity_Type__c = '01 - Find Contact';
                                } 
                                else if ((a.subject).contains('Mail merge')) {                
                                    a.Activity_Type__c = '02 - Mail Letter';     
                                } 
                            }
                        }
                    }
                    //for any task update that Account if missing
                    if (a.WhatId == null && cMap.containsKey(a.whoid)){
                        a.WhatId = cMap.get(a.whoid).AccountId;
                    }
                    //for any task update the Notes Entered By field if missing
                    if (a.Notes_entered_by_del__c == null) {
                        a.Notes_entered_by_del__c = a.User_Name__c;
                    }
                    //for any task update the Site if missing
                    if (a.Site__c == null && cMap.containsKey(a.whoid) && cMap.get(a.whoid).Site_Name2__c != null) {
                        a.Site__c = cMap.get(a.whoid).Site_Name2__c;
                    }
                    //for any task update the points to the numeric value of the first two digits from activity type
                    if (a.Activity_Type__c != null && a.Activity_Type__c.left(2).isNumeric()) {
                        Integer p = Integer.valueOf(a.Activity_Type__c.left(2));
                        a.Points__c = p;
                    }
                    //for any task update the team to the appropriate team value (account or user team based on setting)
                    if (a.Team__c == null) {
                        if (a.user_activity_team_override__c == true) {
                            a.Team__c = a.User_Team__c;
                        } else if (cMap.containsKey(a.whoid)) {
                            a.Team__c = cMap.get(a.whoid).Account_Team__c;
                        }
                    }
                }  
            } 
            //catch block to show a slightly more user friendly error than the standard DML messages
            catch (DmlException de) {
                Integer numErrors = de.getNumDml();
                System.debug('getNumDml = ' + numErrors);
                for(Integer i=0;i<numErrors;i++) {
                    System.debug('getDmlId = ' + de.getDmlId(i));
                    System.debug('getDmlFieldNames = ' + de.getDmlFieldNames(i));
                    System.debug('getDmlMessage = ' + de.getDmlMessage(i)); 
                }
                //query for the contact name to include in error message
                Contact cErrName = [Select Name From Contact Where Id =: de.getDmlId(0)];
                trigger.old[0].adderror('First Error: ' + de.getDmlMessage(0) + ' For Contact (Name: ' + cErrName.Name + ' / Id: ' + cErrName.Id + ')');
            }
        }
        
        if (trigger.isAfter){
        
            List<Task> triggerTasks = Trigger.IsDelete ? Trigger.Old : Trigger.New;
            List<Id> triggerContacts = New List<Id>();
            List<Id> triggerAccounts = New List<Id>();
            
            for(Task t : triggerTasks){
                if(t.WhoID != null && t.whatid != null){
                    triggerContacts.add(t.whoid);
                    triggerAccounts.add(t.whatid);
                }
            }              
            
            if(triggerContacts.size()>0){
                
                List<Contact> contactsWithTasks = [select id, Last_Activity_Type__c, LastActivityDate, Last_Call_Type__c, Last_Call_Date__c, Last_Mail_Letter_Date__c,
                                          (Select Task.id, Task.Subject, Task.ActivityDate, Task.Activity_Type__c 
                                           FROM Contact.Tasks 
                                           Where Task.ActivityDate != NULL
                                           AND Task.IsDeleted = False 
                                           AND Task.Status = 'Completed' 
                                           ORDER BY Task.ActivityDate DESC)
                                          FROM Contact 
                                          WHERE id in : triggerContacts];
                
                Map<Id,Map<String,Task>> contactActivityMap = new Map<Id,Map<String,Task>>{};
                    
                    for (Contact c : contactsWithTasks) {
                        contactActivityMap.put(c.Id, new Map<String,Task>());
                        for (Task t : c.Tasks) {
                            if (!contactActivityMap.get(c.Id).containsKey(t.Activity_Type__c)) {
                                contactActivityMap.get(c.Id).put(t.Activity_Type__c,t);
                            }
                            if (!contactActivityMap.get(c.Id).containsKey('lastCall') && (t.Activity_Type__c == '02 - Left Voicemail' || t.Activity_Type__c == '03 - Spoke with Contact/Lead')) {
                                contactActivityMap.get(c.Id).put('lastCall',t);
                            }
                        }
                    }
                
                List<Contact> ContactsToUpdate = New List<contact>();
                
                for(contact c : contactsWithTasks){
                    String lastCallType = contactActivityMap.get(c.Id).containsKey('last call') ? contactActivityMap.get(c.Id).get('last call').Activity_Type__c : null;
                    Date lastCallDate = contactActivityMap.get(c.Id).containsKey('last call') ? contactActivityMap.get(c.Id).get('last call').ActivityDate : null;
                    Date lastMailLetterDate = contactActivityMap.get(c.Id).containsKey('02 - Mail Letter') ? contactActivityMap.get(c.Id).get('02 - Mail Letter').ActivityDate : null;
                    
                    if(!c.Tasks.isempty()){
                        c.Last_Activity_Type__c = c.Tasks[0].Activity_Type__c;
                        c.Last_Call_Type__c = lastCallType;
                        c.Last_Call_Date__c = lastCallDate;
                        c.Last_Mail_Letter_Date__c = lastMailLetterDate;              
                    }
                    else if(c.Tasks.isempty()){
                        c.Last_Activity_Type__c = null;
                        c.Last_Call_Type__c = lastCallType;
                        c.Last_Call_Date__c = lastCallDate;
                        c.Last_Mail_Letter_Date__c = lastMailLetterDate;
                    }
                    ContactsToUpdate.add(c);
                }
                if(ContactsToUpdate.size()> 0){
                    update ContactsToUpdate;
                }
            }    
            
            if(triggerAccounts.size()>0){
                
                List<Account> accountsWithTasks = [select id, Last_Activity_Type__c, 
                                          (Select Task.id, Task.ActivityDate, Task.Activity_Type__c
                                           FROM Account.Tasks
                                           Where Task.IsDeleted = False
                                           AND Task.Status = 'Completed' 
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
    isTrigger.triggerOn__c = false;
    update isTrigger;
}