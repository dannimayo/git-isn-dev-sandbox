trigger eventAccountDetails on Event (before update, before insert) {

    Set<Id> whatIds = new Set<Id>();
    Map<Id,Account> accountMap = new map<Id,Account>{};
    
    for (Event e : Trigger.New) {
        if (e.whatId != null && e.whatId.getSObjectType().getDescribe().getName() == 'Account' && (e.Related_Account_Name__c == null || e.Related_Account_Email__c == null)) {
            whatIds.add(e.WhatId);
        }
    }
    
    Account[] relatedAccounts = [SELECT Id, Name, Vertical_Team_Email__c FROM Account WHERE Id IN :whatIds];
    
    for (Account a : relatedAccounts) {
        accountMap.put(a.Id, a);
    }

    for (Event e :trigger.new) {
        if (e.whatId != null && e.whatId.getSObjectType().getDescribe().getName() == 'Account' && (e.Related_Account_Name__c == null || e.Related_Account_Email__c == null)) {
            e.Related_Account_Name__c = accountMap.get(e.whatId).Name;
            e.Related_Account_Email__c = accountMap.get(e.whatid).Vertical_Team_Email__c;
        }
        if (e.Activity_Type__c != null && e.Activity_Type__c.left(2).isNumeric()) {
            Integer p = Integer.valueOf(e.Activity_Type__c.left(2));
            e.Points__c = p;
        }  
    }
    
}