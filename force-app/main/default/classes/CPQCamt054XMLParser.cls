public class CPQCamt054XMLParser 
            implements CPQICamt054Parser{

    private static final String GRPHDR = 'grphdr';
    private static final String NTFCTN = 'ntfctn';
    private static final String ACCT = 'acct';
    private static final String DBTR = 'dbtr';
    private static final String PRTRY = 'prtry';
    private static final String CLRSYSMMBID = 'clrsysmmbid';
    private static final String BOOKGDT = 'bookgdt';
    private static final String NTRY = 'ntry';
                
    @TestVisible private CPQPaymentParserState XMLState = new CPQPaymentParserState();
    @TestVisible private CPQXMLParser parser = new CPQXMLParser();
    @TestVisible private List<Deposit__c> CAMT054_deposits = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();
                

    public List<Deposit__c> parsePatternCAMT054(Payload__c payloadToParse){

        XmlStreamReader reader = new XmlStreamReader(payloadToParse.Payload__c);
        CAMT054_deposits.clear();
        currDeposit.clear();
        currDeposit.Bank_Batch_Reference__c = payloadToParse.Name;
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
                            String credttm = parser.parseFromStream(reader, false); 
                            try{
                                currDeposit.Import_Date__c = DateTime.valueOf(credttm.replace('T', ' '));
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToDateException('Invalid import date located in xml payload name ' + payloadToParse.Name + '. Invalid import date is within xml element credttm.');
                            }
                        }
                    }
                    when 'id' {
                        if (XMLState.isWithinLevel(NTFCTN) && XMLState.isWithinLevel(CLRSYSMMBID)){
                            String idTag = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Raw__c = idTag;
                        }
                    }
                    when 'amt' {
                        if (XMLState.isWithinLevel(NTRY)){
                            String currencyAttributeValue = parser.parseFromStream(reader, true);
                            String amt = parser.parseFromStream(reader, false);
                            try{
                                currDeposit.Amount__c = Decimal.valueOf(amt);
                                currDeposit.CurrencyIsoCode = currencyAttributeValue;
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToNumberException('Invalid amount/currency located in xml payload name ' + payloadToParse.Name + '. Invalid amount/currency is within xml element amt.');
                            }
                        }
                    }
                    when 'dt' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(BOOKGDT)){
                            String dt = parser.parseFromStream(reader, false);
                            try{
                                currDeposit.Postmark_Date__c = Date.valueOf(dt);
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToDateException('Invalid postmark date located in xml payload name ' + payloadToParse.Name + '. Invalid postmark date is within xml element dttm.');
                            }
                        }
                    }
                    when 'cd'{
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(PRTRY)){
                            String cd = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Batch_Type__c = cd;
                        }
                    }
                    when 'txid' {
                        if (XMLState.isWithinLevel(NTRY)){
                            String txid = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Reference__c = txid;
                            currDeposit.Name = txid;
                        }
                    }
                    when 'nm' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String nm = parser.parseFromStream(reader, false);
                            currDeposit.Raw_Account_Name__c = nm;
                        }
                    }
                    when 'adrline' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String adrline = parser.parseFromStream(reader, false);
                            currDeposit.Additional_Details__c = adrline; 
                        }
                    }
                    when 'pstcd' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String pstcd = parser.parseFromStream(reader, false);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + pstcd); 
                        }
                    }
                    when 'twnnm' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String twnnm = parser.parseFromStream(reader, false);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + twnnm); 
                        }
                    }
                    when 'ctrysubdvsn' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String ctrysubdvsn = parser.parseFromStream(reader, false);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + ctrysubdvsn);
                        }
                    }
                    when 'ctry' {
                        if (XMLState.isWithinLevel(ACCT)){
                            String ctry = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Country_Raw__c = ctry;
                        } else if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            String ctry = parser.parseFromStream(reader, false);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + ctry);
                        }
                    }
                    when 'ustrd' {
                        if (XMLState.isWithinLevel(NTRY)){
                            String ustrd = parser.parseFromStream(reader, false);
                            currDeposit.Raw_data__c = (currDeposit.Raw_data__c + ustrd);
                        }
                    }
                //end of switch  
                }    
            //end ifSTART_ELEMENT
            }

            if (reader.isEndElement()){
                String endTag = reader.getLocalName().toLowerCase();
                if (endTag == NTRY){
                    CAMT054_deposits.add(currDeposit.clone());  
                    currDeposit.Raw_data__c = '';
                    currDeposit.Additional_Details__c = '';
                } 
                //update scope
                XMLState.leaveLevel(endTag);
            }

            reader.next();
            //loop again
        }
        return CAMT054_deposits.deepClone();
    }
                
                
    public class CPQInvalidXML054StringToDateException extends Exception {                
    }
                
    public class CPQInvalidXML054StringToNumberException extends Exception {                
    }


}