@isTest
private class CPQDepositAccessorTest {

    @isTest static void testIsXMLEntryValid_invalidUSEntry(){
        //setup
        CPQDepositAccessor validator = new CPQDepositAccessor();
        Deposit__c testDeposit = new Deposit__c(Bank_Country_Raw__c = 'US');
        String entryCode = '115';
        
        //test
        Boolean isValid = validator.isXMLEntryValid(testDeposit, entryCode);
        
        //expect
        System.assert(isValid == false);
    }
    
    @isTest static void testIsXMLEntryValid_invalidCADEntry(){
        //setup
        CPQDepositAccessor validator = new CPQDepositAccessor();
        Deposit__c testDeposit = new Deposit__c(Bank_Country_Raw__c = 'CA');
        String entryCode = '115';
        
        //test
        Boolean isValid = validator.isXMLEntryValid(testDeposit, entryCode);
        
        //expect
        System.assert(isValid == false);
    }
    
    @isTest static void testIsXMLEntryValid_invalidGBEntry(){
        //setup
        CPQDepositAccessor validator = new CPQDepositAccessor();
        Deposit__c testDeposit = new Deposit__c(Bank_Country_Raw__c = 'GB');
        String entryCode = '115';
        
        //test
        Boolean isValid = validator.isXMLEntryValid(testDeposit, entryCode);
        
        //expect
        System.assert(isValid == false);
    }
    
    @isTest static void testIsXMLEntryValid_ValidCountry(){
        //setup
        CPQDepositAccessor validator = new CPQDepositAccessor();
        Deposit__c testDeposit = new Deposit__c(Bank_Country_Raw__c = 'MX');
        String entryCode = '115';
        
        //test
        Boolean isValid = validator.isXMLEntryValid(testDeposit, entryCode);
        
        //expect
        System.assert(isValid == true);
    }
    

    
    
}