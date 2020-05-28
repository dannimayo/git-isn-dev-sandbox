trigger LastMeetingWithContactAndAccount on Event (after insert, after update, after undelete, after delete) {
   
    List<Event> triggerEvents = Trigger.IsDelete ? Trigger.Old : Trigger.New;
   
    List<ID> ContactLastMeeting = New List<ID>();
    List<ID> AccountLastMeeting = New List<ID>();
    List<Contact> ContactsToUpdate = New List<Contact>();
    List<Account> AccountsToUpdate = New List<Account>();
            
    for (Event e : triggerEvents){
        if (e.WhoID != null) {
            ContactLastMeeting.add(e.whoId);
        }
        if (e.whatId != null) {
            AccountLastMeeting.add(e.whatId);
        }
    }       
            
    if (ContactLastMeeting.size() > 0) {
    
        List<Contact> contacts = [SELECT Id, Last_Meeting_Date__c, Last_Meeting_Subject__c, Last_Meeting_Type__c, 
                                  (SELECT Event.ID, Event.ActivityDate, Event.Activity_Type__c, Event.Subject, Event.Annual_Metrics_Management_Meeting__c
                                  FROM Contact.Events
                                      WHERE Event.IsDeleted = False 
                                      ORDER BY Event.ActivityDate DESC LIMIT 1) 
                                  FROM Contact 
                                      WHERE Id in : ContactLastMeeting];
        
        for(contact c : contacts){
            if (!c.Events.isEmpty()) {
                c.Last_Meeting_Date__c     = c.Events[0].ActivityDate;
                c.Last_Meeting_Subject__c  = c.Events[0].Subject;
                c.Last_Meeting_Type__c     = c.Events[0].Activity_Type__c;
            } else {
                c.Last_Meeting_Date__c     = null;
                c.Last_Meeting_Subject__c  = null;
                c.Last_Meeting_Type__c     = null;
            }
            ContactsToUpdate.add(c);
        }
    
        if (ContactsToUpdate.size() > 0) {
            update ContactsToUpdate;
        }
    
    }
    
    if (AccountLastMeeting.size() > 0) {
    
        List<Account> LastMeeting = [SELECT Id, Last_Meeting_Date_Account__c, Last_Meeting_Subject_Account__c, Last_Meeting_Type_Account__c, Annual_Mgmt_Meeting_Held__c, Date_of_Last_Metrics_Meeting__c, Hosted_UGM_HD__c, 
                                     (SELECT Event.Id, Event.ActivityDate, Event.Activity_Type__c, Event.Subject, Event.Annual_Metrics_Management_Meeting__c
                                         FROM Account.Events
                                             WHERE Event.IsDeleted = False 
                                             ORDER BY Event.ActivityDate DESC) 
                                     FROM Account
                                         WHERE Id in : AccountLastMeeting];
        
        Map<Id,Map<String,Event>> accountEventMap = new Map<Id,Map<String,Event>>();
        
        for (Account a : LastMeeting) {
            accountEventMap.put(a.Id, new Map<String,Event>());
            for (Event e : a.Events) {
                if (!accountEventMap.get(a.Id).containsKey(e.Activity_Type__c)) {
                    accountEventMap.get(a.Id).put(e.Activity_Type__c,e);
                }
                if (!accountEventMap.get(a.Id).containsKey('Metrics Meeting')) {
                    if (e.Annual_Metrics_Management_Meeting__c == TRUE) {
                        accountEventMap.get(a.Id).put('Metrics Meeting',e);
                    }
                }
            }
        }
        system.debug('the map === ' + accountEventMap);
                                     
        for (Account a : LastMeeting) {
        
            Date annualMgmtMtg = accountEventMap.get(a.Id).containsKey('20 - Meeting with Director or Higher (Existing Client)') ? accountEventMap.get(a.Id).get('20 - Meeting with Director or Higher (Existing Client)').ActivityDate : null;
            Date lastMetricsMtg = accountEventMap.get(a.Id).containsKey('Metrics Meeting') ? accountEventMap.get(a.Id).get('Metrics Meeting').ActivityDate : null;
            Date hostedUGM = accountEventMap.get(a.Id).containsKey('10 - Hosted UGM/HD') ? accountEventMap.get(a.Id).get('10 - Hosted UGM/HD').ActivityDate : null;
        
            if (!a.Events.isEmpty()) {
                a.Last_Meeting_Date_Account__c     = a.Events[0].ActivityDate;
                a.Last_Meeting_Subject_Account__c  = a.Events[0].Subject; 
                a.Last_Meeting_Type_Account__c     = a.Events[0].Activity_Type__c;
                a.Annual_Mgmt_Meeting_Held__c      = annualMgmtMtg;
                a.Date_of_Last_Metrics_Meeting__c  = lastMetricsMtg;
                a.Hosted_UGM_HD__c                 = hostedUGM;
            } else {
                a.Last_Meeting_Date_Account__c     = null;
                a.Last_Meeting_Subject_Account__c  = null; 
                a.Last_Meeting_Type_Account__c     = null;
                a.Annual_Mgmt_Meeting_Held__c      = null;
                a.Date_of_Last_Metrics_Meeting__c  = null;
                a.Hosted_UGM_HD__c                 = null;
            }
            AccountsToUpdate.add(a);
        }
        
        if (AccountsToUpdate.size() > 0) {
            update AccountsToUpdate;
        }
    }
}