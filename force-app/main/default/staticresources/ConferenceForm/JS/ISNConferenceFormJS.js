var j$ = jQuery.noConflict();

//jQuery time
var current_fs, next_fs, previous_fs; //fieldsets
var left, opacity, scale; //fieldset properties which we will animate
var animating; //flag to prevent quick multi-click glitches

j$(".next").click(function(){
	if(animating) return false;
	animating = true;
	
	current_fs = j$(this).parent();
	next_fs = j$(this).parent().next();
	
	//activate next step on progressbar using the index of next_fs
	j$("#progressbar li").eq(j$("fieldset").index(next_fs)).addClass("active");
	
	//show the next fieldset
	next_fs.show(); 
	//hide the current fieldset with style
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
			//as the opacity of current_fs reduces to 0 - stored in "now"
			//1. scale current_fs down to 80%
			scale = 1 - (1 - now) * 0.2;
			//2. bring next_fs from the right(50%)
			left = (now * 50)+"%";
			//3. increase opacity of next_fs to 1 as it moves in
			opacity = 1 - now;
			current_fs.css({
        'transform': 'scale('+scale+')',
        'position': 'absolute'
      });
			next_fs.css({'left': left, 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});

j$(".previous").click(function(){
	if(animating) return false;
	animating = true;
	
	current_fs = j$(this).parent();
	previous_fs = j$(this).parent().prev();
	
	//de-activate current step on progressbar
	j$("#progressbar li").eq(j$("fieldset").index(current_fs)).removeClass("active");
	
	//show the previous fieldset
	previous_fs.show(); 
	//hide the current fieldset with style
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
			//as the opacity of current_fs reduces to 0 - stored in "now"
			//1. scale previous_fs from 80% to 100%
			scale = 0.8 + (1 - now) * 0.2;
			//2. take current_fs to the right(50%) - from 0%
			left = ((1-now) * 50)+"%";
			//3. increase opacity of previous_fs to 1 as it moves in
			opacity = 1 - now;
			current_fs.css({'left': left});
			previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});

j$(".submit").click(function(){
	return false;
})

function show(target,source){
	document.getElementById(target).style.display = 'block';
	document.getElementById(source).style.display = 'none';
}
function hide(target){
	document.getElementById(target).style.display = 'none';
}
function reloadPage(){
	addNotesToNewWebLead();
	setTimeout("location.href = '/ISNConferenceWelcome';",5000);
}
function toggleCheckBox(divId){
	var NAME = document.getElementById(divId);
	var currentClass = NAME.className;
	if (currentClass == "isn-selected btn btn-small") {
		NAME.className = "isn-selector btn-small";
	} else {
		NAME.className = "isn-selected btn btn-small";
	}
}
var wlId;
var notes = "";
function addToNotes(addText1,addText2){
	checkVal = document.getElementById(addText2).value;
	console.log(checkVal);
	console.log(notes);
	if (checkVal == null || checkVal === false || checkVal == "") {
		notes = notes + document.getElementById(addText1).innerHTML.trim() + "\r\n" + document.getElementById(addText2).innerHTML.trim() + "\r\n\r\n";
	} else {
		notes = notes + document.getElementById(addText1).innerHTML.trim() + "\r\n" + document.getElementById(addText2).value.trim() + "\r\n\r\n";
	}
}
function addToNotesMultiSelect(addText1,addText2){
	notes = notes + document.getElementById(addText1).innerHTML.trim() + "\r\n";
	arr = addText2.split(";");
	var NAME;
	var currentClass;
	for (i=0;i<arr.length;i++) {
		NAME = document.getElementById(arr[i]);
		currentClass = NAME.className;
		if (currentClass == "isn-selected btn btn-small") {
			notes = notes + document.getElementById(arr[i]).innerHTML.trim() + "; ";
		} else if (currentClass == "addValuestoNotes") {
			notes = notes + document.getElementById(arr[i]).value;
		}
	}
	notes = notes + "\r\n\r\n";
}

function validate(button,fields) {
	arr = fields.split(";");
	var name;
	var val;
	var count = 0;
	for (i=0;i<arr.length;i++) {
		name = document.getElementById(arr[i]);
		val = name.value;
		if (val == null || val == "") {
			count++;
		}
	}
	if (count == 0) {
		document.getElementById(button).style.display = 'inline-block';
	}
	console.log(count);
}

function addWebLead() {
	var firstname = document.getElementById('firstname').value;
	var lastname = document.getElementById('lastname').value;
	var phone_number = document.getElementById('phone_number').value;
	var email = document.getElementById('email').value;
	var title = document.getElementById('title').value;
	var companyname = document.getElementById('companyname').value;
	WebLeadExt.addNewWebLead( 
		firstname, 
		lastname, 
		phone_number,
		email,
		title,
		companyname,
		notes,
		function(results, event) {
			console.log(results);
			wlId = results.Id;
			var wlName = results.First_Name__c;
		} 
	);
}
function addNotesToNewWebLead() {
	WebLeadExt.addNotesToNewWebLead( 
		wlId,
		notes,
		function(results, event) {
			console.log(results);
		} 
	);
}
