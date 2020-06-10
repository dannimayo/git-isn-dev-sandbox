@isTest
private class CPQDalCSVParserTest {
    
    @isTest static void testParsePayloadCSVStringPositive(){
        //setup
        CPQDalCSVParser parser = new CPQDalCSVParser();
        Payload__c p = CPQPayloadDataFactoryTest.createSingleEntryPayload_DAL();
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
        CPQDALCSVParser parser = new CPQDALCSVParser();
        Payload__c p = CPQPayloadDataFactoryTest.createNoEntryPayload_DAL();
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
    
    @isTest static void convertDALrowToDepositPositive(){
        CPQDalCSVParser parser = new CPQDalCSVParser();
        String rowString = '1,1,1,G-3089001,G-3089001,TB308900b20201030001,DAL-841808,2020/04/13,12:00,4,1,Check,,,$5809.70,113122655,807384054,035728,3,9,,1,,19,,19,,2020/04/09,BULK CARRIERS INC,,,,$5809.70';
        String payloadName = 'DAL__841808_IMG_20200413150632.zip';
        Date importDate = Date.newInstance(2020, 4, 13);
        Date postmarkDate = Date.newInstance(2020, 4, 09);
        
        Test.startTest();
        parser.convertDALrowToDeposit(rowString, payloadName);
        Test.stopTest();
        
        System.assert(parser.currDeposit.Name == 'TB308900b20201030001');
        System.assert(parser.currDeposit.Status__c == 'Open');
        System.assert(parser.currDeposit.Bank_Batch_Reference__c == payloadName);
        System.assert(parser.currDeposit.Bank_Batch_Type__c == 'Check');
        System.assert(parser.currDeposit.Bank_Raw__c == 'BoA : USD');
        System.assert(parser.currDeposit.Bank_Country_Raw__c == 'US');
        System.assert(parser.currDeposit.Check_Num__c == '035728');
        System.assert(parser.currDeposit.CurrencyIsoCode == 'USD');
        System.assert(parser.currDeposit.Import_Date__c == importDate); 
        System.assert(parser.currDeposit.Postmark_Date__c == postmarkDate); 
    }
    
    @isTest static void testConvertDALrowToDepositHandlesInvalidAmount(){
        //setup
        CPQDalCSVParser parser = new CPQDalCSVParser();
        String rowString = '1,1,1,G-3089001,G-3089001,TB308900b20201030001,DAL-841808,2020/04/13,12:00,4,1,Check,,,$invalid0,113122655,807384054,035728,3,9,,1,,19,,19,,2020/04/09,BULK CARRIERS INC,,,,$invalid.70';
        String payloadName = 'DAL__841808_IMG_20200413150632.zip';
        
        //test
        try{
       		Deposit__c d = parser.convertDALrowToDeposit(rowString, payloadName);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQDalCSVParser.CPQDALParsingInvalidAmountException');
        }
    }
    
    @isTest static void testConvertDALrowToDepositHandlesInvalidDate(){
        //setup
        CPQDalCSVParser parser = new CPQDalCSVParser();
        String rowString = '1,1,1,G-3089001,G-3089001,TB308900b20201030001,DAL-841808,invalidDa,12:00,4,1,Check,,,$5809.70,113122655,807384054,035728,3,9,,1,,19,,19,,2020/04/09,BULK CARRIERS INC,,,,$5809.70';
        String payloadName = 'DAL__841808_IMG_20200413150632.zip';
        
        //test
        try{
       		Deposit__c d = parser.convertDALrowToDeposit(rowString, payloadName);
        //expect
        }catch(Exception e){
            String exceptionType = e.getTypeName();
            System.debug(exceptionType);
            System.assert(exceptionType == 'CPQDalCSVParser.CPQDALParsingInvalidDateException');
        }
    }
    
        
    
    

}