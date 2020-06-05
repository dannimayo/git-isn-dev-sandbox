public class CPQDepositCSVPayloadParser {

    @TestVisible private List<Payload__c> CAL_payloads = new List<Payload__c>();  
    @TestVisible private List<Payload__c> DAL_payloads = new List<Payload__c>();

    //@TestVisible CPQCalCSVParser CALparser = new CPQCalCSVParser();   
    @TestVisible CPQDalCSVParser DALparser = new CPQDalCSVParser();
 
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>(); 
    
    public void parseCSVtoDeposits(List<Payload__c> allPayloadsToParse){

        splitPayloads(allPayloadsToParse); 
        //parseAll_CAL(CAL_payloads);
        parseAll_DAL(DAL_payloads);
        

        //return all deposits to insert, til then.. insert list here
        
        //insert finalDepositList;
        
        //mark all payloads as processed
    }


    @TestVisible private void splitPayloads(List<Payload__c> allPayloadsToSplit){ 
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
    }


    @TestVisible private void parseAll_DAL(List<Payload__c> payloadsToParse){ 
        for (Payload__c currPayload: payloadsToParse){
            if (String.isNotBlank(currPayload.Payload__c)){
                List<Deposit__c> DAL_deposits = DALparser.parseDalPatternCSVString(currPayload);
                    finalDepositList.addAll(DAL_deposits);
            }
        } 
    }


    
    



}
