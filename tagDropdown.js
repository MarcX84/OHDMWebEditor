/* 
 * Script-Datei die genutzt wird um die Element zu verwalten die für die
 * Drop-Down Menüs der Tagauswahl verantwortlich sind 
 */


/**
 * Füllt ein Options Feld mit Haupttags, aus der OSM-Liste, füllt
 */
function fillMainSelect() {
  var selectField = document.getElementById("mainTagSelect");
  var filler = document.createElement("option");
  filler.setAttribute("value", "");
  filler.textContent = "";
  filler.setAttribute("style", "display:none");
  selectField.appendChild(filler);

  for (var i = 0; i < standardTags.length; i++) {
    var tagOption = document.createElement("option");
    tagOption.setAttribute("value", standardTags[i]);
    tagOption.textContent = standardTags[i];
    selectField.appendChild(tagOption);
  }
}

/**
 * Erstellt weitere Eingabefelder um, entsprechend des gewählten maintags
 * weiter spezifizieren zu können.
 * @param {type} variante Bestimmt ob bei der Eingabe auch ein Datum abgefragt
 * wird, dies geschieht bei dem Wert 2
 */
function createContentMain(variante) {
  var index = standardTags.indexOf(document.getElementById("mainTagSelect").value);
  var keyBox = document.getElementById("keyContainer");
  var valueBox = document.getElementById("valueContainer");
  var sinceBox = "";
  var untilBox = "";
  var btnBox = document.getElementById("btnContainer");



  var keyField = document.getElementById("keyField");
  var valueField = document.getElementById("valueField");
  var sinceField = "";
  var untilField = "";

  var secondSelect = document.getElementById("secondaryTagSelect");

  keyField.value = "";
  valueField.value = "";

  if (variante == 2) {
    sinceBox = document.getElementById("sinceContainer");
    untilBox = document.getElementById("untilContainer");
    sinceField = document.getElementById("sinceField");
    untilField = document.getElementById("untilField");
    sinceField.value = "";
    untilField.value = "";
  }

  document.getElementById("secondaryTagSelect").value = "";

  if (document.getElementById("mainTagSelect").value === "user defined") {
    document.getElementById("chooseSecondaryCategory").style.visibility = "hidden";
    keyBox.style.visibility = "visible";
    keyField.disabled = false;
    valueBox.style.visibility = "visible";
    valueField.disabled = false;
    if (variante == 2) {
      sinceBox.style.visibility = "visible";
      sinceField.disabled = false;
      untilBox.style.visibility = "visible";
      untilField.disabled = false;
    }
    btnBox.style.visibility = "visible";
  } else {
    document.getElementById("chooseSecondaryCategory").style.visibility = "visible";
    fillSecond(secondSelect, index);
    keyBox.style.visibility = "visible";
    keyField.value = standardTags[index];
    keyField.disabled = true;
    valueBox.style.visibility = "hidden";
    if (variante == 2) {
      sinceBox.style.visibility = "hidden";
      untilBox.style.visibility = "hidden";
    }
    btnBox.style.visibility = "hidden";
  }
}

/**
 * Füllt ein zweites optin Feld mit den Untertags zum gewählten Obertag
 * @param {type} secondSelect Zweites option Element 
 * @param {type} value Position des gewählten Obertags in der List der Tags
 */
function fillSecond(secondSelect, value) {
  var filler = document.createElement("option");
  filler.setAttribute("value", "");
  filler.textContent = "";
  filler.setAttribute("style", "display:none");
  secondSelect.appendChild(filler);

  for (var i = 0; i < unterTags[value].length; i++) {
    var tagOption = document.createElement("option");
    tagOption.setAttribute("value", unterTags[value][i]);
    tagOption.textContent = unterTags[value][i];
    secondSelect.appendChild(tagOption);
  }
}

/**
 * Bei wahl des Untertags wird entsprechend reagiert - gewählter Tag wird in
 * ein Input geschrieben, bei dem keine Änderung möglich ist, oder ein
 * leerer Input wird gegeben in der eingetragen werden kann, wenn es
 * gewünscht ist.
 * @param {type} variante Bestimmt ob bei der Eingabe auch ein Datum abgefragt
 * wird, dies geschieht bei dem Wert 2
 */
function handleSecond(variante) {

  var valueBox = document.getElementById("valueContainer");
  var btnBox = document.getElementById("btnContainer");

  var valueField = document.getElementById("valueField");

  valueField.value = "";

  valueBox.style.visibility = "visible";
  btnBox.style.visibility = "visible";

  if (variante == 2) {
    var sinceBox = document.getElementById("sinceContainer");
    var untilBox = document.getElementById("untilContainer");
    sinceBox.style.visibility = "visible";
    untilBox.style.visibility = "visible";
  }

  if (document.getElementById("secondaryTagSelect").value === "user defined") {
    valueField.disabled = false;
  } else {
    valueField.value = document.getElementById("secondaryTagSelect").value;
    valueField.disabled = true;
  }
}
