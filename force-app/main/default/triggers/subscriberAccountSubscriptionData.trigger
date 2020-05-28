//there is a daily file import from ISNetworld that includes all Clients and Contractor Operators
//it includes basic subscription details like start and end dates and vertical team information
//this trigger will look through the upsert completed with the file each day
//and find any records that had an updated field and add to a map to update related Accounts
trigger subscriberAccountSubscriptionData on ISNCompanyRecord__c (after insert, after update) {
    //custom record to hold ISNetworld company record data
    ISNCompanyRecord__c ISNComp = new ISNCompanyRecord__c();
    //this will get a list of all fields for ISNCompanyRecord__C and create a map
    Schema.SObjectType ISNCompSObj = ISNComp.getSObjectType();
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ISNCompanyRecord__c.fields.getMap();
    //map to hold any records that have updates 
    Map<String, ISNCompanyRecord__c> updatedRecords = new Map<String, ISNCompanyRecord__c>();
    //only looking for updates if a record is already existing in Salesforce
    if (trigger.isUpdate) {
        for (ISNCompanyRecord__c isnr : trigger.new) {
            //create an old record to compare against using trigger OldMap
            ISNCompanyRecord__c oldISNRec = trigger.oldMap.get(isnr.Id);
            //counter to look how many fields are updates for the object
            Integer numFieldUpdates = 0;
            for (String str : fieldMap.keyset()) {
                if (isnr.get(str) != oldISNRec.get(str)) {
                    //ignore updates to the lastmodified dates since these update at every upsert
                    if (!str.containsIgnoreCase('lastmodified') && !str.containsIgnoreCase('systemmodstamp')) {
                        System.Debug('Field Changed: ' + str + ' Old Value: ' + oldISNRec.get(str) + ' New Value: ' + isnr.get(str));
                        numFieldUpdates = numFieldUpdates + 1;
                    }
                }
            }
            system.debug('numFieldUpdates = ' + numFieldUpdates);
            //if a field value has changed add to the update map
            if (numFieldUpdates > 0) {
                updatedRecords.put(isnr.CompanyID__c,isnr);
            }
        }
    }
    //if the update is a new record we automatically add to the map without comparing updates
    else if (trigger.isInsert) {
        for (ISNCompanyRecord__c isnr : trigger.new) {
            updatedRecords.put(isnr.CompanyID__c,isnr);
        }
    }
    //if there are record updates or inserts pass the map to Apex Class to find and update matching Account records
    if (updatedRecords.size() > 0) {
        subscriberAccountUpdates.updateAccountSubscriptionDetails(updatedRecords);
    }
}