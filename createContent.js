/*
 * Script-Datei die genutzt wird wenn Elemente für HTML mittels 
 * Javascript erstellt werden
 */


/**
 * Erstellt einen neuen Button
 * @param {type} text Beschriftung des Buttons
 * @param {type} container Oberelement in dem der Button sich befindet
 * @param {type} onClickFunc Function die beim Klicken auf den Button 
 * ausgelöst wird
 * @param {type} id ID des Buttons
 */
function createButton(text, container, onClickFunc, id) {                            
  var btn = document.createElement("button");
  btn.setAttribute("onclick", onClickFunc);
  btn.setAttribute("id", id);
  btn.setAttribute("class", "btn");
  btn.textContent = text;
  container.appendChild(btn);
}

/**
 * Erstellt ein neues Inputfeld
 * @param {type} placeholder Platzhalter im Inputfeld der zur näheren
 * erläuterung der Eingabe genutzt werden kann
 * @param {type} id ID des Inputfeldes
 * @param {type} container Oberelement in dem das Inputfeld sich befindet 
 * befindet
 * @param {type} labelText Label des Feldes, kann leer sein
 * @param {type} onChFun Function die bei veränderung ausgeführt wird, kann 
 * leer sein
 */
function addInput(placeholder, id, container, labelText, onChFun) {      

  var div = document.createElement("div");
  div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");

  if (labelText != "") {
    var label = document.createElement("label");
    label.setAttribute("for", id);
    label.textContent = labelText;
    div.appendChild(label);
  }
  var input = document.createElement("input");
  input.setAttribute("placeholder", placeholder);
  if (labelText != "")
    input.setAttribute("style", "float: right;");
  input.setAttribute("id", id);
  input.setAttribute("onchange", onChFun);
  div.appendChild(input);

  container.appendChild(div);

}

/**
 * Erstellt ein neues Div zur Darstellung von Text
 * @param {type} container Oberelement in dem das Div sich befindet 
 * @param {type} text Der darzustellende Text
 */
function addDiv(container, text) {                                           
  var div = document.createElement("div");
  div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");
  div.textContent = text;
  container.appendChild(div);
}

/**
 * Erstellt eine neue Radiobox mit einem Label
 * @param {type} container Oberelement in dem die Radiobox sich befindet 
 * @param {type} name Name der Radiobox
 * @param {type} text Inhalt des Labels und ID der Radiobox
 * @param {type} func Onchange funtion der Radiobox
 */
function addRadioNewTime(container, name, text, func) {                         
  var div = document.createElement("div");
  div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");

  var label = document.createElement("label");
  label.setAttribute("for", text);
  label.textContent = text;
  div.appendChild(label);

  var radio = document.createElement("input");
  radio.setAttribute("type", "radio");
  radio.setAttribute("name", name);
  radio.setAttribute("id", text);
  radio.setAttribute("style", "float: right;");
  radio.setAttribute("onchange", func);
  div.appendChild(radio);

  container.appendChild(div);
}

////////////////////Tabellenerstellung////////////////////

/**
 * Erstellt die Kopfzeile einer Tabelle
 * @param {type} containerId Oberelement-ID des Elements in dem sich die 
 * Tabelle befindet 
 * @param {type} headings Liste der Einzelnen Kopfelemente
 * @param {type} functions Liste von Onclick Funktion der Einzelnen Kopfelemente
 */
function createHeadRow(containerId, headings, functions) {
  var container = document.getElementById(containerId);
  var row = document.createElement("div");
  row.setAttribute("class", "row");
  
  headings = headings.split("#");
  functions = functions.split('#');
  for (var i = 0; i < headings.length; i++) {
    createHeadColumn(headings[i], row, functions[i]);    
  }  
  container.appendChild(row);
}

/**
 * Erstellt eine einzelne Spalte für die Kopfzeile
 * @param {type} text Inhalt der Spalte
 * @param {type} container Oberelement in dem sich die Kopfspalte befindet
 * @param {type} func Mögliche Onclick Funktion der Kopfspalte
 */
function createHeadColumn(text, container, func) {
  var column = document.createElement("div");
  column.setAttribute("class", "column");
  column.setAttribute("id", text + "Id");
  column.setAttribute("onclick", func);
  column.textContent = text;
  container.appendChild(column);
}

/**
 * Erstellt eine neue Zeile mit Daten zu einem Geoobjekt
 * @param {type} objectId ID des Objekts das in der Zeile dargestellt wird
 * @param {type} name Name/n des Objektes das in der Zeile dargestellt wird
 * @param {type} since Start der Gültigkeit des in der Zeile dargestellten
 * Objektes
 * @param {type} until Ende der Gültigkeit des in der Zeile dargestellten
 * Objektes
 * @param {type} id ID der Zeile
 * @param {type} containerId Oberelement-ID des Elements in dem sich die 
 * Tabelle befindet 
 * @param {type} rowIntern zusätzliches Mitzählen der Zeilen zur Identifikation 
 * der einzelnen Zeilen
 */
function createRow(objectId, name, since, until, id, containerId, rowIntern) {

  var container = document.getElementById(containerId);
  var row = document.createElement("div");
  row.setAttribute("class", "row nonHead");
  row.setAttribute("id", id);

  createColumnRadio(row, id, 0, rowIntern);
  createColumnDiv(objectId, row, id, 1, rowIntern);
  createColumnDiv(name, row, id, 2, rowIntern);
  createColumnDiv(since, row, id, 3, rowIntern);
  createColumnDiv(until, row, id, 4, rowIntern);
  
  container.appendChild(row);
}

/**
 * Erstellt eine neue Zeile mit Daten zu einem Tag einem Objektes
 * @param {type} key Key/Name des Tags
 * @param {type} value Value/Wert des Tags
 * @param {type} since Start der Gültigkeit des Tags
 * @param {type} until Ende der Gültigkeit des Tags
 * @param {type} id ID der Zeile
 * @param {type} containerId Oberelement-ID des Elements in dem sich die 
 * Tabelle befindet 
 */
function createRowTag(key, value, since, until, id, containerId) {

  var container = document.getElementById(containerId);
  var row = document.createElement("div");
  row.setAttribute("class", "row nonHead");
  row.setAttribute("id", id);

  createColumn(key, row, id, 0);
  createColumn(value, row, id, 1);
  createColumn(since, row, id, 2);
  createColumn(until, row, id, 3);

  var eraser = document.createElement("a");
  eraser.textContent = "[-]";
  eraser.setAttribute("style", "cursor: pointer; color: blue;");
  eraser.setAttribute("onclick", "removeRow(\"table\", '" + id + "')");
  row.appendChild(eraser);

  container.appendChild(row);
}

/**
 * Erstellt die Spalte einer Zeile
 * @param {type} key Wert der Spalte
 * @param {type} container Das Reihenelement als container
 * @param {type} id ID der Zeile
 * @param {type} ele Das n-te Element der Zeile, zur Identifikation
 * @param {type} rowIntern zusätzliches Mitzählen der Zeilen zur Identifikation 
 * der einzelnen Zeilen, genutzt zur Identifikation
 */
function createColumnDiv(key, container, id, ele, rowIntern) {
  var column = document.createElement("div");
  column.setAttribute("class", "column");
  var columnDiv = document.createElement("div");
  columnDiv.textContent = key;
  columnDiv.setAttribute("id", id + "+" + ele + "+" + rowIntern);
  columnDiv.setAttribute("style", "max-width: 190px;")
  column.appendChild(columnDiv);
  container.appendChild(column);
}

/**
 * Erstellt eine Radiobox in der Zeile
 * @param {type} container Zeile in der sich die Box befindet
 * @param {type} id ID der Zeile
 * @param {type} ele n-tes Element der Rihe
 * @param {type} rowIntern zusätzliches Mitzählen der Zeilen zur Identifikation 
 * der einzelnen Zeilen, genutzt zur Identifikation
 */
function createColumnRadio(container, id, ele, rowIntern) {
  var column = document.createElement("div");
  column.setAttribute("class", "column");
  var columnRadio = document.createElement("input");
  columnRadio.setAttribute("type", "radio");
  columnRadio.setAttribute("name", "layerSwitcher");
  columnRadio.setAttribute("id", id + "+" + ele + "+" + rowIntern);
  columnRadio.setAttribute("onchange", "switchLayer('" + id + "')");
  column.appendChild(columnRadio);
  container.appendChild(column);
}

/**
 * Erstellt eine Spalte in einer Zeile
 * @param {type} key Inhalt der Spalte
 * @param {type} container Die Zeile als Container
 * @param {type} id ID der Zeile
 * @param {type} ele n-tes Element der Zeile, zur identifikation
 */
function createColumn(key, container, id, ele) {
  var column = document.createElement("div");
  column.setAttribute("class", "column");

  var columnInput = document.createElement("input");
  columnInput.setAttribute("value", key);
  columnInput.setAttribute("id", id + "+" + ele);
  if (ele == 2) {
    columnInput.setAttribute("class", "columnInput since");
  } else {
    if (ele == 3) {
      columnInput.setAttribute("class", "columnInput until");
    } else {
      columnInput.setAttribute("class", "columnInput");
    }
  }
  if (ele == 2 || ele == 3) {
    columnInput.setAttribute("onchange", "checkNchange('" + id + "+" + ele + "');saveChange('" + id + "+" + ele + "', '" + id + "', '" + ele + "')");
  } else {
    columnInput.setAttribute("onchange", "saveChange('" + id + "+" + ele + "', '" + id + "', '" + ele + "')");
  }
  column.appendChild(columnInput);
  container.appendChild(column);
}

/**
 * Entfernt eine Zeile aus der Tabelle
 * @param {type} containerId ID des Containers
 * @param {type} input ID der Zeile
 */
function removeRow(containerId, input) {
  var toBeErased = document.getElementById(input);
  document.getElementById(containerId).removeChild(toBeErased);
  completeData.splice(input, 1);
}
      
