({
   init : function (component, event, helper) {       
           let serverSideAction = component.get('c.getSessionType');
           serverSideAction.setParams({});
           component.set('v.sessionType', 'Error');
           helper.serverSideCall(component, serverSideAction)
           .then($A.getCallback(function(res) {
                let pageParameters = helper.getUrlParameters();
               	let inputVariables = null;
               
                // Find the component whose aura:id is "flowData"
                let flow = component.find("flowData");
               
                let parmsToProcess = component.get("v.pageParameters");
                let passParms = parmsToProcess!=null &&!(parmsToProcess.trim()==='') ;
                let listParmsToProcess = parmsToProcess.split('|');
                      
                inputVariables = listParmsToProcess.map(helper.getMapFunction(pageParameters));
                console.log("inputVariables=" + JSON.stringify(inputVariables));
                
           		component.set('v.sessionType', res);
        		console.log('sessionType=' + res);
              
      			if(res != 'Error' && res != 'SiteStudio' && res != 'LivePreview') {
                    var flowName = component.get("v.flowName");
                    console.log('Launching flow "' + flowName + '".');
                    if(passParms) {
                    	flow.startFlow(flowName, inputVariables);
                    }
                    else {
                        flow.startFlow(flowName);
                    }
                	console.log('Flow launched.');
                }
                else {
                    component.set('v.previewMessage', 'Flow ' + component.get('v.flowName') +' is in preview mode.  The follwing page parameters will be passed to the flow at runtime: ' + JSON.stringify(listParmsToProcess) + '.');
                    console.log('Not starting flow, session type=' + res);
                }
                },
            $A.getCallback(function(err) {
                //console.log("Encountered error while retrieving session type and starting flow: " + err.name + ": " + err.message);
                console.log('Got here 1.');
                console.log(JSON.stringify(err));
                })
        )).catch($A.getCallback(function(err) {
           // console.log("Encountered exception while retrieving session type and starting flow:  " + err.name + ": " + err.message);
           console.log('Got here 2.');
           console.log(err);
        }));
    }
})