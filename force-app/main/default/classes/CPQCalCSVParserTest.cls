@isTest
private class CPQCalCSVParserTest {
    
    @isTest static void testParsePayloadCSVStringPositive(){
        //setup
        CPQCalCSVParser parser = new CPQCalCSVParser();
        Payload__c p = CPQPayloadDataFactoryTest.createSingleEntryPayload_CAL();
        List<Deposit__c> dList;

        //test
        Test.startTest();
        dList = parser.parsePayloadCSVString(p);
        Test.stopTest();

        //expect
        System.assertEquals(1, parser.csv.size());
        System.assertEquals(1, parser.finalDepositList.size());
        System.assertEquals(1, dList.size());
    }
    
    @isTest static void testParsePayloadCSVStringNoDeposits(){
        //setup
        CPQCalCSVParser parser = new CPQCalCSVParser();
        Payload__c p = CPQPayloadDataFactoryTest.createNoEntryPayload_CAL();
        List<Deposit__c> dList;

        //test
        Test.startTest();
        dList = parser.parsePayloadCSVString(p);
        Test.stopTest();

        //expect
        System.assertEquals(0, parser.csv.size());
        System.assertEquals(0, parser.finalDepositList.size());
        System.assertEquals(0, dList.size());
    }
    
    @isTest static void convertCALrowToDepositPositive(){
        CPQCalCSVParser parser = new CPQCalCSVParser();
        String rowString = '1,1,1,G-3009001,G-3009001,TA300958a20201000001,CAL-310390,2020/04/13,11:00,1,1,Check,,,$1254.40,07040-010,4827813,002621,3,9,,1,1b,9,,,,531088 B C LTD,2020/03/31,2-1128441329,$1254.40,BALLAST HOLDINGS';
        String payloadName = 'CAL-310390_20200413111931.zip';
        Date importDate = Date.newInstance(2020, 4, 13);
        Date postmarkDate = Date.newInstance(2020, 3, 31);
        
        Test.startTest();
        parser.convertCALrowToDeposit(rowString, payloadName);
        Test.stopTest();

        System.assert(parser.currDeposit.Name == 'TA300958a20201000001');
        System.assert(parser.currDeposit.Status__c == 'Open');
        System.assert(parser.currDeposit.Bank_Batch_Reference__c == payloadName);
        System.assert(parser.currDeposit.Bank_Batch_Type__c == 'Check');
        System.assert(parser.currDeposit.Bank_Raw__c == 'BoA : CAD');
        System.assert(parser.currDeposit.Bank_Country_Raw__c == 'CA');
        System.assert(parser.currDeposit.Check_Num__c == '002621');
        System.assert(parser.currDeposit.CurrencyIsoCode == 'CAD');
        System.assert(parser.currDeposit.Import_Date__c == importDate); 
        System.assert(parser.currDeposit.Postmark_Date__c == postmarkDate); 
    }
    
    @isTest static void testConvertCALrowToDepositHandlesInvalidAmount(){
        //setup
        CPQCalCSVParser parser = new CPQCalCSVParser();
        String rowString = '1,1,1,G-3009001,G-3009001,TA300958a20201000001,CAL-310390,2020/04/13,11:00,1,1,Check,,,$invalid,07040-010,4827813,002621,3,9,,1,1b,9,,,,531088 B C LTD,2020/03/31,2-1128441329,$invalid,BALLAST HOLDINGS';
        String payloadName = 'CAL-310390_20200413111931.zip';
        
        //test
        try{
       		Deposit__c d = parser.convertCALrowToDeposit(rowString, payloadName);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCalCSVParser.CPQCALParsingInvalidAmountException');
        }
    }
    
    @isTest static void testConvertCALrowToDepositHandlesInvalidDate(){
        //setup
        CPQCalCSVParser parser = new CPQCalCSVParser();
        String rowString = '1,1,1,G-3009001,G-3009001,TA300958a20201000001,CAL-310390,invalidD,11:00,1,1,Check,,,$1254.40,07040-010,4827813,002621,3,9,,1,1b,9,,,,531088 B C LTD,2020/03/31,2-1128441329,$1254.40,BALLAST HOLDINGS';
        String payloadName = 'CAL-310390_20200413111931.zip';
        
        //test
        try{
       		Deposit__c d = parser.convertCALrowToDeposit(rowString, payloadName);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQCalCSVParser.CPQCALParsingInvalidDateException');
        }
    }
    
        
    
    

}