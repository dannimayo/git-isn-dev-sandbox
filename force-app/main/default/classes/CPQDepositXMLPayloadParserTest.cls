@isTest
private class CPQDepositXMLPayloadParserTest {

    @isTest static void testParseXMLtoDepositsPositive(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> allPayloadsToParse = CPQPayloadDataFactoryTest.createAll6XMLPayloads();

        //test
        Test.startTest();
        parser.parseToDeposits(allPayloadsToParse);
        List<Deposit__c> insertedDeposits = [SELECT Id FROM Deposit__c];
        Test.stopTest();

        //expect
        System.assert(allPayloadsToParse.size() > 0);
        System.assert(insertedDeposits.size() > 0);  
    }
    
    @isTest static void testParseXMLtoDepositsExpectOneDeposit(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> allPayloadsToParse = new List<Payload__c>();
        Payload__c singleEntryPayload = CPQPayloadDataFactoryTest.createSingleEntryPayload_CAMT053();
        allPayloadsToParse.add(singleEntryPayload);

        //test
        Test.startTest();
        parser.parseToDeposits(allPayloadsToParse);
        List<Deposit__c> insertedDeposits = [SELECT Id FROM Deposit__c];
        Deposit__c d1 = insertedDeposits.get(0);
        Test.stopTest();

        //expect
        System.debug('Size of insertedDeposits is ' + insertedDeposits.size());
        System.debug('Size of allPayloadsToParse is ' + allPayloadsToParse.size());
        System.debug('insertedPayload from testdatafactory is ' + singleEntryPayload);
        System.assertEquals(1, insertedDeposits.size());
    }

    
    @isTest static void testParseXMLtoDepositsNoPayloads(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> allPayloadsToParse;

        //test
        Test.startTest();
        parser.parseToDeposits(allPayloadsToParse);
        List<Deposit__c> insertedDeposits = [SELECT Id FROM Deposit__c];
        Test.stopTest();

        //expect
        System.assert(insertedDeposits.isEmpty(), 'No payloads to process. CPQDepositXMLPayloadParser received 0 payloads.');
    }
    
    @isTest static void testSplitPayloadsPositive(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> all6XMLPayloadTypes = CPQPayloadDataFactoryTest.createAll6XMLPayloads();
        Integer totalPayloadsInput = all6XMLPayloadTypes.size();

        //test
        Test.startTest();
        parser.splitPayloads(all6XMLPayloadTypes);
        Integer totalPayloadsDistributed = ( parser.NA_CAMT052_payloads.size() +
                                            parser.NA_CAMT053_payloads.size() +
                                            parser.CAD_CAMT054_payloads.size() +
                                            parser.US_CAMT054_payloads.size() +
                                            parser.EMEA_CAMT052_payloads.size() +
                                            parser.EMEA_CAMT053_payloads.size() );
        Test.stopTest();

        //expect
        System.assertEquals(1, parser.NA_CAMT052_payloads.size());
        System.assertEquals(1, parser.NA_CAMT053_payloads.size());
        System.assertEquals(1, parser.CAD_CAMT054_payloads.size());
        System.assertEquals(1, parser.US_CAMT054_payloads.size());
        System.assertEquals(1, parser.EMEA_CAMT052_payloads.size());
        System.assertEquals(1, parser.EMEA_CAMT053_payloads.size());
        System.assert(totalPayloadsInput == totalPayloadsDistributed);   
    }
    
    
    @isTest static void testSplitPayloadsHandlesInvalidPayloads(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        Payload__c invalidPayload = CPQPayloadDataFactoryTest.createInvalidNamePayload();
        List<Payload__c> listInvalidPayload = new List<Payload__c>();
        listInvalidPayload.add(invalidPayload);

        
        //test
        test.startTest();
        parser.splitPayloads(listInvalidPayload);
        Integer totalPayloadsDistributed = ( parser.NA_CAMT052_payloads.size() +
                                            parser.NA_CAMT053_payloads.size() +
                                            parser.CAD_CAMT054_payloads.size() +
                                            parser.US_CAMT054_payloads.size() +
                                            parser.EMEA_CAMT052_payloads.size() +
                                            parser.EMEA_CAMT053_payloads.size() );
        test.stopTest();

        //expect
        System.assertEquals(0, totalPayloadsDistributed);
    }
    
    
    @isTest static void testSplitPayloadsHandles0Payloads(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList = new List<Payload__c>();
        
        //test
        test.startTest();
        parser.splitPayloads(emptyPayloadList);
        Integer totalPayloadsDistributed = ( parser.NA_CAMT052_payloads.size() +
                                            parser.NA_CAMT053_payloads.size() +
                                            parser.CAD_CAMT054_payloads.size() +
                                            parser.US_CAMT054_payloads.size() +
                                            parser.EMEA_CAMT052_payloads.size() +
                                            parser.EMEA_CAMT053_payloads.size() );
        test.stopTest();
        
        //expect
        System.assertEquals(0, totalPayloadsDistributed);
    }
    
    
    @isTest static void testParseAll_NA_CAMT053Positive(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> payloadsToParse = CPQPayloadDataFactoryTest.createPayloadList_CAMT053();
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;  
        
        //test
        test.startTest();
        parser.parseAll_NA_CAMT053(payloadsToParse);
        Integer totalPayloadsInput = payloadsToParse.size();
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assert(totalPayloadsInput == count);   
    }
    
    @isTest static void testParseAll_NA_CAMT053noPayloadsToParse(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;
        
        //test
        test.startTest();
        parser.parseAll_NA_CAMT053(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_NA_CAMT053NoDepositsReturned(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;
        
        //test
        test.startTest();
        parser.parseAll_NA_CAMT053(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_EMEA_CAMT053Positive(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> payloadsToParse = CPQPayloadDataFactoryTest.createPayloadList_CAMT053();
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;  
        
        //test
        test.startTest();
        parser.parseAll_EMEA_CAMT053(payloadsToParse);
        Integer totalPayloadsInput = payloadsToParse.size();
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assert(totalPayloadsInput == count);   
    }
    
    @isTest static void testParseAll_EMEA_CAMT053noPayloadsToParse(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;
        
        //test
        test.startTest();
        parser.parseAll_EMEA_CAMT053(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_EMEA_CAMT053NoDepositsReturned(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt053XMLParser mockCamt053 = new MockCPQCamt053XMLParser();
        parser.camt053 = mockCamt053;
        
        //test
        test.startTest();
        parser.parseAll_EMEA_CAMT053(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt053.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_US_CAMT054Positive(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> payloadsToParse = CPQPayloadDataFactoryTest.createPayloadList_CAMT054();
        MockCPQCamt054XMLParser mockCamt054 = new MockCPQCamt054XMLParser();
        parser.camt054 = mockCamt054;  
        
        //test
        test.startTest();
        parser.parseAll_US_CAMT054(payloadsToParse);
        Integer totalPayloadsInput = payloadsToParse.size();
        test.stopTest();
        
        //expect
        Integer count = mockCamt054.callCount;
        System.assert(totalPayloadsInput == count);   
    }
    
    @isTest static void testParseAll_US_CAMT054noPayloadsToParse(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt054XMLParser mockCamt054 = new MockCPQCamt054XMLParser();
        parser.camt054 = mockCamt054;
        
        //test
        test.startTest();
        parser.parseAll_US_CAMT054(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt054.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_US_CAMT054NoDepositsReturned(){
        //setup
        CPQDepositXMLPayloadParser parser = new CPQDepositXMLPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCamt054XMLParser mockCamt054 = new MockCPQCamt054XMLParser();
        parser.camt054 = mockCamt054;
        
        //test
        test.startTest();
        parser.parseAll_US_CAMT054(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCamt054.callCount;
        System.assertEquals(0, count);
    }
    
	
	


    
    

}