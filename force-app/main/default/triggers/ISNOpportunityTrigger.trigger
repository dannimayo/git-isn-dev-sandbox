trigger ISNOpportunityTrigger on Opportunity(before insert, before update) {
    //INSERT===
    if(Trigger.isInsert){
        final Map<ID, String> billCntrMap = new Map<ID, String> ();

        for (Opportunity oppty : Trigger.new) {
            billCntrMap.put(oppty.accountId, oppty.Billing_Country__c);
        }

        if (!billCntrMap.isEmpty()) {

            final List<String> billingCountries = billCntrMap.values();

            //Retrieve Country-Currency Mapping
            List<CPQ_Country_to_Region_Mapping__mdt> mappings = [SELECT Country__c, Currency__c
                                                                FROM CPQ_Country_to_Region_Mapping__mdt
                                                                WHERE Country__c IN: billingCountries];

            if (!mappings.isEmpty()) {
                for (Opportunity oppty : Trigger.new) {
                    if (billCntrMap.containsKey(oppty.accountId)) {

                        final String billCountry = billCntrMap.get(oppty.accountId);

                        for (CPQ_Country_to_Region_Mapping__mdt mapp: mappings) {

                            if (billCountry == mapp.Country__c) {
                                oppty.CurrencyIsoCode = mapp.Currency__c;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    //UPDATE===
 	if(Trigger.isUpdate){
        

     final List<Id> oppIds = new List<Id>();
    
     for (Opportunity oppty : Trigger.new) {
         if(!oppty.IsClosed && !oppty.IsWon && oppty.Days_Overdue__C > 90){
             oppty.StageName='Lost/Dead';
             oppty.Lost_Dead_Reason__c = 'Aged 90 Days';
             oppty.Lost_Dead_Notes__c = 'Aged 90 Days';
             
        	 oppIds.add(oppty.Id);  
         }
     }
    
    //Quotes
    List<SBQQ__Quote__c> quotesToExpire = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :oppIds];
    
    if(!quotesToExpire.isEmpty()){
	    for(SBQQ__Quote__c quote : quotestoExpire){
	        quote.SBQQ__Status__c='Expired';
	    }
	    update quotestoExpire;
	}
  }
}