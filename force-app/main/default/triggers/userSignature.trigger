trigger userSignature on User (before insert, before update) {
    for (user u : trigger.new) {
        u.Email_Signature__c = u.Signature;
    }
}