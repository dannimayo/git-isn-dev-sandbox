public with sharing class anonymousApex {




    List<Payload__c> allXMLPayloads = [SELECT Name, Id, Payload__c FROM Payload__c WHERE Name LIKE '%xml%'];
    CPQDepositXMLPayloadParser dma = new CPQDepositXMLPayloadParser();
    dma.parseToDeposits(allXMLPayloads);
    //done


    /*
    Id jobID = System.enqueueJob(new CPQParseXMLQueueable());
    System.debug ('\n Here is the job id ' + jobID);
    //done
    */


    //direct cal parser
    Payload__c CALpayload = [SELECT Id, Name, Payload__c FROM Payload__c WHERE Name LIKE '%CAL-310390_20200413111931.zip%' LIMIT 1];
    CPQCalCSVParser calParser = new CPQCalCSVParser();
    CalParser.parseCalPatternCSVString(CALpayload);

    //direct dal parser
    Payload__c DALpayload = [SELECT Id, Name, Payload__c FROM Payload__c WHERE Name LIKE '%DAL__841808_IMG_20200413150632%' LIMIT 1];
    CPQDalCSVParser dalParser = new CPQDalCSVParser();
    dalParser.parseDalPatternCSVString(DALpayload);
    

    //parse 1 DAL via main class
    Payload__c DALpayload = [SELECT Id, Name, Payload__c FROM Payload__c WHERE Name LIKE '%DAL__841808_IMG_20200413150632%' LIMIT 1];
    List<Payload__c> payloadsToParse = new List<Payload__c>();
    payloadsToParse.add(DALpayload);
    CPQDepositCSVPayloadParser csvParser = new CPQDepositCSVPayloadParser();
    csvParser.parseToDeposits(payloadsToParse);



    //parse all zip (CSV dal & cal files)
    List<Payload__c> allCSVPayloads = [SELECT Name, Id, Payload__c FROM Payload__c WHERE Name LIKE '%zip%'];
    CPQDepositCSVPayloadParser csvParser = new CPQDepositCSVPayloadParser();
    csvParser.parseToDeposits(allCSVPayloads);



    
}
