public class CPQXMLParser {
    
    public String parseFromStream(XmlStreamReader reader, boolean parseAttributeValue ){
        String data = '';
        while(reader.hasNext()){
            if(reader.getEventType() == XmlTag.START_ELEMENT && parseAttributeValue == true){
                data = reader.getAttributeValueAt(0);
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS){
                data = reader.getText();
                System.debug('\nEXTRACTING DATA ' + data);
            } else if (reader.getEventType() == XmlTag.END_ELEMENT){
                break;
            }
            reader.next();
        }
        return data;
    }

    
    public void skipToNextNtry(XmlStreamReader reader){
        System.debug('\n\nLETS FAST FORWARD READER. CURRENT PASSED LOCATION IS: ' + reader.getLocation());
        while(reader.hasNext()){
            if( (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ntry') || (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'stmt') || (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'ntfctn') ){
                System.debug('\nNEW LOCATION IS: ' + reader.getLocation());
                break;
            }
            reader.next();
        }
    }

}