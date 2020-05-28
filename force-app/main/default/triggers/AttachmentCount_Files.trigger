/************************************************************************
 * Trigger calls AttachmentCount_Helper and an @future method
 * to update the attachment count field on parent object
 * **********************************************************************/
trigger AttachmentCount_Files on ContentDocument (after insert, before delete, after delete, after update, after undelete) {
    
    TriggerSetting__mdt triggerSetting = [SELECT Label, isDisabled__c FROM TriggerSetting__mdt WHERE Label = 'AttachmentCount' LIMIT 1];
    
    if (!triggerSetting.isDisabled__c) {
        
        Set<Id> parentIds = new Set<Id>();
        Set<Id> docSet = new Set<Id>();
        List<ContentDocument> triggerList = Trigger.IsDelete ? Trigger.Old : Trigger.New;
        for (ContentDocument c : triggerList) {
            docSet.add(c.Id);
        }
        
        List<ContentDocumentLink> triggerRelatedlist = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId in : docSet];
        
        for (ContentDocumentLink c : triggerRelatedlist) {
            system.debug('c.LinkedEntityId.getSobjectType() === ' + c.LinkedEntityId.getSobjectType());
            if(c.LinkedEntityId.getSobjectType() != Schema.User.SObjectType && c.LinkedEntityId.getSobjectType() != Schema.ContentWorkspace.SObjectType) {
                parentIds.add(c.LinkedEntityId);
            }
        }
        
        if (!parentIds.isEmpty()) {
            AttachmentCount_Helper.updateObjectAttachmentCount(parentIds);
        }
    }
}