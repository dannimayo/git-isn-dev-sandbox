public class CPQDepositXMLPayloadParser 
                implements CPQIDepositPayloadParser {
    
    @TestVisible private CPQICamt052Parser camt052 = new CPQCamt052XMLParser();          
    @TestVisible private CPQICamt053Parser camt053 = new CPQCamt053XMLParser();
    @TestVisible private CPQICamt054Parser camt054 = new CPQCamt054XMLParser();

    @TestVisible private List<Payload__c> NA_CAMT052_payloads = new List<Payload__c>();  
    @TestVisible private List<Payload__c> NA_CAMT053_payloads = new List<Payload__c>();  
    @TestVisible private List<Payload__c> CAD_CAMT054_payloads = new List<Payload__c>(); 
    @TestVisible private List<Payload__c> US_CAMT054_payloads = new List<Payload__c>();  
    @TestVisible private List<Payload__c> EMEA_CAMT052_payloads = new List<Payload__c>(); 
    @TestVisible private List<Payload__c> EMEA_CAMT053_payloads = new List<Payload__c>(); 
    @TestVisible private List<Deposit__c> finalDepositList = new List<Deposit__c>();  


    public void parseToDeposits(List<Payload__c> allPayloadsToParse){

        //clear cache
        NA_CAMT052_payloads.clear();
        NA_CAMT053_payloads.clear();
        CAD_CAMT054_payloads.clear();
        US_CAMT054_payloads.clear();
        EMEA_CAMT052_payloads.clear();
        EMEA_CAMT053_payloads.clear();
        finalDepositList.clear();

        //process
        splitPayloads(allPayloadsToParse); 
        parseAll_NA_CAMT052(NA_CAMT052_payloads);
        parseAll_EMEA_CAMT052(EMEA_CAMT052_payloads);
        parseAll_NA_CAMT053(NA_CAMT053_payloads);
        parseAll_EMEA_CAMT053(EMEA_CAMT053_payloads);
        parseAll_US_CAMT054(US_CAMT054_payloads);
        parseALL_CAD_CAMT054(CAD_CAMT054_payloads);

        //return all deposits to insert, til then.. insert list here
        if(finalDepositList != null && !finalDepositList.isEmpty())
        	insert finalDepositList;
        
        //mark all payloads as processed
    }

                    
	@TestVisible private void splitPayloads(List<Payload__c> allPayloadsToSplit){ 
        if(allPayloadsToSplit != null && !allPayloadsToSplit.isEmpty()){
            for ( Payload__c iteratedPayload : allPayloadsToSplit){
                String fileName = (iteratedPayload.Name).toLowerCase();

                if ( fileName.contains('na') && (fileName.contains('camt052') || fileName.contains('camt.052')) ){
                    NA_CAMT052_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('na') && (fileName.contains('camt053') || fileName.contains('camt.053')) ){
                    NA_CAMT053_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('cad') && (fileName.contains('camt054') || fileName.contains('camt.054')) ){
                    CAD_CAMT054_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('us') && (fileName.contains('camt054') || fileName.contains('camt.054')) ){
                    US_CAMT054_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('emea') && (fileName.contains('camt052') || fileName.contains('camt.052')) ){
                    EMEA_CAMT052_payloads.add(iteratedPayload);
                }
                else if ( fileName.contains('emea') && (fileName.contains('camt053') || fileName.contains('camt.053'))  ){
                    EMEA_CAMT053_payloads.add(iteratedPayload);   
                } else {
                    System.debug('A payload of unknown type has been detected. Here is the payload name: ' + iteratedPayload.Name);
                }
            }
        } else {
            System.debug('No payloads to process. CPQDepositXMLPayloadParser received 0 payloads.');
        }
    }
                    
       
    @TestVisible private void parseAll_NA_CAMT052(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> NA_CAMT052_deposits = camt052.parsePatternCAMT052(currPayload);
                    if(NA_CAMT052_deposits != null && !NA_CAMT052_deposits.isEmpty()){
                        finalDepositList.addAll(NA_CAMT052_deposits);
                    }
                }
            }
        }else
            System.debug('No NA_CAMT052 xml payloads to parse');
    }
                    
    
    @TestVisible private void parseAll_EMEA_CAMT052(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> EMEA_CAMT052_deposits = camt052.parsePatternCAMT052(currPayload);
                    if(EMEA_CAMT052_deposits != null && !EMEA_CAMT052_deposits.isEmpty()){
                        finalDepositList.addAll(EMEA_CAMT052_deposits);
                    }
                } 
            }
        }else
            System.debug('No EMEA_CAMT052 xml payloads to parse');
    }
                    
                    
    @TestVisible private void parseAll_NA_CAMT053(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> NA_CAMT053_deposits = camt053.parsePatternCAMT053(currPayload);
                    if(NA_CAMT053_deposits != null && !NA_CAMT053_deposits.isEmpty()){
                        finalDepositList.addAll(NA_CAMT053_deposits);
                    }
                }
            }
        }else
            System.debug('No NA_CAMT053 xml payloads to parse');
    }


    @TestVisible private void parseAll_EMEA_CAMT053(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> EMEA_CAMT053_deposits = camt053.parsePatternCAMT053(currPayload);
                    if(EMEA_CAMT053_deposits != null && !EMEA_CAMT053_deposits.isEmpty()){
                        finalDepositList.addAll(EMEA_CAMT053_deposits);
                    }
                }
            }
        }else
            System.debug('No EMEA_CAMT053 xml payloads to parse');
    }

    
    @TestVisible private void parseALL_US_CAMT054(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> US_CAMT054_deposits = camt054.parsePatternCAMT054(currPayload);
                    if(US_CAMT054_deposits != null && !US_CAMT054_deposits.isEmpty()){
                        finalDepositList.addAll(US_CAMT054_deposits);
                    }
                } 
            }
        }else
            System.debug('No US_CAMT054 xml payloads to parse');
    }


    @TestVisible private void parseALL_CAD_CAMT054(List<Payload__c> payloadsToParse){ 
        if (payloadsToParse != null && !payloadsToParse.isEmpty()){
            for (Payload__c currPayload: payloadsToParse){
                if (String.isNotBlank(currPayload.Payload__c)){
                    List<Deposit__c> CAD_CAMT054_deposits = camt054.parsePatternCAMT054(currPayload);
                    if(CAD_CAMT054_deposits != null && !CAD_CAMT054_deposits.isEmpty()){
                        finalDepositList.addAll(CAD_CAMT054_deposits);
                    } 
                }      
            }
        }else
            System.debug('No CAD_CAMT054 xml payloads to parse');
    }


    
}