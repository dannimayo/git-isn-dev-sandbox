({
	init : function(cmp, event, helper) {
        helper.initLoadQuote(cmp, false);
	},
    
    onBlur: function(cmp, event, helper) {
        cmp.set('v.loading', true);
        helper.calculateAndSaveQuote(cmp)
        .then($A.getCallback(function(data) {
            helper.loadQuote(cmp)
            .then($A.getCallback(function(data) {
                cmp.set('v.loading', false);
                helper.loadData(cmp, data);
            }))
            .catch($A.getCallback(function(error) {
                console.log(error);
                cmp.set('v.loading', false);
            }));
        }))
        .catch($A.getCallback(function(error) {
            console.log(error);
            cmp.set('v.loading', false);
        }));
    },

    handleLineDelete: function(cmp, event, helper) {
        cmp.set('v.loading', true);
        const rootRecordId = Object.assign({}, event.currentTarget.dataset).lineid;
      
        helper.deleteQuoteLine(cmp,rootRecordId)
        .then($A.getCallback(function(data) {
            helper.loadQuote(cmp)
            .then($A.getCallback(function(data) {
                cmp.set('v.loading', false);
                helper.loadData(cmp, data);
            }))
            .catch($A.getCallback(function(error) {
                console.log(error);
                cmp.set('v.loading', false);
            }));
        }))
        .catch($A.getCallback(function(error) {
            console.log(error);
            cmp.set('v.loading', false);
        }));
    },
    addToCartClick: function(cmp, event) {
        var navigate = cmp.get('v.navigateFlow');
        cmp.set("v.isAddToCartAction",true);
        cmp.set("v.AddToCartAction","NEXT");
        navigate("NEXT");
    }
})