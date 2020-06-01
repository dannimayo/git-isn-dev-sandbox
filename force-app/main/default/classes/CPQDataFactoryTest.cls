/***************************************************************************************
* @author Ruslan Vekua - aMind Solutions
* @CreatedDate 4/24/2020
* 
* Last Modified By - Ruslan Vekua
* @ModifiedDate 4/27/2020
* @Change History:
	1. Ruslan Vekua 4/27/2020' - Create initial version
	2. Ruslan Vekua 4/27/2020' - Add stubbing methods
*****************************************************************************************/
@isTest
public class CPQDataFactoryTest {
     
    public static Product2 constructISNContractorProduct(ID brId, ID rrrId, ID trId){
        Product2 pr2 = new Product2();
        pr2.Name = 'ISN Contractor';
        pr2.ProductCode = 'CESUB';
        pr2.CurrencyIsoCode = 'USD';
        pr2.Description = 'ISNetworld Annual Contractor/Supplier Subscription';
        pr2.Family = 'Contractor';
        pr2.IsActive = true;
        pr2.SBQQ__AssetAmendmentBehavior__c = 'Default';
        pr2.SBQQ__AssetConversion__c = 'One per quote line';
        pr2.SBQQ__BillingFrequency__c = 'Annual';
        pr2.SBQQ__BillingType__c = 'Advance';
        pr2.SBQQ__BlockPricingField__c = 'Quantity';
        pr2.SBQQ__ChargeType__c = 'Recurring';
        pr2.SBQQ__Component__c = false;
        pr2.SBQQ__DefaultQuantity__c = 1;
        pr2.blng__BillingRule__c = brId;
        pr2.blng__RevenueRecognitionRule__c = rrrId;
        pr2.blng__TaxRule__c = trId;
        Insert pr2;
		return pr2;
    }
    
    public static Account createContractorAccount(){
        Id accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contractor').getRecordTypeId();
        Account acc = new Account();
        acc.name = 'Account Contractor';
        acc.ISNetworld_Status__c = 'Prospect';
        acc.type = 'Contractor';
        acc.RecordTypeId = accRtId;
        Insert acc;
        return acc;
    }
    
    public static Order createOrder(ID accId, ID pricebook2Id){
        Order ord = new Order();
        ord.AccountId = accId;
        //ord.BillingCity = 'Newark';
        //ord.BillingCountry = 'United States';
        //ord.BillingCountryCode = 'US';
        //ord.BillingPostalCode = '19711';
        //ord.BillingState = 'DE';
        //ord.BillingStateCode = 'DE';
        ord.CurrencyIsoCode = 'USD';
        //ord.BillingStreet = '2213 ogletown rd  unit BP-PON 22098';
        ord.Pricebook2Id = pricebook2Id;
        ord.SBQQ__PriceCalcStatus__c = 'Not Needed';
        ord.EffectiveDate = System.today();
        ord.Status = 'Draft';
        ord.blng__BillingDayOfMonth__c = '22';
        Insert ord;
        return ord;
    }
    
    public static OrderItem createOrderItem(ID productId, ID orderId, ID pricebookEntryId, ID brId, ID rrrId, ID trId){
        OrderItem oi = new OrderItem();
        oi.blng__BillableUnitPrice__c = 3000;
        oi.blng__BilledAmountwithouttax__c = 3000;
        oi.blng__BilledTax__c = 0;
        oi.blng__HoldBilling__c = 'No';
        oi.EndDate = System.today().addYears(1);
        oi.OrderId = orderId;
        oi.PricebookEntryId = pricebookEntryId;
        oi.Product2Id = productId;
        oi.Quantity = 1;
        oi.SBQQ__Activated__c = false;
        oi.SBQQ__BillingFrequency__c = 'Annual';
        oi.SBQQ__BillingType__c = 'Advance';
        oi.SBQQ__ChargeType__c = 'Recurring';
        oi.SBQQ__OrderedQuantity__c = 1;
        oi.SBQQ__QuotedListPrice__c = 3000;
        oi.SBQQ__QuotedQuantity__c = 1;
        oi.SBQQ__Status__c = 'Activated';
        oi.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        oi.SBQQ__SubscriptionTerm__c = 12;
        oi.SBQQ__SubscriptionType__c = 'Renewable';
        oi.SBQQ__ProductSubscriptionType__c = 'Renewable';
        oi.SBQQ__DefaultSubscriptionTerm__c = 12;
        oi.ServiceDate = System.today();
        oi.UnitPrice = 3000;
        oi.blng__BillingRule__c = brId;
        oi.blng__RevenueRecognitionRule__c = rrrId;
        oi.blng__TaxRule__c = trId;
        Insert oi;
        return oi;
    }
    
    public static blng__BillingRule__c createContractorBillingRule(){
        blng__BillingRule__c br = new blng__BillingRule__c();
        br.Name = 'Contractor Sub : Default';
        br.blng__Active__c = true;
		br.blng__GenerateInvoices__c = 'Yes';
        br.blng__InitialBillingTrigger__c = 'Order Product Activation Date';
        br.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        br.blng__PartialPeriodTreatment__c = 'Combine';
        br.CurrencyIsoCode = 'USD';
        Insert br;
        return br;
    }
    
    public static PricebookEntry createPriceBookEntry(ID priceBookId, ID pr2Id){
        Update new Pricebook2(Id=priceBookId, IsActive=true);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = priceBookId,
            Product2Id = pr2Id,
            UnitPrice = 3000,
            IsActive = true
        );
        Insert pbe;
		return pbe;
    }
    
    public static blng__RevenueRecognitionRule__c createGeneralRevRecRule(){
        blng__RevenueRecognitionRule__c rrr = new blng__RevenueRecognitionRule__c();
        rrr.blng__Active__c = true;
        rrr.blng__CreateRevenueSchedule__c = 'Yes';
        rrr.CurrencyIsoCode = 'USD';
        rrr.Name = 'General Rev Rec Rule';
        Insert rrr;
        return rrr;
    }
    
    public static blng__TaxRule__c createAvalaraTaxRule(){
        blng__TaxRule__c tr = new blng__TaxRule__c();
        tr.blng__Active__c = true;
        tr.blng__TaxableYesNo__c = 'Yes';
        tr.CurrencyIsoCode = 'USD';
        tr.Name = 'Avalara Tax Rule';
        Insert tr;
        return tr;
    }

   public static Account createAccount(){
       Account acc = new Account();
       acc.Active__c=true;
       acc.Name='Test Name';
       insert acc;
       return acc;
    }
    
    public static blng__GLRule__c createGlRule(){
        blng__GLRule__c rule = new blng__GLRule__c();
        rule.CurrencyIsoCode = 'USD';
        rule.Name='Payment GL Rule : ISN Software Corporation PayPal : USD';
        insert rule;
        return rule;
    }
    
     public static blng__GLTreatment__c createGlTreatment(Id glRuleId){
        blng__GLTreatment__c treat = new blng__GLTreatment__c();
        treat.CurrencyIsoCode = 'USD';
        treat.blng__GLRule__c = glRuleId;
        treat.Name='Payment GL Treatment : ISN Software Corporation PayPal : USD';
        insert treat;
        return treat;
    }  
    
    public static blng__Payment__c createBillingPayment(Id accountId){         
        blng__Payment__c pmt = new blng__Payment__c();
        pmt.blng__Amount__c = 100;
        pmt.blng__Account__c = accountId;
        pmt.Bank_Name__c = 'PayPal';
        pmt.CurrencyIsoCode = 'USD';
        insert pmt;
        return pmt;
    }

     public static Account createHCPAccount(){
        Id accRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hiring Client Prospect').getRecordTypeId();
        Account acc = new Account();
        acc.name = 'Hiring Client Prospect';
        acc.ISNetworld_Status__c = 'Prospect';
        acc.type = 'Hiring Client'; 
        acc.RecordTypeId = accRtId;
        Insert acc;
        return acc;
    }

     public static Opportunity createRenewalOppty(ID accId){
        
        Id opptyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Hiring Client Subscription').getRecordTypeId();
        Opportunity oppty = new Opportunity();
        oppty.AccountId = accId;
        oppty.SBQQ__Renewal__c=true;
        oppty.RecordTypeId = opptyRtId;
        oppty.Type = 'Contractor Subscription';
        oppty.Name = 'TEST OPPTY ' + accId;
        oppty.StageName = '00 - New';
        oppty.CloseDate = System.today().addDays(30);
        Insert oppty;
        return oppty;
    }
    
    public static Opportunity createOppty(ID accId){
        
        Id opptyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Hiring Client Subscription').getRecordTypeId();
        Opportunity oppty = new Opportunity();
        oppty.AccountId = accId;
        oppty.RecordTypeId = opptyRtId;
        oppty.Type = 'Hiring Client Subscription';
        oppty.Name = 'TEST OPPTY ' + accId;
        oppty.StageName = '00 - New';
        oppty.CloseDate = System.today().addDays(30);
        Insert oppty;
        return oppty;
    }
    
    public static Contract createContract(ID accId){
        Opportunity oppty = createRenewalOppty(accId);
        Contract contr = new Contract();
        contr.AccountId = accId;
        contr.ContractTerm = 12;
        contr.SBQQ__Opportunity__c=oppty.Id;
        contr.StartDate = system.today();
        insert contr;
        return contr;
    }
    
    public static SBQQ__Subscription__c createSubscription(ID accId, ID contractId){
		
        blng__BillingRule__c br= createContractorBillingRule();
        blng__TaxRule__c tr = createAvalaraTaxRule();
        blng__RevenueRecognitionRule__c rrr = createGeneralRevRecRule();
        Product2 prod2 =constructISNContractorProduct(br.Id, rrr.Id ,tr.Id);
        
         SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
         sub.SBQQ__Account__c=accId;
         sub.SBQQ__Contract__c=contractId;
         sub.SBQQ__Quantity__c=10;
         sub.SBQQ__Product__c=prod2.Id;
         sub.Integration_Status__c='Submitted';
         sub.Thank_You_Email_Sent__c=false;
         insert sub;
         return sub;
    }
    
    public static EmailTemplate createEmailTemplate(){
        EmailTemplate tmp = new EmailTemplate();
        tmp.DeveloperName='test';
        tmp.Name='Renewal Thank You VF';
        tmp.FolderId='00DL0000005xuC6MAI';
        tmp.TemplateType='custom';
        tmp.IsActive=true;
        insert tmp;
        return tmp;
    }
    public static Contact createContact(Id accId){
        Contact cnt = new Contact();
        cnt.LastName='Test';
        cnt.AccountId=accId;
        cnt.Email='Test@example.com';
    	insert cnt;
        return cnt;
    }
    public static SBQQ__Quote__c createQuote(ID accId, ID opptyId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = accId;
        quote.SBQQ__Opportunity2__c = opptyId;
        quote.SBQQ__Status__c = 'Draft';
        Insert quote;
        return quote;
    }  
    
    public static SBQQ__QuoteLine__c createQuoteLine(ID productId, ID quoteId, ID pricebookEntryId){
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__CustomerPrice__c = 3000;
        ql.SBQQ__StartDate__c = System.today();
        ql.SBQQ__Quote__c = quoteId;
        ql.SBQQ__PricebookEntryId__c = pricebookEntryId;
        ql.SBQQ__Product__c = productId;
        ql.SBQQ__Quantity__c = 1;
        ql.SBQQ__ChargeType__c = 'Recurring';
        ql.SBQQ__PricingMethod__c = 'List';
        ql.SBQQ__ListPrice__c = 3000;
        ql.SBQQ__NetPrice__c = 3000;
        ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        ql.SBQQ__SubscriptionTerm__c = 12;
        ql.SBQQ__SubscriptionType__c = 'Renewable';
        ql.SBQQ__ProductSubscriptionType__c = 'Renewable';
        ql.SBQQ__DefaultSubscriptionTerm__c = 12;
        ql.SBQQ__BillingType__c = 'Advance';
        Insert ql;
        return ql;
    }
}