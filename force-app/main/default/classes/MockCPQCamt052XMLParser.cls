public class MockCPQCamt052XMLParser implements CPQICamt052Parser{
    
    @testVisible public Integer callCount = 0;
    
    public List<Deposit__c> parsePatternCAMT052(Payload__c payloadToParse){
        ++callCount;
        return null;
    }
                                

}