public with sharing class anonymousApex {




    List<Payload__c> allXMLPayloads = [SELECT Name, Id, Payload__c FROM Payload__c WHERE Name LIKE '%xml%'];
    CPQDepositXMLPayloadParser dma = new CPQDepositXMLPayloadParser();
    dma.parseXMLtoDeposits(allXMLPayloads);
    //done




    /*
    Id jobID = System.enqueueJob(new CPQParseXMLQueueable());
    System.debug ('\n Here is the job id ' + jobID);
    //done
    */

    Payload__c DALpayload = [SELECT Id, Name, Payload__c FROM Payload__c WHERE Name LIKE '%DAL__841808_IMG_20200413150632%' LIMIT 1];
    CPQCSVParser parser = new CPQCSVParser();
    parser.parseCSV(DALpayload);
    //done

    
}
