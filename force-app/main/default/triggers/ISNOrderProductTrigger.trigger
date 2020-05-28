/*
Developer: George Sirbiladze
Author Date: 3/13/2020
Last Update: 3/17/2020

Version History: 
1.0 - Created
ISN-1312 - Update Legal Entities 


Parameters:

Usage: Auto Update Legal Entities for Order Product (API: OrderItem)
*/
trigger ISNOrderProductTrigger on OrderItem (before insert) {
  system.debug('DDDDD: Begin...');

  if(Trigger.isInsert){
        system.debug('DDDDD: ininsert mode');
        final Map<String, String> clPair = new Map<String, String>(); 
        final Map<String, Id> legalEntityIds = new Map<String, Id>(); 

        final List<blng__LegalEntity__c> legalEntities = [SELECT Id,Name FROM blng__LegalEntity__c WHERE blng__Active__c=true];
         
        system.debug('DDDDD: legalEntities: ' + legalEntities); 
        //CAD => id
        for(blng__LegalEntity__c entity : legalEntities){
            legalEntityIds.put(entity.Name, entity.Id);
        }
      
        final List<CPQ_Country_to_Region_Mapping__mdt> countriesMeta = [SELECT Country__c, Legal_Entity__c FROM CPQ_Country_to_Region_Mapping__mdt WHERE Legal_Entity__c in :legalEntityIds.keySet()];
    
      
        system.debug('DDDDD: countriesMeta: ' + countriesMeta); 
        //Canada <= CAD.Id
        for(CPQ_Country_to_Region_Mapping__mdt mType : countriesMeta){
            clPair.put(mType.Country__c, legalEntityIds.get(mType.Legal_Entity__c));
        }
        
        //Asign 
        for(OrderItem oi : Trigger.new){
            if(clPair.containsKey(oi.Billing_Country__c)){
                oi.blng__LegalEntity__c = clPair.get(oi.Billing_Country__c);
                
                system.debug('DDDDD: oi.blng__LegalEntity__c: ' + oi.blng__LegalEntity__c); 
            }
        }
    }
}