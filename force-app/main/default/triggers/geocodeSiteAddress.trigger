trigger geocodeSiteAddress on Site__c (after insert, after update) {    
    //bulkify trigger in case of multiple sites
    for (Site__c site : trigger.new) {
        //check if Address has been updated
        Boolean addressChangedFlag = false;
        if (Trigger.isUpdate) {
            Site__c oldsite = Trigger.oldMap.get(site.Id);
            if ((site.Street__C != oldsite.Street__c) || (site.City__C != oldsite.City__C) || (site.State__c != oldsite.State__c) || (site.Postal_Code__c != oldsite.Postal_Code__c) || (site.Country__c != oldsite.Country__c)) {
                addressChangedFlag = true;
                System.debug(LoggingLevel.DEBUG, '***Address changed for - ' + oldsite.Name);
            }
        }
        // if address is null or has been changed, geocode it
        if ((site.Location__Latitude__s == null) || (addressChangedFlag == true)) {
            System.debug(LoggingLevel.DEBUG, '***Geocoding Account - ' + site.Name);
            SiteGeocodeAddress.DoAddressGeocode(site.id);
        }
    }
}