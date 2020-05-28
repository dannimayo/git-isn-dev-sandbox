public interface CPQIPaymentParserState {

    String enterLevel(String tokenName);

    String leaveLevel(String tokenName);

    Boolean isWithinLevel(String tokenName);

}