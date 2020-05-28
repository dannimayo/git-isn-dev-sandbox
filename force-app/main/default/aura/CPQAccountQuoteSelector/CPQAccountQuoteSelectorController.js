({
    init : function(component, event, helper) {
       let availableActions = component.get('v.availableActions');
       component.set("v.canNext", false); 
       for (let i = 0; i < availableActions.length; i++) {
           if (availableActions[i] == "NEXT") {
              component.set("v.canNext", true);
           } 
        }
        helper.loadAcc(component)
        .then($A.getCallback(function(data) {
            component.set('v.quotes', data);
            console.log('data: ');
            console.log(data);
        }))
        .catch($A.getCallback(function(error) {
            console.log(error);
        }));
        /*component.set('v.quotes', [{'Id':'a0u3i0000005nUGAAY', 'SBQQ__Introduction__c': 'Product A', 'SBQQ__Notes__c': 'First month free, renew for 2 years.', 'Total_Customer_Amount__c': 220.00},
                                   {'Id':'2','SBQQ__Introduction__c': 'Product A', 'SBQQ__Notes__c': 'Renew for 1 year.', 'Total_Customer_Amount__c': 120.00} ]);
        */
    },
    
    onRadioChange: function(component, event) {
        console.log(event.getSource().get('v.value'));
        component.set('v.selectedQuoteId', event.getSource().get('v.value'));
    },
    
    onClickNext:function(cmp, event) {
       let navigate = cmp.get("v.navigateFlow");
       let canNext = cmp.get("v.canNext");
       if(canNext) {
           navigate("NEXT");
       }
       else {
           navigate("FINISH");
       }
    }

})