({  
    applyLineItemChanges: function(cmp, event, helper){
        const params = event.getParam('arguments');
        console.log("params:");
        console.log(params);
        let draftValues = params.draftValues;
        let cart = JSON.parse(params.cartJson);
        console.log("cart:");
        console.log(cart);
        console.log("draftValues:");
        console.log(draftValues);
        
        draftValues.forEach(function(draftValue){
            console.log("Processing draftValue: ");
            console.log(draftValue);
            for(let i=0;i<cart.lineItems.length;i++){
                console.log("Processing line item number: " + i);
                if (cart.lineItems[i].record.Id === draftValue.Id){
                    console.log("Found match on record id: " + draftValue.Id);
                    Object.keys(draftValue).forEach(function(key, index){
                        if(key != "Id"){
                            cart.lineItems[i].record[key] = draftValue[key];
                            console.log("Setting line item with id " + cart.lineItems[i].record.Id + ".  Key=" + key + ", value=" + draftValue[key]);
                        }
                    });
                }    
            }
        }); 
        return cart;
    },
    getCartIdFromCart: function(cmp, event, helper){
        const params = event.getParam('arguments');
        console.log("params:");
        console.log(params);

        let cart= params.cart;
        let cartId = cart.record.Id;
        console.log("cartId=" + cartId);
        return cartId;
    }
 
})