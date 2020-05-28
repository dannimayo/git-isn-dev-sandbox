({
	init : function  (component, event, helper) {
                
      const mode = 'available';
      var serverSideAction = component.get('c.getSessionType');
      serverSideAction.setParams({});
      component.set('v.sessionType', 'Error');
      helper.serverSideCall(component, serverSideAction)
    		.then($A.getCallback(function(res) {
           		component.set('v.sessionType', res);
        		console.log('sessionType=' + res);
              
      			if(res != 'Error' && res != 'SiteStudio' && res != 'LivePreview') {
                    let btn1Cmd = component.get('v.button1Command');
                    let btn2Cmd = component.get('v.button2Command');
                    let btn3Cmd = component.get('v.button3Command');
                                        
                    if(btn1Cmd) {
                    	let btn1 = btn1Cmd + '|' + component.get('v.button1DefaultDestination') + '|v.button1Enabled';
                    	helper.computeURL(component, btn1, mode);
                    }
                    
                    if(btn2Cmd) {
                    	let btn2 = btn2Cmd + '|' + component.get('v.button2DefaultDestination') + '|v.button2Enabled';
                    	helper.computeURL(component, btn2, mode);
                    }

                    if(btn3Cmd) {
                    	let btn3 = btn3Cmd + '|' + component.get('v.button3DefaultDestination') + '|v.button3Enabled';
                    	helper.computeURL(component, btn3, mode);
                    }
                    
                }
                else {
                   console.log('In preview mode, session type=' + res);
			       component.set("v.button1Enabled", true);
			       component.set("v.button2Enabled", true);
			       component.set("v.button3Enabled", true);
                }
            },
            $A.getCallback(function(err) {
                console.log("Encountered error while retrieving session type and starting flow: " + err);
                })
        )).catch($A.getCallback(function(err) {
            console.log("Encountered exception while retrieving session type and starting flow:  " + err.name + ": " + err.message);
        }));
       
  
	},
    handleClick : function (component, event, helper) {
    	console.log('Got here!');
    	let rawButtonParms = String(event.getSource().get('v.name'));
    	helper.computeURL(component, rawButtonParms,'exec');
    },
    
    showSpinner: function(component, event, helper) {
        helper.showSpinner(component);
    },
    
    hideSpinner : function(component,event,helper){
        helper.showSpinner(component);
    }
})