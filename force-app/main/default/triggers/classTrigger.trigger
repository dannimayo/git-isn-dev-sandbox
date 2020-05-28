//trigger to get the time zone offset based on selected class time zone and class start date
//uses a Salesforce method to get the offset based on an entered date
//method helps account for varying time differences and changes based on daylight savings
trigger classTrigger on Class__c (before insert, before update) {

	//create a map of time zones from the custom meta data Time Zones
    Map<String,String> isnTZm = new Map<String,String>();
    
    //create a map of Label to KeyId
    //KeyId matches the time zone ids that salesforce uses
    for (Time_Zone__mdt tz : [SELECT Label, KeyId__c FROM Time_Zone__mdt ORDER BY Label ASC]) {
        isnTZm.put(tz.Label,tz.KeyId__c);
    }
    
    //loop through new or updated classes that started the trigger
    for (Class__c c : Trigger.new) {
           
        //from Salesforce documentation
        //uses TimeZone methods to get the time zone and offset
        TimeZone tz 			= TimeZone.getTimeZone(isnTZm.get(c.Time_Zone__c));
        Time newTime 			= Time.newInstance(0, 0, 0, 0);
        DateTime classStartDT 	= DateTime.newInstance(c.Start_Date__c, newTime);
        
        //set the time zone offsite hours on the class
        c.Time_Zone_Offset__c 	= (tz.getOffset(classStartDT) / 1000 / 60 / 60);
    
    }
    
}