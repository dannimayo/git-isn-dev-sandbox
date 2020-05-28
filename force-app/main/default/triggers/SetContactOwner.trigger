trigger SetContactOwner on Contact (before insert,after insert,after update,after undelete,after delete) {
    TriggerSetting__mdt triggerSetting = [SELECT Label, isDisabled__c FROM TriggerSetting__mdt WHERE Label = 'SetContactOwner' LIMIT 1];
    if (!triggerSetting.isDisabled__c) {
        if (trigger.isBefore) {
            
            // Gather accounts
            List<String> accountList = new List<String>();
            List<String> siteList = new List<String>();
            List<String> psaList = new List<String>();
            for (Contact c : Trigger.new){
                accountList.add(c.AccountId);
                if (c.Site_Name2__c != null) {
                    siteList.add(c.Site_Name2__c);
                } 
            }
            
            // Query Accounts and Sites
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT OwnerId FROM Account WHERE Id =: accountList]);
            Map<Id, Site__c> siteMap = new Map<Id, Site__c>([SELECT Site_Primary__r.Id FROM Site__c WHERE Id =: siteList AND Site_Primary__r.IsActive = TRUE]);
            
            // Set Owners
            for (Contact c : Trigger.new){
                if (siteMap.containsKey(c.Site_Name2__c)){
                    c.OwnerId = siteMap.get(c.Site_Name2__c).Site_Primary__c;
                } else if (accountMap.containsKey(c.AccountId)) {
                    c.OwnerId = accountMap.get(c.AccountId).OwnerId;
                }
            }
        }
        if (trigger.isAfter) {
            
            // Gather accounts
            contact[] cons = trigger.isDelete ? trigger.old : trigger.new;
            List<String> accountList = new List<String>();
            for (Contact c : cons){
                accountList.add(c.AccountId);
            }
            system.debug('accountList' + accountList);
            
            // get counts of references and contact sharing info with contractors as two aggregate lists
            Map<Id,AggregateResult> results = new Map<Id,AggregateResult>([SELECT AccountId Id, Sum(Is_Active_Reference__c) numRefs, Sum(Is_Sharing_Info_with_CEs__c) numShared FROM Contact WHERE (Is_Active_Reference__c = 1 OR Is_Sharing_Info_with_CEs__c = 1) AND AccountId IN : accountList Group By AccountId]);
            system.debug('results' + results);
            if(!results.isEmpty()){
                // Loop through Accounts and update reference and contact info shared stats
                Account[] accs = [SELECT Id, Number_of_References__c, Contacts_Sharing_Info_with_CEs__c FROM Account WHERE Id IN : results.keySet()];
                for (Account a : accs) {
                    a.Number_of_References__c = (Decimal)results.get(a.Id).get('numRefs');
                    a.Contacts_Sharing_Info_with_CEs__c = (Decimal)results.get(a.Id).get('numShared');
                }
                update accs;  
            }
        }
    }
}