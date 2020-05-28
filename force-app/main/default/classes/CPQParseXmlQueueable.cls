public with sharing class CPQParseXmlQueueable implements Queueable {
    public CPQParseXmlQueueable() {
    }

    public void execute(QueueableContext qc){
        List<Payload__c> allXmlPayloads = [SELECT Id, Name, Payload__c FROM Payload__c WHERE Name LIKE '%xml'];
        CPQDepositXMLPayloadParser xmlParser = new CPQDepositXMLPayloadParser();
        xmlParser.parseXMLtoDeposits(allXmlPayloads);
        System.debug('Here is the a sys debug statement within the execute of cpqparsexmlqueueable' + qc);

    }

}