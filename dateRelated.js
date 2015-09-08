/*
 * Scriptdatei mit Funktionen die für die Verarbeitung von Daten genutzt wird.
 */


/**
 * Erstellt eine List der Reihenfolge der Daten sodas diese sortiert sind
 * @param {type} times  alle vorhandenen Daten
 */
function orderTimes(times) {
  listOrder = [];
  listOrder.push(0);
  for (var i = 1; i < times.length; i++) {
    var tmp = i;
    for (var j = 0; j < listOrder.length; j++) {
      var compareTo = createDate(times[listOrder[j]]);
      var compareWith = createDate(times[i]);

      if (compareWith < compareTo) {
        tmp = listOrder[j];
        listOrder[j] = i;
        for (var k = j + 1; k < listOrder.length; k++) {
          var tmp2 = listOrder[k];
          listOrder[k] = tmp;
          tmp = tmp2;
        }
        j = listOrder.length;
      }
    }
    listOrder.push(tmp);
  }
}

/**
 * Sortiert Daten dem Alter nach und speichert Sie in einer Liste der Form
 * 'since bis until'
 * @param {type} since Liste der 'Start'-Daten
 * @param {type} until Liste der 'End'-Daten
 * @returns {Array|orderTimeZones.orderedList}  Liste der Daten als Strings
 */
function orderTimeZones(since, until) {
  var orderedList = [];
  orderTimes(since);
  for (var i = 0; i < listOrder.length; i++) {
    orderedList.push(since[listOrder[i]] + " bis " + until[listOrder[i]]);
  }
  return orderedList;
}

/*
 * Teilt einen Datumsstring der form YYYY-MM-DD in seine Einzeldaten auf
 * @param {type} fullDate 
 * @returns {String} geteiltes Datum -> YYYY,MM,DD
 */
function getSingleDates(fullDate) {
  var neg = 0;
  if (fullDate.indexOf('-') === 0) {
    neg = 1;
    fullDate = fullDate.substr(1);
  }
  var singleDates = fullDate.split("-");
  if (neg === 1) {
    singleDates[0] = "-" + singleDates[0];
    neg = 0;
  }
  return singleDates;
}

/**
 * Ueberprueft ob ein Datum zwischen zwei anderen Daten liegt
 * @param {type} newDate  Das zu ueberpruefende Datum
 * @param {type} oldSince Das zeitlich aeltere Datum
 * @param {type} oldUntil Das zeitlich juengere Datum
 * @returns {Number}  0 vor beiden Daten; 1 zwischen den Daten, 2 nach beiden Daten
 */
function checkIfBetween(newDate, oldSince, oldUntil) {
  var position = 0;                                                         // 0 vor der Zeitachse, 1 in der Zeitachse, 2 nach der Zeitachse
  var afterSince = "false";
  var afterUntil = "false";  
  if (compareTimes(newDate, oldSince) == 1) {
    afterSince = "true";
  }
  if (compareTimes(oldUntil, newDate) == 0) {
    afterUntil = "true";
  }
  if (afterSince === "false" && afterUntil === "false")
    position = 0;
  if (afterSince === "true" && afterUntil === "false")
    position = 1;
  if (afterSince === "true" && afterUntil === "true")
    position = 2;
  return position;
}

/**
 * Ueberprueft ob zu vergleichende Daten tatsaechlich valide Daten sind
 * @param {type} since  Datum Nummer 1
 * @param {type} until  Datum nummer 2
 * @returns {Number}  0 falls alles OK ist, 1 sonst
 */
function compareTimesPrep(since, until) {
  var inputSince = getSingleDates(since);
  var inputUntil = getSingleDates(until);
  var error = 0;

  if (checkIfCorrectDate(inputSince) === 1) {
    error = 1;
  }
  if (checkIfCorrectDate(inputUntil) === 1) {
    error = 1;
  }
  if (error === 1) {
  }
  else {
    var compared = compareTimes(since, until)
    if (compared === 1) {
      alert("'von' muss zeitlich vor 'bis' liegen!")
    }
    error = compared;
  }
  return error;
}

/**
 * Vergleicht zwei Daten
 * @param {type} a  Datum Nummer 1
 * @param {type} b  Datum Nummer 2
 * @returns {Number}  0 --> a < b; 1 --> a > b; 0 --> a == b 
 */
function compareTimes(a, b) {
  a = createDate(createCorrectDate(a));
  b = createDate(createCorrectDate(b));
  var BkleinerA = 0;
  if (b.getTime() < a.getTime())
    BkleinerA = 1;
  if (b.getTime() == a.getTime())
    BkleinerA = 2;
  return BkleinerA;
}

/**
 * Ueberprueft ob ein Datum wirklich ein richtiges Datum ist
 * @param {type} date Der String der das Datum darstellen soll
 * @returns {Number} gibt 0 zurueck wenn alles OK ist, 1 sonst
 */
function checkIfCorrectDate(date) {
  var error = 0;
  if (date.length !== 3) {
    error = 1;
  } else {
    if (isNaN(date[0]) === true ||
            isNaN(date[1]) === true ||
            isNaN(date[2]) === true) {
      error = 1;
    } else {
      if (validateDate(date[0], date[1], date[2]) === "false")
        error = 1;
    }
  }
  return error;
}

/**
 * Ueberprueft ob ein Datum wirklich ein existierendes Datum ist
 * @param {type} year Jahr
 * @param {type} month Monat
 * @param {type} day Tag
 * @returns {String} Gibt true zurueck wenn das Datum existiert, false sonst
 */
function validateDate(year, month, day) {
  var valid = "true";
  if (month > 12 || month < 1) {
    valid = "false";
  } else {
    if (day > getMaxDay(year, month) || day < 1)
      valid = "false";
  }
  return valid;
}

/**
 * Ermittelt den maximalen Tag eines Monats in Abhaengigkeit des 
 * Jahres und des Monats
 * @param {type} year Das Jahr als Nummer
 * @param {type} month Der Monat als Nummer
 * @returns {Number} Der maximale Tag des angegebenen Monats
 */
function getMaxDay(year, month) {
  var maxDay = 30;
  if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8
          || month == 10 || month == 12) {
    maxDay = 31;
  } else {
    if (month == 2) {
      maxDay = 28;
      if (year % 4 == 0) {
        maxDay = 29;
      }
      if (year % 100 == 0) {
        maxDay = 28;
      }
      if (year % 400 == 0) {
        maxDay = 29;
      }
    }
  }
  return maxDay;
}

/**
 * Erstellt Datums String der fuehrende Nullen hat
 * @param {type} date Ausgangsstring mit Datum
 * @returns {String} Datum mit fuehrenden Nullen (Bsp.: 9-9-9 -> 0009-09-09)
 */
function createCorrectDate(date) {
  date = getSingleDates(date);
  var neg = 0;
  if (date[0].indexOf("-") == 0) {
    date[0] = date[0].substr(1);
    neg = 1;
  }
  while (date[0].toString().length < 4) {
    date[0] = "0" + date[0].toString();
  }
  if (neg == 1)
    date[0] = "-" + date[0];
  if (date[1].toString().length < 2)
    date[1] = "0" + date[1].toString();
  if (date[2].toString().length < 2)
    date[2] = "0" + date[2].toString();
  return date[0] + "-" + date[1] + "-" + date[2];
}

/**
 * Erstellt ein ein Objekt vom Typ 'date' aus einem String
 * @param {type} date String der ein Datum enthaelt
 * @returns {String|Date} Object vom Typ 'date'
 */
function createDate(date) {
  if (date.indexOf('-') === 0) {
    date = getSingleDates(date);
    date = new Date(date[0], date[1] - 1, date[2]);
  } else {
    date = new Date(date);
  }
  return date;
}

/**
 * Erstellt Datum einen Tag vor (-) oder nach (+) einem gegebenem Datum
 * @param {type} date Ausgangsdatum
 * @param {type} operation  Operationszeichen welches festlegt ob das erstellte
 * Datum vor oder nach dem Ausgangsdatum liegt
 * @returns {String}  Datum einen Tag vor/nach dem Ausgangsdatum
 */
function trimDate(date, operation) {
  date = getSingleDates(date);
  if (operation === "+") {
    if (date[2] == getMaxDay(date[0], date[1])) {
      date[2] = 1;
      date[1] = parseInt(date[1]) + 1;
      if (date[1] == 13) {
        date[1] = 1;
        date[0] = parseInt(date[0]) + 1;
      }
    } else {
      date[2]++;
    }
  } else {
    if (date[2] == 1) {
      if (date[1] == 1) {
        date[0] = parseInt(date[0]) - 1;
        date[1] = 12;
        date[2] = 31;
      } else {
        date[1] = parseInt(date[1]) - 1;
        date[2] = getMaxDay(date[0], date[1]);
      }
    } else {
      date[2] = parseInt(date[2]) - 1;
    }
  }
  return createCorrectDate(date[0] + "-" + date[1] + "-" + date[2]);
}

/**
 * Sucht Position eines Neuen Datums in einer sortierten Liste von Daten
 * @param {type} newDate  Das zu testende Datum
 * @param {type} oldSince Liste aller 'Start'-Daten
 * @param {type} oldUntil Liste aller 'End'-Daten
 * @returns {String|Number} none: hinter letzten Element, positiv: vor Element von listOrder[pos]
 * negativ: in Achsenabschnitt von listOrder[pos]
 */
function getPos(newDate, oldSince, oldUntil) {
  var pos = "none";
  for (var i = 0; i < listOrder.length; i++) {    
    var tmp = checkIfBetween(newDate, oldSince[listOrder[i]], oldUntil[listOrder[i]]);    
    if (tmp < 2) {
      if (tmp === 0)
        pos = i;
      else
        pos = "-" + i;
      i = listOrder.length;
    }
  }
  return pos;
}

/**
 * Ueberprueft ob zwei Daten genau einen Tag auseinenader liegen
 * @param {type} testUntil  Das erste Datum
 * @param {type} testSince  Das zweite Datum
 * @returns {Boolean} true wenn genau ein tag zwischen ihnen liegt, false sonst
 */
function oneDayDifference(testUntil, testSince) {
  var oneDay = true;
  var testa = createDate(testUntil);
  var testb = createDate(testSince);
  if (testb.getTime() - testa.getTime() != 86400000)
    oneDay = false;
  return oneDay;
}

/**
 * Filtert value aus einer Eingabe und ueberprueft auf Korrektheit des Datums 
 * und aendert es in die Form YYYY-MM-DD
 * @param {type} id ID des Eingabe Elements
 */
function checkNchange(id) {
  var input = document.getElementById(id);
  if (input.value != "") {
    if (checkIfCorrectDate(getSingleDates(input.value)) != 1) {
      input.value = createCorrectDate(input.value);
    } else {
      alert("Fehlerhafte Eingabe");
    }
  }
}

/**
 * Ermittelt die Position eines neu erstellten Datums + Geometrie in einer Liste
 * bereits vorhandener Daten und trägt diese in die Listen der Daten/Geometrien ein.
 * @param {type} geom Die neue Geometrie
 * @param {type} oldSince Liste der bereit vorhandenen 'Since' - Werte
 * @param {type} oldUntil Liste der bereit vorhandenen 'Until' - Werte
 */
function getNewTimes(geom, oldSince, oldUntil) {
  oldSince = oldSince.split("#");
  oldUntil = oldUntil.split("#");
  var newSince = createCorrectDate(document.getElementById("sinceInput").value);
  var newUntil = createCorrectDate(document.getElementById("untilInput").value);

  var posSince = getPos(newSince, oldSince, oldUntil);
  var posUntil = getPos(newUntil, oldSince, oldUntil);

  if (posSince === "none" && posUntil === "none") {
    oldSince.push(newSince);
    oldUntil.push(newUntil);
    listOrder.push(oldSince.length - 1);
  } else {
    if (posSince !== posUntil) {
      newTimesDiffPos(posSince, posUntil, oldSince, oldUntil, newSince, newUntil);
    } else {
      newTimesSamePos(posSince, oldSince, oldUntil, newSince, newUntil);
    }
  }
  coordinates.push(geom);
  finalSince = oldSince;
  finalUntil = oldUntil;
  
}

/**
 * Befinden sich bereits vorhandene Daten in dem Zeitraum der neuen Daten
 * so werden diese hier überschrieben bzw. wenn nötig angepasst.
 * Bsp:
 * Altes Datum1: 01-01-0001 - 01-01-1000
 * Altes Datum2: 01-01-1001 - 01-01-1500
 * Neues Datum : 01-01-0500 - 01-01-2000
 * Ergebnis    : 01-01-0001 - 31-12-0499 & 
 *               01-01-0500 - 01-01-2000
 * ==> Datum1 wurde abgeändert und Datum2 komplett entfernt              
 * @param {type} posSince Position des neuen Sincedatums in der Liste der 
 *                        vorhandenen Sincedaten
 * @param {type} posUntil Position des neuen Untildatums in der Liste der 
 *                        vorhandenen Untildaten
 * @param {type} oldSince Liste der vorhandenen Sincedaten
 * @param {type} oldUntil Liste der vorhandenen Untildaten
 * @param {type} newSince Das neue Since-Datum
 * @param {type} newUntil Das neue Until-Datum
 */
function newTimesDiffPos(posSince, posUntil, oldSince, oldUntil, newSince, newUntil) {
  var stopList = 0;
  var continueList = 0;
  var tmpList = [];
  if (posSince[0] === "-") {
    if (compareTimes(oldSince[listOrder[posSince.substr(1)]], newSince) == 2) {
      stopList = parseInt(posSince.substr(1));
    } else {
      oldUntil[listOrder[posSince.substr(1)]] = trimDate(newSince, "-");
      stopList = parseInt(posSince.substr(1)) + 1;
    }
  } else {
    stopList = parseInt(posSince);
  }
  for (var i = 0; i < stopList; i++) {
    tmpList.push(listOrder[i]);
  }
  if (posUntil === "none") {
    continueList = listOrder.length;
  } else {
    if (posUntil[0] === "-") {
      if (compareTimes(oldUntil[listOrder[posUntil.substr(1)]], newUntil) == 2) {
        continueList = parseInt(posUntil.substr(1))+1;
      } else {
        oldSince[listOrder[posUntil.substr(1)]] = trimDate(newUntil, "+");
        continueList = parseInt(posUntil.substr(1));
      }
    } else {
      continueList = parseInt(posUntil);
    }
  }
  tmpList.push(oldSince.length);
  for (var i = continueList; i < listOrder.length; i++) {
    tmpList.push(listOrder[i]);
  }
  
  listOrder = tmpList;
  oldSince.push(newSince);
  oldUntil.push(newUntil);    
}

/**
 * Befinden sich die neuen Daten zwischen zwei angrenzender Daten so wird, im 
 * Fall das beide Daten zum gleichen Zeitraum gehören, das neue Datum in das
 * Vorhandene eingefügt und die alten Daten geändert. Liegt das neue Datum in 
 * einem Zwischenraum zwischen verschiedenen Zeiträumen, so wird es einfach 
 * eingefügt.
 * Bsp:
 * Altes Datum: 01-01-0001 - 01-01-2000
 * Neues Datum: 01-01-0500 - 31-12-0999
 * Ergebnis:    01-01-0001 - 31-12-0499 &
 *              01-01-0500 - 31-12-0999 &
 *              01-01-1000 - 01-01-2000 
 * @param {type} posSince Position des neuen Datums in der Liste der 
 *                        vorhandenen Daten
 * @param {type} oldSince Liste der vorhandenen Sincedaten
 * @param {type} oldUntil Liste der vorhandenen Untildaten
 * @param {type} newSince Das neue Since-Datum
 * @param {type} newUntil Das neue Until-Datum
 */
function newTimesSamePos(posSince, oldSince, oldUntil, newSince, newUntil) {
  var tmpList = [];
  if (posSince[0] === "-") {
    var tmpSince = oldSince[posSince.substr(1)];
    var tmpUntil = oldUntil[posSince.substr(1)];
    var addOne = 1;

    if (compareTimes(tmpSince, newSince) == 2)
      addOne = 0;

    for (var i = 0; i < parseInt(posSince.substr(1)) + parseInt(addOne); i++) {
      tmpList.push(listOrder[i]);
    }
    oldUntil[listOrder[posSince.substr(1)]] = trimDate(newSince, "-");    
    if (compareTimes(tmpUntil, newUntil) != 2) {      
      tmpList.push(listOrder.length + 1);
      tmpSince = trimDate(newUntil, "+");
      oldSince.push(tmpSince);
      oldUntil.push(tmpUntil);
      coordinates.push(coordinates[listOrder[posSince.substr(1)]]);
    }
    tmpList.push(listOrder.length);    
    for (var i = parseInt(posSince.substr(1)) + 1; i < listOrder.length; i++) {
      tmpList.push(listOrder[i]);
    }
    oldSince.push(newSince);
    oldUntil.push(newUntil);
    listOrder = tmpList;
  } else {
    if (compareTimes(oldSince[posSince], newUntil) == 2) {
      oldSince[posSince] = trimDate(newUntil, "+");
    }
    for (var i = 0; i < posSince; i++) {
      tmpList.push(listOrder[i]);
    }
    tmpList.push(listOrder.length);
    for (var i = posSince; i < listOrder.length; i++) {
      tmpList.push(listOrder[i]);
    }
    oldSince.push(newSince);
    oldUntil.push(newUntil);
    listOrder = tmpList;
  }
}

