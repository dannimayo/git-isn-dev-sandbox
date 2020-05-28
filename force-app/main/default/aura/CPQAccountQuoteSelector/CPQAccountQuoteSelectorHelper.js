({
loadAcc: function(component) {
    return new Promise(function(resolve, reject) {
        console.log('Entered init');
        let searchKey = component.get("v.accountId");
        const action = component.get('c.getAccountQuotes');
        action.setParams({
            "accountId" : searchKey
           });
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                resolve(JSON.parse(response.getReturnValue()));
            } else {
                reject();
            }
        });
        $A.enqueueAction(action);
    });
}
})