//refactor and create interface
public class CPQCSVParser {

    @TestVisible private String delim = ',';
    @TestVisible private String[] csv;
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();


    public List<Deposit__c> parseCSV(Payload__c payloadToParse){
        //1 split string by '\n'
        this.csv = payloadToParse.Payload__c.toLowerCase().split('\n');
      
        //2 clear null rows & correspondence rows from csv
        for(Integer rowCount = 0; rowCount < csv.size() ; rowCount++){
            String rowString = csv.get(rowCount);
            if( String.isBlank(rowString) || rowString.contains('correspondence')){
                csv.remove(rowCount);
                rowCount--;
            } 
        }
        
        //3 discard header columns (top 3 are header columns)
        for (integer removeCount = 0; removeCount < 3; removeCount++){
            csv.remove(0);
        }
        
        //4 parse each individual row into a deposit
        for(String rowString: csv){
            Deposit__c d = DALrowToDeposit(rowString, payloadToParse.Name);
            finalDepositList.add(d);
        }
        
        //debug stuff
        System.debug('The following is the final list AFTER removing blank & correspondence\n\n\n');
        for (Integer i = 0; i < csv.size() ; i++){
            System.debug('\nThe following is row ' + i + ' : ' + csv.get(i));
        }
        System.debug('All rows output.');

        //5 return deposit list to main class
        return finalDepositList.deepClone();
    }


    private Deposit__c DALrowToDeposit(String rowString, String payloadName){
        List<String> row = rowString.split(',');
        currDeposit.clear();

        // --keep payloadName for Bank_Reference__c

        //row 7 DATE - '4/13/2020' --Import_Date__c
        String importDate = row.get(7);
        importDate = importDate.replace('/', '-');
        currDeposit.Import_Date__c = Date.valueOf(importDate);
        System.debug('Import Date is ' + importDate);
        // --Bank_Raw__c
        currDeposit.Bank_Raw__c = 'BoA : USD';
        // --Bank_Country_Raw__c
        currDeposit.Bank_Country_Raw__c = 'US';
        //row 14 Amount - $5809.70  --Amount__c
        String amount = row.get(14);
        Decimal amt = Decimal.valueOf(amount.removeStart('$'));
        currDeposit.Amount__c = amt;
        System.debug('Amount is ' + amount);
        // --CurrencyIsoCode
        currDeposit.CurrencyIsoCode = 'USD';
        //row 27 Postmark Date - 4/9/2020 --Postmark_Date__c
        String postmarkDate = row.get(27);
        if (String.isNotBlank(postmarkDate)){
            postmarkDate = postmarkDate.replace('/', '-');
            currDeposit.Postmark_Date__c = Date.valueOf(postmarkDate);
        }
        System.debug('Postmark Date is ' + postmarkDate);
        //row 5 Trans UID - TB260700b20201020001 --Deposit.Name
        String transUID = row.get(5);
        currDeposit.Name = transUID;
        System.debug('Trans UID or deposit name is ' + transUID);
        //lockboxName + row 7 'Date' + row 8 'Time' + row 9 'Batch'
        String refDate = row.get(7);
        String refTime = row.get(8);
        String refBatch = row.get(9);
        String bankReference = payloadName.left(11) + ' - ' + refDate + ' - ' + refTime + ' - ' + refBatch;
        currDeposit.Bank_Reference__c = bankReference;
        System.debug('Bank Reference is ' + bankReference);
        //row 17 --Check_Num__c
        String checkNum = row.get(17);
        currDeposit.Check_Num__c = checkNum;
        System.debug('Check num is ' + checkNum);
        //row 28 Remitter Name --Raw_Account_Name__c
        String remitterName = row.get(28);
        currDeposit.Raw_Account_Name__c = remitterName.toUpperCase();
        System.debug('Remitter Name or raw account name is ' + remitterName);
        //row 30 Company # --Raw_Account_Num__c
        String companyNum = row.get(30);
        currDeposit.Raw_Account_Num__c = companyNum;
        System.debug('Company # or raw account num is ' + companyNum);
        //row 31 Inv # -01-1149669734 or 11155244933 or 79698957-2020 or 1-1170089032 --Raw_Invoice_Num__c
        String rawInvoiceNum = row.get(31);
        currDeposit.Raw_Invoice_Num__c = rawInvoiceNum;
        System.debug('Raw Inv # is ' + rawInvoiceNum);
        //row 11 Trans Source -Check --Bank_Batch_Type__c
        String transSource = row.get(11);
        currDeposit.Bank_Batch_Type__c = transSource;
        System.debug('transsource or Bank Batch Type is ' + transSource);
        // --Bank_Batch_Reference__c
        currDeposit.Bank_Batch_Reference__c = payloadName;
        // --Status__c
        currDeposit.Status__c = 'Open';
        // --Raw_Data__c
        currDeposit.Raw_Data__c = rowString;


        System.debug('\nDEPOSIT RECORD COMPLETE & SENT TO FINAL DEPOSIT LIST\n');
        return currDeposit.clone();
    }



}
