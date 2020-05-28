({
    init : function (cmp) {
        var flow = cmp.find("flowData");
        var inputVariables = [  { name : "recordId" , type : "String" , value : cmp.get("v.recordId") } ];
        flow.startFlow("Log_Activity_Spoke_with_Contact", inputVariables);
      },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        }
    }
})