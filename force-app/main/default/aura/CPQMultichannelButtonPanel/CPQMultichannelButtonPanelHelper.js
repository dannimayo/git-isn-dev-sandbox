({
    showSpinner : function (component) {
		component.set("v.spinner", true); 
    },
    hideSpinner : function (component) {
        component.set("v.spinner", false); 
    },

    serverSideCall : function(component,action) {
        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    },
    
    computeURL : function(component, rawButtonParms, mode) {
        let serverSideAction = component.get('c.buildCommand');

        let buttonParms = rawButtonParms.toString().split('|');
        let commandId = buttonParms[0];
        let defaultURL = buttonParms[1];
        let visibleFlag = buttonParms[2];
        
        console.log('rawButtonParms=' + rawButtonParms);
        console.log('mode=' + mode);
        console.log('buttonParms length=' + buttonParms.length);
        console.log('commandId=' + ((!commandId) ? 'null' : commandId));
        console.log('defaultURL=' + ((!defaultURL) ? 'null' : defaultURL));
        
        if(mode=='exec')  {
            this.showSpinner(component);
        }
        
        serverSideAction.setParams({
            "commandId" : commandId,
            "recordId": component.get('v.recordId'),
            "mode" : mode
            });
        this.serverSideCall(component, serverSideAction)
    		.then($A.getCallback(function(res) {
        		
                console.log("res.type=" + res.type);
                console.log("res.detail=" + res.detail);
                if(!res.detail && defaultURL) {
                	console.log("defaultURL=" + defaultURL);
                	if(mode=="exec") {
                		window.location.replace(defaultURL);
                	}
                	else if(mode=="available") {
                		component.set(visibleFlag,true);
                	}
                }
                else if(res.type=="redirect"){
                	console.log("calculated URL=" + res.detail);
                 	if(mode=="exec") {
                		window.location.replace(res.detail);
                	}
                	else if(mode=="available") {            		
                		component.set(visibleFlag, (res.detail ? true : false));
                	}
             	}
            },
            $A.getCallback(function(err) {
                component.set("v.spinner", false);
                console.log("Encountered error while computing url: " +  err.name + ": " + err.message);
                console.log(err);
                console.log(err.name);
                console.log(err.message);
                $A.reportError(err);
                })
        )).catch($A.getCallback(function(err) {
            component.set("v.spinner", false); 
            console.log("Encountered exception while computing url.  " + err.name + ": " + err.message);
            console.log(err);
            console.log(err.name);
            console.log(err.message);
        $A.reportError(err);
        }));
    }    

})