//refactor and create interface
public class CPQCalCSVParser {

    @TestVisible private String delim = ',';
    @TestVisible private String[] csv;
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();
    private static final Integer CAL_importDateRow = 7;
    private static final Integer CAL_amountRow = 14;
    private static final Integer CAL_postmarkDateRow = 28;
    private static final Integer CAL_transUIDRow = 5;
    private static final Integer CAL_timeRow = 8;
    private static final Integer CAL_batchRow = 9;
    private static final Integer CAL_checkRow = 17;
    private static final Integer CAL_remitterNameRow = 27;
    private static final Integer CAL_companyNumRow = 32;
    private static final Integer CAL_rawInvoiceNumRow = 29;
    private static final Integer CAL_transSource = 11;


    public List<Deposit__c> parseCALPatternCSVString(Payload__c payloadToParse){
        //0
        finalDepositList.clear();

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
            Deposit__c d = convertCALrowToDeposit(rowString, payloadToParse.Name);
            finalDepositList.add(d);
        }

        //5 return deposit list to main class
        return finalDepositList.deepClone();
    }


    private Deposit__c convertCALrowToDeposit(String rowString, String payloadName){
        List<String> row = rowString.split(delim);
        currDeposit.clear();

        currDeposit.Name = row.get(CAL_transUIDRow);
        currDeposit.Bank_Reference__c = payloadName.left(11) + ' - ' + row.get(CAL_importDateRow) + ' - ' + row.get(CAL_timeRow) + ' - ' + row.get(CAL_batchRow);
        currDeposit.Raw_Data__c = rowString;
        currDeposit.Status__c = 'Open';
        currDeposit.Bank_Batch_Reference__c = payloadName;
        currDeposit.Bank_Batch_Type__c = row.get(CAL_transSource);
        currDeposit.Bank_Raw__c = 'BoA : CAD';
        currDeposit.Bank_Country_Raw__c = 'CA';
        currDeposit.Check_Num__c = row.get(CAL_checkRow);
        currDeposit.CurrencyIsoCode = 'CAD';
        currDeposit.Raw_Account_Name__c = row.get(CAL_remitterNameRow).toUpperCase();
        currDeposit.Raw_Invoice_Num__c = row.get(CAL_rawInvoiceNumRow);
        if (row.size()> 32)
            currDeposit.Raw_Account_Num__c = row.get(CAL_companyNumRow);
        String importDate = row.get(CAL_importDateRow);
        if (String.isNotBlank(importDate)){
            try{
                importDate = importDate.replace('/', '-');
                currDeposit.Import_Date__c = Date.valueOf(importDate);
            }catch(Exception e){throw new CPQCALParsingInvalidDateException('The following import date string is invalid: ' + importDate + '\nCSV row substring is: ' + rowString); }
        }
        String amount = row.get(CAL_amountRow);
        try{
            Decimal amt = Decimal.valueOf(amount.removeStart('$'));
            currDeposit.Amount__c = amt;
        }catch (Exception e){ throw new CPQCALParsingInvalidAmountException('The following amount string is invalid: ' + amount + '\nCSV row substring is: ' + rowString); }
        String postmarkDate = row.get(CAL_postmarkDateRow);
        if (String.isNotBlank(postmarkDate)){
            try{
                postmarkDate = postmarkDate.replace('/', '-');
                currDeposit.Postmark_Date__c = Date.valueOf(postmarkDate);
            }catch(Exception e){ throw new CPQCALParsingInvalidDateException('The following postmark date string is invalid: ' + postmarkDate + '\nCSV row substring is: ' + rowString); }
        }
        
        //DEPOSIT RECORD COMPLETE & SENT TO FINAL DEPOSIT LIST
        return currDeposit.clone();
    }


    public class CPQCALParsingInvalidAmountException extends Exception{  
    }


    public class CPQCALParsingInvalidDateException extends Exception{  
    }


}
