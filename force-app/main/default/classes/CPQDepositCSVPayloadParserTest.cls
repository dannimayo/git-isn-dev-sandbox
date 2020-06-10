@isTest
private class CPQDepositCSVPayloadParserTest {
    
    @isTest static void testParseCSVtoDepositsPositive(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> allPayloadsToParse = CPQPayloadDataFactoryTest.createAllCSVPayloads();

        //test
        Test.startTest();
        parser.parseToDeposits(allPayloadsToParse);
        List<Deposit__c> insertedDeposits = [SELECT Id FROM Deposit__c];
        Test.stopTest();

        //expect
        System.assert(allPayloadsToParse.size() > 0);
        System.assert(insertedDeposits.size() > 0);  
    }
    
    @isTest static void testParseCSVtoDepositsExpectOneDeposit(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> allPayloadsToParse = new List<Payload__c>();
        Payload__c singleEntryPayload = CPQPayloadDataFactoryTest.createSingleEntryPayload_CAL();
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
    
    @isTest static void testParseCSVtoDepositsNoPayloads(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> allPayloadsToParse;

        //test
        Test.startTest();
        parser.parseToDeposits(allPayloadsToParse);
        List<Deposit__c> insertedDeposits = [SELECT Id FROM Deposit__c];
        Test.stopTest();

        //expect
        System.assert(insertedDeposits.isEmpty(), 'No payloads to process. CPQDepositCSVPayloadParser received 0 payloads.');
    }
    
    @isTest static void testSplitPayloadsPositive(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> allCSVPayloadTypes = CPQPayloadDataFactoryTest.createAllCSVPayloads();
        Integer totalPayloadsInput = allCSVPayloadTypes.size();

        //test
        Test.startTest();
        parser.splitPayloads(allCSVPayloadTypes);
        Integer totalPayloadsDistributed = ( parser.CAL_payloads.size() +
                                            parser.DAL_payloads.size() );
        Test.stopTest();

        //expect
        System.assertEquals(1, parser.CAL_payloads.size());
        System.assertEquals(1, parser.DAL_payloads.size());
        System.assert(totalPayloadsInput == totalPayloadsDistributed);   
    }
    
    @isTest static void testSplitPayloadsHandles0Payloads(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> emptyPayloadList = new List<Payload__c>();
        
        //test
        test.startTest();
        parser.splitPayloads(emptyPayloadList);
        Integer totalPayloadsDistributed = ( parser.CAL_payloads.size() +
                                            parser.DAL_payloads.size() );
        test.stopTest();
        
        //expect
        System.assertEquals(0, totalPayloadsDistributed);
    }
    
    @isTest static void testParseAll_CALPositive(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        Payload__c p1 =  CPQPayloadDataFactoryTest.createPayload_CAL();
        List<Payload__c> payloadsToParse = new List<Payload__c>();
        payloadsToParse.add(p1);
        
        MockCPQCSVParser mockCAL = new MockCPQCSVParser();
        parser.CALparser = mockCAL;  
        
        //test
        test.startTest();
        parser.parseAll_CAL(payloadsToParse);
        Integer totalPayloadsInput = payloadsToParse.size();
        test.stopTest();
        
        //expect
        Integer count = mockCAL.callCount;
        System.assert(totalPayloadsInput == count);   
    }
    
    @isTest static void testParseAll_CALnoPayloadsToParse(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCSVParser mockCAL = new MockCPQCSVParser();
        parser.CALparser = mockCAL;
        
        //test
        test.startTest();
        parser.parseAll_CAL(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockCAL.callCount;
        System.assertEquals(0, count);
    }
    
    @isTest static void testParseAll_DALPositive(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        Payload__c p1 =  CPQPayloadDataFactoryTest.createPayload_DAL();
        List<Payload__c> payloadsToParse = new List<Payload__c>();
        payloadsToParse.add(p1);
        
        MockCPQCSVParser mockDAL = new MockCPQCSVParser();
        parser.DALparser = mockDAL;  
        
        //test
        test.startTest();
        parser.parseAll_DAL(payloadsToParse);
        Integer totalPayloadsInput = payloadsToParse.size();
        test.stopTest();
        
        //expect
        Integer count = mockDAL.callCount;
        System.assert(totalPayloadsInput == count);   
    }
    
    @isTest static void testParseAll_DALnoPayloadsToParse(){
        //setup
        CPQDepositCSVPayloadParser parser = new CPQDepositCSVPayloadParser();
        List<Payload__c> emptyPayloadList;
        MockCPQCSVParser mockDAL = new MockCPQCSVParser();
        parser.DALparser = mockDAL;
        
        //test
        test.startTest();
        parser.parseAll_DAL(emptyPayloadList);
        test.stopTest();
        
        //expect
        Integer count = mockDAL.callCount;
        System.assertEquals(0, count);
    }

}