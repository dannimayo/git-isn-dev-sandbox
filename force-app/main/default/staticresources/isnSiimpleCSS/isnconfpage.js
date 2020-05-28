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
function toggleCheckBox(divId,cbId){
	var NAME = document.getElementById(divId);
	var currentClass = NAME.className;
	if (currentClass == "isn-selected btn btn-small") {
		NAME.className = "isn-selector btn-small";
		document.getElementById(cbId).checked = false;
	} else {
		NAME.className = "isn-selected btn btn-small";
		document.getElementById(cbId).checked = true;
	}
}
function updateHiddenValue(fieldId,updateFieldId) {
	newVal = document.getElementById(fieldId).value;
	document.getElementById(updateFieldId).value = newVal;
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
		}
	}
	notes = notes + "\r\n\r\n";
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