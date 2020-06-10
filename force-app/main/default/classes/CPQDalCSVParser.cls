public class CPQDalCSVParser
                implements CPQICSVParser{

    @TestVisible private String delim = ',';
    @TestVisible private String[] csv;
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>();
    @TestVisible private Deposit__c currDeposit = new Deposit__c();
    private static final Integer DAL_importDateRow = 7;
    private static final Integer DAL_amountRow = 14;
    private static final Integer DAL_postmarkDateRow = 27;
    private static final Integer DAL_transUIDRow = 5;
    private static final Integer DAL_timeRow = 8;
    private static final Integer DAL_batchRow = 9;
    private static final Integer DAL_checkRow = 17;
    private static final Integer DAL_remitterNameRow = 28;
    private static final Integer DAL_companyNumRow = 30;
    private static final Integer DAL_rawInvoiceNumRow = 31;
    private static final Integer DAL_transSource = 11;


    public List<Deposit__c> parsePayloadCSVString(Payload__c payloadToParse){
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
            Deposit__c d = convertDALrowToDeposit(rowString, payloadToParse.Name);
            finalDepositList.add(d);
        }

        //5 return deposit list to main class
        return finalDepositList.deepClone();
    }


    @TestVisible private Deposit__c convertDALrowToDeposit(String rowString, String payloadName){
        List<String> row = rowString.split(delim);
        currDeposit.clear();

        currDeposit.Name = row.get(DAL_transUIDRow);
        currDeposit.Bank_Reference__c = payloadName.left(11) + ' - ' + row.get(DAL_importDateRow) + ' - ' + row.get(DAL_timeRow) + ' - ' + row.get(DAL_batchRow);
        currDeposit.Raw_Data__c = rowString;
        currDeposit.Status__c = 'Open';
        currDeposit.Bank_Batch_Reference__c = payloadName;
        currDeposit.Bank_Batch_Type__c = row.get(DAL_transSource);
        currDeposit.Bank_Raw__c = 'BoA : USD';
        currDeposit.Bank_Country_Raw__c = 'US';
        currDeposit.Check_Num__c = row.get(DAL_checkRow);
        currDeposit.CurrencyIsoCode = 'USD';
        currDeposit.Raw_Account_Name__c = row.get(DAL_remitterNameRow).toUpperCase();
        currDeposit.Raw_Invoice_Num__c = row.get(DAL_rawInvoiceNumRow);
        currDeposit.Raw_Account_Num__c = row.get(DAL_companyNumRow);
        String importDate = row.get(DAL_importDateRow);
        if (String.isNotBlank(importDate)){
            try{
                importDate = importDate.replace('/', '-');
                currDeposit.Import_Date__c = Date.valueOf(importDate);
            }catch(Exception e){
                throw new CPQDALParsingInvalidDateException('The following import date string is invalid: ' + importDate + '\nCSV row substring is: ' + rowString);
            }
        }
        String amount = row.get(DAL_amountRow);
        try{
            Decimal amt = Decimal.valueOf(amount.removeStart('$'));
            currDeposit.Amount__c = amt;
        }catch (Exception e){
            throw new CPQDALParsingInvalidAmountException('The following amount string is invalid: ' + amount + '\nCSV row substring is: ' + rowString);
        }
        String postmarkDate = row.get(DAL_postmarkDateRow);
        if (String.isNotBlank(postmarkDate)){
            try{
                postmarkDate = postmarkDate.replace('/', '-');
                currDeposit.Postmark_Date__c = Date.valueOf(postmarkDate);
            }catch(Exception e){
                throw new CPQDALParsingInvalidDateException('The following postmark date string is invalid: ' + postmarkDate + '\nCSV row substring is: ' + rowString);
            }
        }
        
        //DEPOSIT RECORD COMPLETE & SENT TO FINAL DEPOSIT LIST
        return currDeposit.clone();
    }


    public class CPQDALParsingInvalidAmountException extends Exception{  
    }


    public class CPQDALParsingInvalidDateException extends Exception{  
    }


}