public class CPQCamt052XMLParser 
            implements CPQICamt052Parser{

    private static final String GRPHDR = 'grphdr';
    private static final String ACCT = 'acct';
    private static final String SVCR = 'svcr';
    private static final String PRTRY = 'prtry';
    private static final String TXAMT = 'txamt';
    private static final String BOOKGDT = 'bookgdt';
    private static final String NTRY = 'ntry';   
                
    @TestVisible private CPQPaymentParserState XMLState = new CPQPaymentParserState();
    @TestVisible private CPQXMLParser parser = new CPQXMLParser();
    @TestVisible private CPQDepositAccessor depositValidator = new CPQDepositAccessor();
    @TestVisible private List<Deposit__c> CAMT052_deposits = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();
                 
                
    public List<Deposit__c> parsePatternCAMT052(Payload__c payloadToParse){
 
        XmlStreamReader reader = new XmlStreamReader(payloadToParse.Payload__c);
        CAMT052_deposits.clear();
        currDeposit.clear();
        currDeposit.Bank_Batch_Reference__c = payloadToParse.Name;
        currDeposit.Bank_Batch_Type__c = 'Transfer';
        currDeposit.Status__c = 'Open';
        //salesforce doesn't support final vars in switch statements --https://success.salesforce.com/ideaView?id=0873A000000lLkNQAU

        while (reader.hasNext()) {
            
            if (reader.isStartElement()){
                String startTag = reader.getLocalName().toLowerCase();
                //update scope
                XMLState.enterLevel(startTag);
                

                switch on startTag{
                    when 'credttm'{
                        if (XMLState.isWithinLevel(GRPHDR)){
                            String credttm = parser.parseFromStream(reader, false); //remove T from yyyy-MM-ddTHH:mm:ss
                            try{
                            currDeposit.Import_Date__c = DateTime.valueOf(credttm.replace('T', ' '));
                            }catch(Exception e){
                                throw new CPQInvalidXML052StringToDateException('Invalid import date located in xml payload name ' + payloadToParse.Name + '. Invalid import date is within xml element credttm.');
                            }
                        }
                    }
                    when 'nm' {
                        if (XMLState.isWithinLevel(ACCT) && XMLState.isWithinLevel(SVCR)){
                            String nm = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Raw__c = nm;
                        }
                    }
                    when 'ctry' {
                        if (XMLState.isWithinLevel(ACCT) && XMLState.isWithinLevel(SVCR)){
                            String ctry = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Country_Raw__c = ctry;
                        } 
                    }
                    when 'amt' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(TXAMT)){
                            String currencyAttributeValue = parser.parseFromStream(reader, true);
                            String amt = parser.parseFromStream(reader, false);
                            try{
                                currDeposit.Amount__c = Decimal.valueOf(amt);
                                currDeposit.CurrencyIsoCode = currencyAttributeValue;
                            }catch(Exception e){
                                throw new CPQInvalidXML052StringToNumberException('Invalid amount/currency located in xml payload name ' + payloadToParse.Name + '. Invalid amount/currency is within xml element amt.');
                            }
                        }
                    }
                    when 'dttm' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(BOOKGDT)){
                            String dttm = parser.parseFromStream(reader, false);
                            try{
                            currDeposit.Postmark_Date__c = Date.valueOf(dttm);
                            }catch(Exception e){
                                throw new CPQInvalidXML052StringToDateException('Invalid postmark date located in xml payload name ' + payloadToParse.Name + '. Invalid postmark date is within xml element dttm.');
                            }
                        }
                    }
                    when 'cd' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(PRTRY)){
                            String BAIcode = parser.parseFromStream(reader, false);
                            if (depositValidator.isXMLEntryValid(currDeposit, BAIcode) == false){
                                parser.skipToNextNtry(reader);
                                XMLState.leaveLevel(NTRY);
                            }
                        }
                    }
                    when 'acctsvcrref' {
                        if (XMLState.isWithinLevel(NTRY)){
                            String acctsvcrref = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Reference__c = acctsvcrref;
                            currDeposit.Name = acctsvcrref;
                        }
                    }
                    when 'ustrd' {
                        if (XMLState.isWithinLevel(NTRY)){
                            String ustrd = parser.parseFromStream(reader, false);
                            currDeposit.Raw_data__c = (currDeposit.Raw_data__c + ustrd);
                        }
                    }
                }
                    
                //end of switch    
            }
            //end ifSTART_ELEMENT
            
 
            if (reader.isEndElement()){
                String endTag = reader.getLocalName().toLowerCase();

                if (endTag == NTRY){
                    CAMT052_deposits.add(currDeposit.clone());
                    currDeposit.Raw_data__c = '';
                }
                
                //update scope
                XMLState.leaveLevel(endTag);
            }
            
            reader.next();
            //loop again
        }
        return CAMT052_deposits.deepClone();
    }
                
    
    public class CPQInvalidXML052StringToDateException extends Exception {                
    }
                
    public class CPQInvalidXML052StringToNumberException extends Exception {                
    }
                
                

    
}