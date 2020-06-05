public interface CPQICSVParser {
    
    List<Deposit__c> parsePayloadCSVString(Payload__c payloadToParse);

}
