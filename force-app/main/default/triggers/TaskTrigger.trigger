/*
Developer: Randy Perkins
Author Date: 3/10/2020
Last Update: 3/10/2020

Version History: 
1.0 - Created

Parameters:

Notes: send taskIds to EventTriggerHandler
*/
trigger TaskTrigger on Task (before insert, before update, after insert, after update, after delete, after undelete) {
    if (trigger.isBefore){
        List<Id> taskWhoIds = New List <Id>();
        for (Task a : trigger.New){
            if (a.whoId != null) {
                taskWhoIds.add(a.whoid);
            }
        }
        Map<Decimal,Activity_Criteria__mdt> activityProspectCriteria = new Map<Decimal,Activity_Criteria__mdt>();
        Map<Decimal,Activity_Criteria__mdt> activitySubscriberCriteria = new Map<Decimal,Activity_Criteria__mdt>();
        Activity_Criteria__mdt[] isnTeamList = [SELECT		Process_Order__c, 
                                                			Search_Subject_For__c, 
                                                			Update_Activity_Type_To__c, 
                                                			Use_For_Prospect__c
                                                FROM   		Activity_Criteria__mdt 
                                                ORDER BY 	Process_Order__c ASC];
        for (Activity_Criteria__mdt a : isnTeamList) {
            if (a.Use_For_Prospect__c) {
                activityProspectCriteria.put(a.Process_Order__c,a);
            } else {
                activitySubscriberCriteria.put(a.Process_Order__c,a);
            }
        } 
        Map<String,Id> taskRecordTypes = new Map<String,Id>{};
        List<RecordType> recordTypeList = [SELECT 	Id, 
                                           			Name, 
                                           			sObjectType 
                                           FROM 	RecordType 
                                           WHERE 	sObjectType = 'Task'];
        for (RecordType r : recordTypeList) {
            taskRecordTypes.put(r.Name,r.Id);
        }
        Map<Id,Contact> taskContactsMap = New Map <Id,Contact>([SELECT	Id, 
                                                                		Name, 
                                                                		Account_ISN_Status__c, 
                                                                		Account_Team__c, 
                                                                		AccountId, 
                                                                		Site_Name2__c, 
                                                                		IsProspect__c, 
                                                                		PS_Account_Only__c, 
                                                                		(SELECT 	Id, 
                                                                         			OpportunityId, 
                                                                         			Opportunity.Team__c 
                                                                         FROM 		OpportunityContactRoles 
                                                                         WHERE 		Opportunity.IsClosed = FALSE 
                                                                         ORDER BY 	Opportunity.LastActivityDate Desc 
                                                                         LIMIT 1)
                                                                FROM   Contact 
                                                                WHERE  Id IN :taskWhoIds]);
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
        if (TaskTriggerHandler.isFirstTime && (!triggerContacts.isEmpty() || !triggerAccounts.isEmpty())) {
            TaskTriggerHandler.isFirstTime = FALSE;
            TaskTriggerHandler.handleAfterTrigger(triggerAccounts, triggerContacts);
        }
    }
}