trigger AttachQuestionBank on Account_Summary__c (before insert) {
    
    Map<String,Question_Bank__c> questionBanks = new Map<String,Question_Bank__c>();
    
    for (Question_Bank__c qb : [SELECT Id, Name, Form__r.Used_For__c FROM Question_Bank__c WHERE Status__c = 'Published']) {
        questionBanks.put(qb.Form__r.Used_For__c,qb);
    }
    
    if (!questionBanks.keySet().isEmpty()) {
        Map<Id,String> recordTypes = new Map<Id,String>();
        
        for (RecordType r : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Account_Summary__c']) {
            recordTypes.put(r.Id,r.Name);
        }
        
        for (Account_Summary__c a : trigger.new) {
            string checkRecordType = recordTypes.get(a.RecordTypeId);
            if (questionBanks.containsKey(checkRecordType)) {
                a.Question_Bank__c = questionBanks.get(checkRecordType).Id;
            }
        }
    }
}