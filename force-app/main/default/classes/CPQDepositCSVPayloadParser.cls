public class CPQDepositCSVPayloadParser 
                implements CPQIDepositPayloadParser {

    @TestVisible CPQICSVParser CALparser = new CPQCalCSVParser();   
    @TestVisible CPQICSVParser DALparser = new CPQDalCSVParser();

    @TestVisible private List<Payload__c> CAL_payloads = new List<Payload__c>();  
    @TestVisible private List<Payload__c> DAL_payloads = new List<Payload__c>();
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>(); 
    

    public void parseToDeposits(List<Payload__c> allPayloadsToParse){

        //clear cache
        CAL_payloads.clear();
        DAL_payloads.clear();
        finalDepositList.clear();

        //process
        splitPayloads(allPayloadsToParse); 
        parseAll_CAL(CAL_payloads);
        parseAll_DAL(DAL_payloads);
        
        //return all deposits to insert, til then.. insert list here
        if(finalDepositList != null && !finalDepositList.isEmpty())
        	insert finalDepositList;
        
        //mark all payloads as processed
    }


    @TestVisible private void splitPayloads(List<Payload__c> allPayloadsToSplit){ 
        if(allPayloadsToSplit != null && !allPayloadsToSplit.isEmpty()){
            for ( Payload__c iteratedPayload : allPayloadsToSplit){
                String fileName = (iteratedPayload.Name).toLowerCase();
    
                if ( fileName.contains('cal') ){
                    CAL_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('dal') ){
                    DAL_payloads.add(iteratedPayload);
                } else {
                    System.debug('A payload of unknown type has been detected. Here is the payload name: ' + iteratedPayload.Name);
                }
            } 
        } else {
            System.debug('No payloads to process. CPQDepositCSVPayloadParser received 0 payloads.');
        }
    }


    @TestVisible private void parseAll_CAL(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> CAL_deposits = CALparser.parsePayloadCSVString(currPayload);
                    if (CAL_deposits != null && !CAL_deposits.isEmpty()){
                        finalDepositList.addAll(CAL_deposits);
                    }
                }
            } 
        } else 
            System.debug('No CAL format payloads to parse');
    }


    @TestVisible private void parseAll_DAL(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> DAL_deposits = DALparser.parsePayloadCSVString(currPayload);
                    if (DAL_deposits != null && !DAL_deposits.isEmpty()){
                        finalDepositList.addAll(DAL_deposits);
                    }
                }
            } 
        } else 
            System.debug('No DAL format payloads to parse');
    }
                               
    



}