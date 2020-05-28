public class CPQPaymentParserState
    implements CPQIPaymentParserState 
    {

        @TestVisible
        private List<String> stateStack = new List<String>();

        public String enterLevel(String tokenName){
            String retval = tokenName;
            if(String.isNotBlank(retval)){
            	stateStack.add(retval);
            }
            return retval;
        }

        public String leaveLevel(String endTag) {
            String leaving;
            if(stateStack.get(stateStack.size()-1) == endTag){
                leaving = stateStack.remove(stateStack.size()-1);
            } else if(stateStack.isEmpty()) {
                throw new CPQInvalidParserStateException('Attempted to leave current state when there is no current state.');
            } else {
                System.debug('XML.END_ELEMENT does not have a matching XML.START_ELEMENT'); 
            }
            return leaving;
        }

        public Boolean isWithinLevel(String tokenName){
            if (stateStack.contains(tokenName)){
                return true;
            } else {
                return false;
            }
        }

        public class CPQInvalidParserStateException extends Exception {
            //CPQInvalidParserStateException(String msg) { Super(msg); } --System exception constructor already defined
            //any sublcass of Exception inherits constructors from Exception. Inherited constructors cant be overridden
        }

}