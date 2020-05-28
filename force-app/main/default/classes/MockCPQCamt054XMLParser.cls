public class MockCPQCamt054XMLParser implements CPQICamt054Parser{
    
    @testVisible public Integer callCount = 0;
    
    public List<Deposit__c> parsePatternCAMT054(Payload__c payloadToParse){
        ++callCount;
        return null;
    }
                                

}