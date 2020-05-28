trigger PaymentAllocationTrigger on blng__PaymentAllocationInvoiceLine__c (after insert, after update) {
    PaymentAllocationTriggerHandler handler = new PaymentAllocationTriggerHandler();
    if( Trigger.isAfter ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            handler.updateInvoice(Trigger.new );
        }       
    }
}