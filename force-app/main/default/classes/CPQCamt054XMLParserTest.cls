@isTest
private class CPQCamt054XMLParserTest {
    
    @isTest static void testParsePatternCAMT054Positive(){
        //setup
        CPQCamt054XMLParser camt054 = new CPQCamt054XMLParser();
        Payload__c camt054Payload = CPQXMLDataFactoryTest.createSingleEntryPayload_CAMT054();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        Datetime importDate = DateTime.newInstanceGmt(2020, 4, 30, 10, 42, 45);
        Date postmarkDate = Date.newInstance(2020, 4, 30);
        
        //test
        Test.startTest();
        createdDeposits = camt054.parsePatternCAMT054(camt054Payload);
        Test.stopTest();

        //expect
        System.assertEquals(1,camt054.CAMT054_deposits.size());
        System.assert(camt054.currDeposit.Name == '2000003852USX1');
        System.assert(camt054.currDeposit.Bank_Reference__c == '2000003852USX1');
        System.assert(camt054.currDeposit.CurrencyIsoCode == 'USD');
        System.assert(camt054.currDeposit.Amount__c == 3400);
        System.assert(camt054.currDeposit.Bank_Raw__c == 'USABA111000025');
        System.assert(camt054.currDeposit.Bank_Country_Raw__c == 'US');
        System.assert(camt054.currDeposit.Status__c == 'Open');
        System.assert(camt054.currDeposit.Bank_Batch_Reference__c == camt054Payload.Name);
        System.assert(camt054.currDeposit.Bank_Batch_Type__c == 'ACH/LOW VALUE - CTX');   
        System.assert(camt054.currDeposit.Import_Date__c == importDate);
        System.assert(camt054.currDeposit.Postmark_Date__c == postmarkDate);      
    }
    
    @isTest static void testParsePatternCAMT054HandleInvalidDates(){
        //setup
        CPQCamt054XMLParser camt054 = new CPQCamt054XMLParser();
        Payload__c camt054Payload = CPQXMLDataFactoryTest.createInvalidDatePayload_CAMT054();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        String errorMsg;
        
        //test

        try{
        	createdDeposits = camt054.parsePatternCAMT054(camt054Payload);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt054XMLParser.CPQInvalidXML054StringToDateException');
        }
    }
    
    @isTest static void testParsePatternCAMT054HandleInvalidAmount(){
        //setup
        CPQCamt054XMLParser camt054 = new CPQCamt054XMLParser();
        Payload__c camt054Payload = CPQXMLDataFactoryTest.createInvalidAmountPayload_CAMT054();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        String errorMsg;
        
        //test
   
        try{
        	createdDeposits = camt054.parsePatternCAMT054(camt054Payload);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt054XMLParser.CPQInvalidXML054StringToNumberException');
        }
    }
    
    
    

}