trigger enrollmentClassRollUp on Enrollment__c (after insert, after update, after undelete, after delete) {
    List<Enrollment__c> triggerEnrollments = Trigger.IsDelete ? Trigger.Old : Trigger.New;
    Set<Id> classIds = new Set<Id>();
    for (Enrollment__c e : triggerEnrollments) {
        classIds.add(e.Course__c);
    }
    Class__c[] parentClass = [SELECT Id, Name, Number_Registered__c, Number_Cancelled__c, Number_Completed__c, Number_Passed__c, (SELECT Id, Status__c FROM Course_Enrollments__r WHERE IsDeleted = FALSE) FROM Class__c WHERE IsDeleted = FALSE AND ID in :classIds];

    for (Class__c c : parentClass) {
        Decimal numReg = 0;
        Decimal numRem = 0;
        Decimal numCan = 0;
        Decimal numCom = 0;
        Decimal numPas = 0;
        Decimal numTra = 0;
        Decimal numAvg = 0;
        if (!c.Course_Enrollments__r.isEmpty()) {
            AggregateResult[] enrollmentCounts = [SELECT Status__c, Count(Id) FROM Enrollment__c WHERE Id in :c.Course_Enrollments__r GROUP BY Status__c]; 
            AggregateResult[] passedCount = [SELECT isPassed__c, Count(Id) FROM Enrollment__c WHERE Id in :c.Course_Enrollments__r GROUP BY isPassed__c]; 
            AggregateResult[] avgScore = [SELECT AVG(Score_Percent__c)aver FROM Enrollment__c WHERE Score_Percent__c != null AND (Status__c = 'Completed' OR Status__c = 'Training Recommended') AND Id in :c.Course_Enrollments__r];
            for (AggregateResult ag : enrollmentCounts) {
                if (String.valueof(ag.get('Status__c')) == 'Registered') {
                    numReg = (decimal)ag.get('expr0');
                }
                if (String.valueof(ag.get('Status__c')) == 'Registered (Remote)') {
                    numRem = (decimal)ag.get('expr0');
                }
                if (String.valueof(ag.get('Status__c')) == 'Cancelled') {
                    numCan = (decimal)ag.get('expr0');
                }
                if (String.valueof(ag.get('Status__c')) == 'Completed') {
                    numCom = (decimal)ag.get('expr0');
                }
                if (String.valueof(ag.get('Status__c')) == 'Training Recommended') {
                    numTra = (decimal)ag.get('expr0');
                }
            }
            for (AggregateResult ag : passedCount) {
                if (String.valueof(ag.get('isPassed__c')) == 'True') {
                    numPas = (decimal)ag.get('expr0');
                }
            }
            for (AggregateResult ag : avgScore) {
                if (String.valueof(ag.get('aver')) != null) {
                    numAvg = (decimal)ag.get('aver');
                }
            }
        }
        c.Number_Registered__c = numReg;
        c.Number_Remote__c = numRem;
        c.Number_Cancelled__c = numCan;
        c.Number_Completed__c = numCom;
        c.Number_Passed__c = numPas;
        c.Number_Training_Recommended__c = numTra;
        c.Average_Score__c = numAvg;
    }
    update parentClass;
}