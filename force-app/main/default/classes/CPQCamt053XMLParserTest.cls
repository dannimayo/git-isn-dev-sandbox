@isTest
private class CPQCamt053XMLParserTest {
    
    @isTest static void testParsePatternCAMT053Positive(){
        //setup
        CPQCamt053XMLParser camt053 = new CPQCamt053XMLParser();
        Payload__c camt053Payload = CPQXMLDataFactoryTest.createSingleEntryPayload_CAMT053();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        Datetime importDate = DateTime.newInstanceGmt(2020, 5, 4, 12, 4, 7);
        Date postmarkDate = Date.newInstance(2020, 5, 1);
        
        //test
        Test.startTest();
        createdDeposits = camt053.parsePatternCAMT053(camt053Payload);
        Test.stopTest();

        //expect
        System.assertEquals(1,camt053.CAMT053_deposits.size());
        System.assert(camt053.currDeposit.Name == '813000051109816');
        System.assert(camt053.currDeposit.Bank_Reference__c == '813000051109816');
        System.assert(camt053.currDeposit.CurrencyIsoCode == 'USD');
        System.assert(camt053.currDeposit.Amount__c == 155684.50);
        System.assert(camt053.currDeposit.Bank_Raw__c == 'Bank of America, Texas');
        System.assert(camt053.currDeposit.Bank_Country_Raw__c == 'US');
        System.assert(camt053.currDeposit.Status__c == 'Open');
        System.assert(camt053.currDeposit.Bank_Batch_Reference__c == camt053Payload.Name);
        System.assert(camt053.currDeposit.Bank_Batch_Type__c == 'Transfer');   
        System.assert(camt053.currDeposit.Import_Date__c == importDate);
        System.assert(camt053.currDeposit.Postmark_Date__c == postmarkDate);  
    }
    
    @isTest static void testParsePatternCAMT053HandleInvalidDates(){
        //setup
        CPQCamt053XMLParser camt053 = new CPQCamt053XMLParser();
        Payload__c camt053Payload = CPQXMLDataFactoryTest.createInvalidDatePayload_CAMT053();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        String errorMsg;
        
        //test
        try{
        	createdDeposits = camt053.parsePatternCAMT053(camt053Payload);  
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt053XMLParser.CPQInvalidXML053StringToDateException');
        }
    }
    
    @isTest static void testParsePatternCAMT053HandleInvalidAmount(){
        //setup
        CPQCamt053XMLParser camt053 = new CPQCamt053XMLParser();
        Payload__c camt053Payload = CPQXMLDataFactoryTest.createInvalidAmountPayload_CAMT053();
        List<Deposit__c> createdDeposits = new List<Deposit__c>();
        String errorMsg;
        
        //test
        try{
       		createdDeposits = camt053.parsePatternCAMT053(camt053Payload);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCamt053XMLParser.CPQInvalidXML053StringToNumberException');
        }
    }
    
    
    

}