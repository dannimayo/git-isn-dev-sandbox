@isTest
private class CPQPaymentParserStateTest {

    @isTest
    private static void testPositiveEnterLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        String enterLevelValue = 'abc';

        s.enterLevel(enterLevelValue);

        System.assert(s.stateStack != null);
        System.assert(s.stateStack.get(0) == 'abc');
        
    }

    @isTest static void testNegativeEnterLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        String enterLevelValue = '';

        s.enterLevel(enterLevelValue);

        System.debug(s.stateStack.size());
        System.assert(s.stateStack.size() == 0);

    }

    @isTest static void testPositiveLeaveLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        s.stateStack.add('abc');
        s.stateStack.add('xyz');
        String token = 'xyz';

        String leftLevel = s.leaveLevel(token);

        System.debug('Size of stateStack is ' + s.stateStack.size());
        System.assert(s.stateStack.size() == 1);
        System.assert(leftLevel == token);
    }

    @isTest static void testNegativeLeaveLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        s.stateStack.add('abc');
        s.stateStack.add('xyz');
        String token = 'lol';

        String leftLevel = s.leaveLevel(token);

        System.debug('Size of stateStack is ' + s.stateStack.size());
        System.assert(s.stateStack.size() == 2);
        System.assert(leftLevel == null);
    }

    @isTest static void testPositiveIsWithinLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        String token = 'abc';
        s.stateStack.add(token);
        
        Boolean isValid = s.isWithinLevel('abc');
        
        System.assert(isValid);
    }

    @isTest static void testNegativeIsWithinLevel(){
        CPQPaymentParserState s = new CPQPaymentParserState();
        String token = 'abc';
        s.stateStack.add(token);
        
        Boolean isValid = s.isWithinLevel('xyz');
        
        System.assert(isValid == false);

    }


}