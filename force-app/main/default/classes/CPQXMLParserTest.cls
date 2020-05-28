@isTest
private class CPQXMLParserTest {
    
    @isTest static void testParseFromStreamPositive(){
        //setup
        String testXML = '<xmlEvent>getThisValue</xmlEvent>';
        CPQXMLParser parser = new CPQXMLParser();
        XmlStreamReader reader = new XmlStreamReader(testXML);
        
        //test
        Test.startTest();
        String insideValue = parser.parseFromStream(reader, false); 
        Test.stopTest();

        //expect
        System.assertEquals('getThisValue', insideValue); 
    }
    
    @isTest static void testParseFromStreamPositiveGetsAttribute(){
        //setup
        String testXML = '<xmlEvent attr="getThisAttribute">getThisValue</xmlEvent>';
        CPQXMLParser parser = new CPQXMLParser();
        XmlStreamReader reader = new XmlStreamReader(testXML);
        
        //test
        Test.startTest();
        String insideValue = parser.parseFromStream(reader, true); 
        Test.stopTest();

        //expect
        System.assertEquals('getThisAttribute', insideValue); 
    }
    
    @isTest static void testParseFromStreamNoValue(){
        //setup
        String testXML = '<xmlEvent attr="getThisAttribute"></xmlEvent>';
        CPQXMLParser parser = new CPQXMLParser();
        XmlStreamReader reader = new XmlStreamReader(testXML);
        
        //test
        Test.startTest();
        String insideValue = parser.parseFromStream(reader, false); 
        Test.stopTest();

        //expect
        System.assertEquals('', insideValue); 
    }
    
    @isTest static void testSkipToNextNtryPositive(){
        //setup
        String testXML = '<ntry><inner1></inner1></ntry><breakhere></breakhere><ntry><inner1></inner1></ntry><ntry><inner1></inner1></ntry>';
        CPQXMLParser parser = new CPQXMLParser();
        XmlStreamReader reader = new XmlStreamReader(testXML);
        String startPoint = reader.getLocation();
        
        //test
        Test.startTest();
        parser.skipToNextNtry(reader);
        String endPoint = reader.getLocation();
        Test.stopTest();

        //expect
        System.assert(startPoint < endPoint);
    }
    
    @isTest static void testSkipToNextNtryNegative(){
        //setup
        String testXML = '123456789';
        CPQXMLParser parser = new CPQXMLParser();
        XmlStreamReader reader = new XmlStreamReader(testXML);
        String startPoint = reader.getLocation();
        String error;
        
        //test
        try{
        	parser.skipToNextNtry(reader);
        }catch(Exception e){
            error = e.getTypeName();
        }
 
        //expect
        System.assert(error == 'System.XmlException');
    }
    
    
    

    
    
}