({
	getUrlParameters : function() {
        let sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i,
            retval = {};
        
        for (i = 0; i < sURLVariables.length; i++) {
            if(sURLVariables[i]) {
                sParameterName = sURLVariables[i].split('=');
                retval[sParameterName[0]] = ( (sParameterName[1] === undefined) ? true : sParameterName[1]);
            }
        }
        return retval;
    },
    
    getMapFunction : function(parmValLookup){
        return function(parm) { 
            let retval={};
            retval["name"]=parm;
            retval["type"]="String";
            retval["value"] = parmValLookup[parm];
            return retval;
        }
    },
    
   serverSideCall : function(component,action) {
        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   let state = response.getState();
                                   if (state === "SUCCESS") {
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    }
    
})