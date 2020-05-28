/************************************************************************
 * Trigger calls AttachmentCount_Helper and an @future method
 * to update the attachment count field on parent object
 * **********************************************************************/
trigger AttachmentCount on Attachment (after insert, after delete, after undelete) {
    
    TriggerSetting__mdt triggerSetting = [SELECT Label, isDisabled__c FROM TriggerSetting__mdt WHERE Label = 'AttachmentCount' LIMIT 1];
    
    if (!triggerSetting.isDisabled__c) {
    
        Set<Id> parentIds = new Set<Id>();
        List<Attachment> triggerList = Trigger.IsDelete ? Trigger.Old : Trigger.New;
        
        for (Attachment a : triggerList) {
            parentIds.add(a.ParentId);
        }
        
        AttachmentCount_Helper.updateObjectAttachmentCount(parentIds);
    }
    
}