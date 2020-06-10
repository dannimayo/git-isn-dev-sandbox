@isTest
private class CPQCamt052XMLParserTest {
    
    @isTest static void testParsePatternCAMT052Positive(){
        //setup
        CPQCamt052XMLParser camt052 = new CPQCamt052XMLParser();
        Payload__c camt052Payload = CPQPayloadDataFactoryTest.createSingleEntryPayload_CAMT052();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        Datetime importDate = DateTime.newInstanceGmt(2020, 4, 30, 12, 7, 41);
        Date postmarkDate = Date.newInstance(2020, 4, 30);
        
        //test
        Test.startTest();
        createdDeposits = camt052.parsePatternCAMT052(camt052Payload);
        Test.stopTest();

        //expect
        System.assertEquals(1,camt052.CAMT052_deposits.size());
        System.assert(camt052.currDeposit.Name == '6008121DA902');
        System.assert(camt052.currDeposit.Bank_Reference__c == '6008121DA902');
        System.assert(camt052.currDeposit.CurrencyIsoCode == 'USD');
        System.assert(camt052.currDeposit.Amount__c == 5750.00);
        System.assert(camt052.currDeposit.Bank_Raw__c == 'Bank of America, London');
        System.assert(camt052.currDeposit.Bank_Country_Raw__c == 'GB');
        System.assert(camt052.currDeposit.Status__c == 'Open');
        System.assert(camt052.currDeposit.Bank_Batch_Reference__c == camt052Payload.Name);
        System.assert(camt052.currDeposit.Bank_Batch_Type__c == 'Transfer');   
        System.assert(camt052.currDeposit.Import_Date__c == importDate);
        System.assert(camt052.currDeposit.Postmark_Date__c == postmarkDate);  
    }
    
    @isTest static void testParsePatternCAMT052HandleInvalidDates(){
        //setup
        CPQCamt052XMLParser camt052 = new CPQCamt052XMLParser();
        Payload__c camt052Payload = CPQPayloadDataFactoryTest.createInvalidDatePayload_CAMT052();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        
        //test
        try{
        	createdDeposits = camt052.parsePatternCAMT052(camt052Payload);  
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt052XMLParser.CPQInvalidXML052StringToDateException');
        }
    }
    
    @isTest static void testParsePatternCAMT052HandleInvalidAmount(){
        //setup
        CPQCamt052XMLParser camt052 = new CPQCamt052XMLParser();
        Payload__c camt052Payload = CPQPayloadDataFactoryTest.createInvalidAmountPayload_CAMT052();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        String errorMsg;
        
        //test
        try{
        	createdDeposits = camt052.parsePatternCAMT052(camt052Payload);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt052XMLParser.CPQInvalidXML052StringToNumberException');
        }
    }
    
    
    

}