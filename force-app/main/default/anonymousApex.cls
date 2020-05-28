public with sharing class anonymousApex {




    List<Payload__c> allXMLPayloads = [SELECT Name, Id, Payload__c FROM Payload__c WHERE Name LIKE '%xml%'];
    CPQDepositXMLPayloadParser dma = new CPQDepositXMLPayloadParser();


    dma.parseXMLtoDeposits(allXMLPayloads);
    //this is a comment showing changes




    /*
    Id jobID = System.enqueueJob(new CPQParseXMLQueueable());
    System.debug ('\n Here is the job id ' + jobID);
    */

    
}
