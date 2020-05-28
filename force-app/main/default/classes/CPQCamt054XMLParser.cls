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
        currDeposit.clear();
        currDeposit.Bank_Batch_Reference__c = payloadToParse.Name;
        currDeposit.Status__c = 'Open';
        //salesforce doesn't support final vars in switch statements --https://success.salesforce.com/ideaView?id=0873A000000lLkNQAU

        while (reader.hasNext()) {
            if (reader.isStartElement()){
                String startTag = reader.getLocalName().toLowerCase();
                System.debug(startTag);
                //update scope
                XMLState.enterLevel(startTag);

                
                switch on startTag{
                    when 'credttm'{
                        if (XMLState.isWithinLevel(GRPHDR)){
                            System.debug('\n\nHere is the value of credttm start tag ');
                            String credttm = parser.parseFromStream(reader, false); 
                            System.debug('\n' + credttm);
                            try{
                                currDeposit.Import_Date__c = DateTime.valueOf(credttm.replace('T', ' '));
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToDateException('Invalid import date located in xml payload name ' + payloadToParse.Name + '. Invalid import date is within xml element credttm.');
                            }
                            System.debug('\nglobal deposit record updated. Import Date: ' + currDeposit.Import_Date__c);
                        }
                    }
                    when 'id' {
                        if (XMLState.isWithinLevel(NTFCTN) && XMLState.isWithinLevel(CLRSYSMMBID)){
                            System.debug('\n\nHere is the value of id start tag ');
                            String idTag = parser.parseFromStream(reader, false);
                            System.debug('\n' + idTag);
                            currDeposit.Bank_Raw__c = idTag;
                            System.debug('\nglobal deposit record updated. Bank: ' + currDeposit.Bank_Raw__c);
                        }
                    }
                    when 'amt' {
                        if (XMLState.isWithinLevel(NTRY)){
                            System.debug('\n\nHere is the value of amt start tag ');
                            String currencyAttributeValue = parser.parseFromStream(reader, true);
                            String amt = parser.parseFromStream(reader, false);
                            System.debug('\n' + currencyAttributeValue);
                            System.debug('\n' + amt);
                            try{
                                currDeposit.Amount__c = Decimal.valueOf(amt);
                                currDeposit.CurrencyIsoCode = currencyAttributeValue;
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToNumberException('Invalid amount/currency located in xml payload name ' + payloadToParse.Name + '. Invalid amount/currency is within xml element amt.');
                            }
                            System.debug('\nglobal deposit record updated. Amount: ' + currDeposit.Amount__c);
                            System.debug('\nglobal deposit record updated. Currency: ' + currDeposit.CurrencyIsoCode);
                        }
                    }
                    when 'dt' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(BOOKGDT)){
                            System.debug('\n\nHere is the value of dt start tag ');
                            String dt = parser.parseFromStream(reader, false);
                            System.debug('\n' + dt);
                            try{
                                currDeposit.Postmark_Date__c = Date.valueOf(dt);
                            }catch(Exception e){
                                throw new CPQInvalidXML054StringToDateException('Invalid postmark date located in xml payload name ' + payloadToParse.Name + '. Invalid postmark date is within xml element dttm.');
                            }
                            System.debug('\nglobal deposit record updated. Postmark Date: ' + currDeposit.Postmark_Date__c);
                            
                        }
                    }
                    when 'cd'{
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(PRTRY)){
                            String cd = parser.parseFromStream(reader, false);
                            currDeposit.Bank_Batch_Type__c = cd;
                            System.debug('\nglobal deposit record updated. Bank Batch Type: ' + currDeposit.Bank_Batch_Type__c);
                        }
                    }
                    when 'txid' {
                        if (XMLState.isWithinLevel(NTRY)){
                            System.debug('\n\nHere is the value of txid start tag ');
                            String txid = parser.parseFromStream(reader, false);
                            System.debug('\n' + txid);
                            currDeposit.Bank_Reference__c = txid;
                            currDeposit.Name = txid;
                            System.debug('\nglobal deposit record updated. Bank Reference: ' + currDeposit.Bank_Reference__c +
                                        '\nglobal deposit record updated. Deposit Name: ' + currDeposit.Name);
                        }
                    }
                    when 'nm' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of nm start tag ');
                            String nm = parser.parseFromStream(reader, false);
                            System.debug('\n' + nm);
                            currDeposit.Raw_Account_Name__c = nm;
                            System.debug('\nglobal deposit record updated. Raw Account Name: ' + currDeposit.Raw_Account_Name__c);
                        }
                    }
                    when 'adrline' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of adrline start tag ');
                            String adrline = parser.parseFromStream(reader, false);
                            System.debug('\n' + adrline);
                            currDeposit.Additional_Details__c = adrline; 
                            System.debug('\nglobal deposit record updated. Additional Details: ' + currDeposit.Additional_Details__c);
                        }
                    }
                    when 'pstcd' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of pstcd start tag ');
                            String pstcd = parser.parseFromStream(reader, false);
                            System.debug('\n' + pstcd);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + pstcd); 
                            System.debug('\nglobal deposit record updated. Additional Details: ' + currDeposit.Additional_Details__c);
                        }
                    }
                    when 'twnnm' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of pstcd start tag ');
                            String twnnm = parser.parseFromStream(reader, false);
                            System.debug('\n' + twnnm);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + twnnm); 
                            System.debug('\nglobal deposit record updated. Additional Details: ' + currDeposit.Additional_Details__c);
                        }
                    }
                    when 'ctrysubdvsn' {
                        if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of pstcd start tag ');
                            String ctrysubdvsn = parser.parseFromStream(reader, false);
                            System.debug('\n' + ctrysubdvsn);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + ctrysubdvsn); 
                            System.debug('\nglobal deposit record updated. Additional Details: ' + currDeposit.Additional_Details__c);
                        }
                    }
                    when 'ctry' {
                        if (XMLState.isWithinLevel(ACCT)){
                            System.debug('\n\nHere is the value of ACCT ctry start tag ');
                            String ctry = parser.parseFromStream(reader, false);
                            System.debug('\n' + ctry);
                            currDeposit.Bank_Country_Raw__c = ctry;
                        } else if (XMLState.isWithinLevel(NTRY) && XMLState.isWithinLevel(DBTR)){
                            System.debug('\n\nHere is the value of NTRY ctry start tag ');
                            String ctry = parser.parseFromStream(reader, false);
                            System.debug('\n' + ctry);
                            currDeposit.Additional_Details__c = (currDeposit.Additional_Details__c + ctry);
                            System.debug('\nglobal deposit record updated. Additional Details: ' + currDeposit.Additional_Details__c);
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
                //end of switch  
                }    
            //end ifSTART_ELEMENT
            }

            if (reader.isEndElement()){
                String endTag = reader.getLocalName().toLowerCase();
                System.debug(endTag);
                
                //update scope
                XMLState.leaveLevel(endTag);
                if (endTag == NTRY){
                    CAMT054_deposits.add(currDeposit.clone());
                    System.debug('\n\nTHIS IS THE currDeposit to be added: ' + currDeposit); 
                    System.debug('\n ntry tag equals FALSE now');  
                    currDeposit.Raw_data__c = '';
                    currDeposit.Additional_Details__c = '';
                } 
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