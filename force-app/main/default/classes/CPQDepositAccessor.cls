public class CPQDepositAccessor {
    //TODO: Move to new class CPQDepositAccessor; currDeposit should be a parameter not a member variable 
    //helper method
    @testVisible private boolean isValid;


    public boolean isXMLEntryValid(Deposit__c currDeposit, String entryCode){
        if ( currDeposit.Bank_Country_Raw__c == 'US' && (entryCode == '166' || entryCode == '115') ){
            System.debug('\nINVALID US ENTRY: the current bank country is ' + currDeposit.Bank_Country_Raw__c + ' and BAI code is ' + entryCode);
            isValid = false;
            return isValid;
        }else if ( currDeposit.Bank_Country_Raw__c == 'CA' && (entryCode == '165' || entryCode == '142' || entryCode == '115') ){
            System.debug('\nINVALID CA ENTRY: the current bank country is ' + currDeposit.Bank_Country_Raw__c + ' and BAI code is ' + entryCode);
            isValid = false;
            return isValid;
        }else if ( currDeposit.Bank_Country_Raw__c == 'GB' && (entryCode == '166' || entryCode == '115')){
            System.debug('\nINVALID GB/London ENTRY: the current bank country is ' + currDeposit.Bank_Country_Raw__c + ' and BAI code is ' + entryCode);
            isValid = false;
            return isValid;
        }else
            System.debug('\nVALID: bank country is ' + currDeposit.Bank_Country_Raw__c + ' and BAI code is ' + entryCode);
            isValid = true;
            return isValid;
    }
}