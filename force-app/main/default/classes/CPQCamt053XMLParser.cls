public class CPQCamt053XMLParser 
            implements CPQICamt053Parser{

    private static final String GRPHDR = 'grphdr';
    private static final String ACCT = 'acct';
    private static final String PRTRY = 'prtry';
    private static final String TXAMT = 'txamt';
    private static final String NTRY = 'ntry';   
                
    @TestVisible private CPQPaymentParserState XMLState = new CPQPaymentParserState();
    @TestVisible private CPQXMLParser parser = new CPQXMLParser();
    @TestVisible private CPQDepositAccessor depositValidator = new CPQDepositAccessor();
    @TestVisible private List<Deposit__c> CAMT053_deposits = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();
                 
                
    public List<Deposit__c> parsePatternCAMT053(Payload__c payloadToParse){
 
        XmlStreamReader reader = new XmlStreamReader(payloadToParse.Payload__c);
        CAMT053_deposits.clear();
        currDeposit.clear();
        currDeposit.Bank_Batch_Reference__c = payloadToParse.Name;
        currDeposit.Bank_Batch_Type__c = 'Transfer';
        currDeposit.Status__c = 'Open';
        //salesforce doesn't support final vars in switch statements --https://success.salesforce.com/ideaView?id=0873A000000lLkNQAU

        while (reader.hasNext()) {
            
            if (reader.isStartElement()){
                String startTag = reader.getLocalName().toLowerCase();
                System.debug('starttag ' + startTag);
                //update scope
                XMLState.enterLevel(startTag);
                

                switch on startTag{
                    when 'credttm'{
                        if (XMLState.isWithinLevel(GRPHDR)){
                            System.debug('\n\nHere is the value of credttm start tag ');
                            String credttm = parser.parseFromStream(reader, false); //remove T from yyyy-MM-ddTHH:mm:ss
                            System.debug('\n' + credttm);
                            try{
                                currDeposit.Import_Date__c = DateTime.valueOf(credttm.replace('T', ' '));
                            }catch(Exception e){
                                throw new CPQInvalidXML053StringToDateException('Invalid import date located in xml payload name ' + payloadToParse.Name + '. Invalid import date is within xml element credttm.');
                            }
                            System.debug('\nglobal deposit record updated. Import Date: ' + currDeposit.Import_Date__c);
                        }
                    }
                    when 'nm' {
                        if (XMLState.isWithinLevel(ACCT)){
                            String nm = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Raw__c = nm;
                            System.debug('\nglobal deposit record updated. Bank Raw Name: ' + currDeposit.Bank_Raw__c);
                        }
                    }
                    when 'ctry' {
                        if (XMLState.isWithinLevel(ACCT)){
                            System.debug('\n\nHere is the value of ACCT ctry start tag ');
                            String ctry = parser.parseFromStream(reader, false);
                            System.debug('\n' + ctry);
                            currDeposit.Bank_Country_Raw__c = ctry;
                        } 
                    }
                    when 'amt' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(TXAMT)){
                            System.debug('\n\nHere is the value of amt start tag ');
                            String currencyAttributeValue = parser.parseFromStream(reader, true);
                            String amt = parser.parseFromStream(reader, false);
                            System.debug('\n' + currencyAttributeValue);
                            System.debug('\n' + amt);
                            try{
                                currDeposit.Amount__c = Decimal.valueOf(amt);
                                currDeposit.CurrencyIsoCode = currencyAttributeValue;
                            }catch(Exception e){
                                throw new CPQInvalidXML053StringToNumberException('Invalid amount/currency located in xml payload name ' + payloadToParse.Name + '. Invalid amount/currency is within xml element amt.');
                            }
                            System.debug('\nglobal deposit record updated. Amount: ' + currDeposit.Amount__c);
                            System.debug('\nglobal deposit record updated. Currency: ' + currDeposit.CurrencyIsoCode);
                        }
                    }
                    when 'dttm' {
                        if (XMLState.isWithinLevel(NTRY)){
                            System.debug('\n\nHere is the value of dttm start tag ');
                            String dttm = parser.parseFromStream(reader, false);
                            System.debug('\n' + dttm);
                            try{
                                currDeposit.Postmark_Date__c = Date.valueOf(dttm);
                            }catch(Exception e){
                                throw new CPQInvalidXML053StringToDateException('Invalid postmark date located in xml payload name ' + payloadToParse.Name + '. Invalid postmark date is within xml element dttm.');
                            }
                            System.debug('\nglobal deposit record updated. Postmark Date: ' + currDeposit.Postmark_Date__c);
                        }
                    }
                    when 'cd' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(PRTRY)){
                            System.debug('\n\nHere is the valud of cd inside prtry tag ');
                            String BAIcode = parser.parseFromStream(reader, false);
                            System.debug('\nBAI code is ' + BAIcode);
                            if (depositValidator.isXMLEntryValid(currDeposit, BAIcode) == false){
                                parser.skipToNextNtry(reader);
                                XMLState.leaveLevel(NTRY);
                            }
                        }
                    }
                    when 'acctsvcrref' {
                        if (XMLState.isWithinLevel(NTRY)){
                            System.debug('\n\nHere is the value of txid start tag ');
                            String acctsvcrref = parser.parseFromStream(reader, false);
                            System.debug('\n' + acctsvcrref);
                            currDeposit.Bank_Reference__c = acctsvcrref;
                            currDeposit.Name = acctsvcrref;
                            System.debug('\nglobal deposit record updated. Bank Reference: ' + currDeposit.Bank_Reference__c +
                                        '\nglobal deposit record updated. Deposit Name: ' + currDeposit.Name);
                        }
                    }
                    when 'ustrd' {
                        if (XMLState.isWithinLevel(NTRY)){
                            System.debug('\n\nHere is the value of ustrd start tag ');
                            String ustrd = parser.parseFromStream(reader, false);
                            System.debug('\n' + ustrd);
                            currDeposit.Raw_data__c = (currDeposit.Raw_data__c + ustrd);
                            System.debug('\nglobal deposit record updated. Raw Data: ' + currDeposit.Raw_data__c);
                        }
                    }
                }
                    
                //end of switch    
            }
            //end ifSTART_ELEMENT
            
 
            if (reader.isEndElement()){
                String endTag = reader.getLocalName().toLowerCase();
                System.debug('end tag is ' + endTag);

                if (endTag == NTRY){
                    CAMT053_deposits.add(currDeposit.clone());
                    System.debug('\n\nTHIS IS THE currDeposit to be added: ' + currDeposit); 
                    System.debug('\n ntry tag equals FALSE now');  
                    currDeposit.Raw_data__c = '';
                }
                
                //update scope
                XMLState.leaveLevel(endTag);
            }
            
            reader.next();
            //loop again
        }
        return CAMT053_deposits.deepClone();
    }
                
    
    public class CPQInvalidXML053StringToDateException extends Exception {                
    }
                
    public class CPQInvalidXML053StringToNumberException extends Exception {                
    }
                
                

    
}