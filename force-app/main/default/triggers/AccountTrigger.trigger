/*
Developer: Randy Perkins
Author Date: 1/31/2020
Last Update: 1/31/2020

Version History: 
1.0 - Created

Parameters:

Usage: send account ids to AccountEmployeeBillingCount
*/
trigger AccountTrigger on Account (after insert, after update, after delete, after undelete) {
    Set<string> accountIds = new Set<string>{};
    if ((Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) && AccountEmployeeBillingCount.isFirstTime) {
        for (Account a : Trigger.New) {
            if (Trigger.isUpdate && Trigger.NewMap.get(a.Id).ParentId != Trigger.OldMap.get(a.Id).ParentId){
                accountIds.add(Trigger.NewMap.get(a.Id).Ultimate_Parent__c); system.debug(Trigger.NewMap.get(a.Id).Ultimate_Parent__c);
                accountIds.add(Trigger.OldMap.get(a.Id).Ultimate_Parent__c); system.debug(Trigger.OldMap.get(a.Id).Ultimate_Parent__c);
            } 
            if (Trigger.isInsert || Trigger.isUndelete || (Trigger.isUpdate && (Trigger.NewMap.get(a.Id).Billing_Employee_Count__c != Trigger.OldMap.get(a.Id).Billing_Employee_Count__c || Trigger.NewMap.get(a.Id).Hierarchy_Type__c != Trigger.OldMap.get(a.Id).Hierarchy_Type__c))){
                accountIds.add(Trigger.NewMap.get(a.Id).Ultimate_Parent__c);
            }
        }
    }
    if (Trigger.isDelete && AccountEmployeeBillingCount.isFirstTime) {
        for (Account a : Trigger.Old) {
            accountIds.add(Trigger.OldMap.get(a.Id).Ultimate_Parent__c);
        }
    }
    if (!accountIds.isEmpty() && AccountEmployeeBillingCount.isFirstTime) {
        AccountEmployeeBillingCount.isFirstTime = false; //added to prevent trigger recursion
        AccountEmployeeBillingCount.calcHierarchyBillingCount(accountIds);
    }
}