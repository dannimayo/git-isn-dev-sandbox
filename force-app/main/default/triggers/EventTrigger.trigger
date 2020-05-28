/*
Developer: Randy Perkins
Author Date: 3/9/2020
Last Update: 3/9/2020

Version History: 
1.0 - Created

Parameters:

Notes: send eventIds to EventTriggerHandler
*/
trigger EventTrigger on Event (after insert, after update, after delete, after undelete) {
    
    List<Event> triggerEvents = Trigger.IsDelete ? Trigger.Old : Trigger.New;
    
    Set<ID> ContactLastMeeting = New Set<ID>();
    Set<ID> AccountLastMeeting = New Set<ID>();
    
    for (Event e : triggerEvents) {
        if (e.AccountId != null) {
            AccountLastMeeting.add(e.AccountId);
        }
        if (e.WhoId != null && e.WhoId.getSobjectType() == Schema.Contact.SObjectType) {
            ContactLastMeeting.add(e.WhoId);
        }
    }
    if (EventTriggerHandler.isFirstTime && (!ContactLastMeeting.isEmpty() || !AccountLastMeeting.isEmpty())) {
        EventTriggerHandler.isFirstTime = FALSE;
        EventTriggerHandler.eventAccountContactLastActivity(AccountLastMeeting, ContactLastMeeting);
    }
}