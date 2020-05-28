({
   getResponse : function(component) {
		var action = component.get("c.doISNLogin");
        action.setParams({
            "sAccountID": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                //console.log('res---->' + response.getReturnValue());
                component.set("v.response", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    getToken : function(component) {
		var action = component.get("c.getToken");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                //console.log('res---->' + response.getReturnValue());
                component.set("v.response", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
	helperMethod : function() {
		
	}
})