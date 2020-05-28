public class MockCPQCamt053XMLParser implements CPQICamt053Parser{
    
    @testVisible public Integer callCount = 0;
    
    public List<Deposit__c> parsePatternCAMT053(Payload__c payloadToParse){
        ++callCount;
        return null;
    }
                                

}