({
	loadQuote : function(component) {
		return new Promise(function(resolve, reject) {
			const action = component.get('c.loadQuote');
			console.log("Start Parameters");
			let clientCartService = component.find("clientCartService");
			let carts =  JSON.parse(component.get('v.carts'));
			let quoteId=clientCartService.getCartIdFromCart(carts);

			console.log(carts);
			console.log(quoteId);
			console.log("End Parameter");

			action.setParams({
				"quoteId" : quoteId
			});
			action.setCallback(this, function(response) {
				if(response.getState() === 'SUCCESS') {
					resolve(JSON.parse(response.getReturnValue()));
				} else {
					reject(response);
				}
			});
			$A.enqueueAction(action);
		});
	},
    
	intervalId: null,
    PC_INTERVAL: 5000,
    
	processPricingCheck: function(component, quoteId) {
		let _self = this;
		this.intervalId = window.setInterval(
            $A.getCallback(function() {
				_self.checkPricingStatus(component, quoteId);
            }), _self.PC_INTERVAL);
	},

    checkPricingStatus: function(component, quoteId) {
    	console.log('BEGIN checkPricingStatus...');
		const action = component.get('c.getSimpleQuote');   
		action.setParams({"quoteId" : quoteId });  
		action.setCallback(this, function(response) {				
			this.handleResponse(response, component, quoteId);
		});
		$A.enqueueAction(action);
	},

    handleResponse: function(response, component, quoteId) {
		if(response.getState() === 'SUCCESS') {
			var retVal = JSON.parse(response.getReturnValue());
			if(retVal) {
				let quote = JSON.parse(retVal.quote);
				console.log('checkPricingStatus SBQQ__Uncalculated__c: ' + quote.record.SBQQ__Uncalculated__c);

				if(quote.record.SBQQ__Uncalculated__c === false){
					console.log('Your cart has been repriced!');
					if(this.intervalId){
						window.clearInterval(this.intervalId);
						this.initLoadQuote(component, true);
					}
					component.set('v.loading', false);
				}else{
					console.log('not done yet...');
				}
			}
		} else {
			console.log('The response state is not SUCCESS');
		}
	},

    initLoadQuote: function(component, pricingCompleted){
        let _self = this;
        _self.loadQuote(component).then($A.getCallback(function(data) {
            _self.loadData(component, data);            
            let sQuote = JSON.parse(data[0].quote);
            let quoteId = sQuote.record.Id;
            //If pricing has not happened yet...
            if(!pricingCompleted){
            	_self.processPricingCheck(component, quoteId);
            }
        })).catch($A.getCallback(function(error) {
            console.log(error);
        }));  
    },
    
	calculateAndSaveQuote : function(component) {
		return new Promise(function(resolve, reject) {
			const quote = component.get('v.quote');
			const originalQuote = component.get('v.originalQuote');

			let quoteLineQunatity = {};
			quote.lineItems.forEach(lineItem => {
				quoteLineQunatity[lineItem.record.Id] = lineItem.record.SBQQ__Quantity__c;
			});

			originalQuote.lineItems.forEach(lineItem => {
				if(quoteLineQunatity[lineItem.record.Id]) {
					lineItem.record.SBQQ__Quantity__c = quoteLineQunatity[lineItem.record.Id];
				}
			});

			const action = component.get('c.calculateAndSaveQuote');
			action.setParams({
				"quote" : JSON.stringify(originalQuote)
			});
			action.setCallback(this, function(response) {
				if(response.getState() === 'SUCCESS') {
					resolve(JSON.parse(response.getReturnValue()));
				} else {
					reject(response);
				}
			});
			$A.enqueueAction(action);
		});
	},
	deleteQuoteLine : function(component,quoteLine) {
		return new Promise(function(resolve, reject) {

			const action = component.get('c.deleteQuoteLine');

			action.setParams({
				"quoteLine" : quoteLine
			});
			action.setCallback(this, function(response) {
				if(response.getState() === 'SUCCESS') {
					resolve(JSON.parse(response.getReturnValue()));
				} else {
					reject(response);
				}
			});
			$A.enqueueAction(action);
		});
	},
	loadData: function(cmp, data) {
		console.log('Entered loadData');
		if (data && data[0]) {
			let quote = JSON.parse(data[0].quote);
			let productImages = JSON.parse(data[0].images);
			let taxDetails = JSON.parse(data[0].taxDetails);
			cmp.set('v.originalQuote', Object.assign({}, quote));

			console.log("Quote is: " , quote);

			//Show only bundles
			let topLines = quote.lineItems.filter(function(line){
				console.log('Top line filter entered.')
				let image = productImages[line.record.SBQQ__Product__c];
				let taxDetail = taxDetails[line.record.Id];
                
                let taxDetailSplit = taxDetail ? taxDetail.AVA_SFCPQ__Sales_Tax_Details__c ? taxDetail.AVA_SFCPQ__Sales_Tax_Details__c .split("Rate") : null : null;
                

				line.record.image = image ? image.Product_Image__c : null;
				line.record.taxAmount = taxDetail ? taxDetail.AVA_SFCPQ__TaxAmount__c : 0;
                line.record.taxDetail = taxDetailSplit ? taxDetailSplit[1].replace(':','') : null;
                line.record.totalPrice = (line.record.SBQQ__NetPrice__c ? line.record.SBQQ__NetPrice__c : 0) + (line.record.taxAmount ? line.record.taxAmount : 0);
				//TODO: The check below is the check for root level items/primary lines.
				// Move to a service method for reuse.

				return true;
			});
			let taxTotal = 0;
            topLines.forEach(f=> { taxTotal += (f.record.taxAmount ? f.record.taxAmount : 0); });

			quote.taxTotal = taxTotal;
			quote.grandTotal = taxTotal + quote.netTotal;

			console.log('Line items have been filtered. Filtered quote is:');
			quote.lineItems = topLines;
			console.log(quote);
			cmp.set('v.quote', quote);
		}
		console.log('Exiting loadData');

	}
})