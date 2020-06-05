public class MockCPQCSVParser implements CPQICSVParser {

    @TestVisible public Integer callCount = 0;

    public List<Deposit__c> parsePayloadCSVString(Payload__c payloadToParse){
        ++callCount;
        return null;
    }
    
}
