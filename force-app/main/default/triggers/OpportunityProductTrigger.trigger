trigger OpportunityProductTrigger on OpportunityLineItem (after insert) {
    OpportunityProductTriggerHandler handler = new OpportunityProductTriggerHandler();
   
    if(Trigger.isAfter && Trigger.isInsert) {
        handler.applyRenewalOptyFieldUpdates(Trigger.new);
    }

}