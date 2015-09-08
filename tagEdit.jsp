<%-- 
    Document   : tagEdit
    Created on : 25.05.2015, 12:48:57
    Author     : Tommy Ball
--%>

<%@page import="org.json.JSONArray"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URLDecoder"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <title>OHDM - Editor</title>
    <script type="text/javascript" src="tagList.js"></script>
    <script type="text/javascript" src="dateRelated.js"></script>
    <script type="text/javascript" src="tagDropdown.js"></script>
    <script type="text/javascript" src="createContent.js"></script>
    <%

      String origId = "";
      String since = "";
      String until = "";
      String tagKeys = "";
      String tagValues = "";
      StringBuilder aresponse = null;

      try {

        origId = request.getParameter("originalID");                               // Die original ID

        String token = "b13d3b247d0c0a4c5ddd6db91b5108e123bdb8fbda9d0cfbdebb806f0a9408c3210579cc53d44d6addd00a78e972747522a4dc3928cd99975a5f462ee1062395";
        response.setContentType("text/html;charset=UTF-8");

        URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
        //URL url = new URL("http://127.0.0.1:8080/OhdmApi/"
                + "geographicObject/"
                + origId);                  // Die Eingangsgeometrie (data)
        HttpURLConnection con = (HttpURLConnection) url.openConnection();                 // Verbindung herstellen
        con.setRequestMethod("GET");
        con.setRequestProperty("Content-Type",
                "application/json; charset=utf-8");
        con.setRequestProperty("Authorization", "Bearer " + token);

        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream()));
        String inputLine;
        aresponse = new StringBuilder();                                  // StringBuilder fuer die zu empfangenden Daten

        while ((inputLine = in.readLine()) != null) {
          aresponse.append(inputLine);                                                  // Empfangene Daten Zeilenweise zusammensetzen
        }
        in.close();

        JSONArray jsonArray = new JSONArray('[' + aresponse.toString() + ']');

        JSONArray tagDateList = new JSONArray(jsonArray.getJSONObject(0).get("tagDates").toString());

        int timeCounter = tagDateList.length();

        for (int i = 0; i < timeCounter; i++) {
          // Filter since und until, für einen Zeitraum
          JSONArray timeZone = new JSONArray("[" + tagDateList.getJSONObject(i).get("valid").toString() + "]");
          since += timeZone.getJSONObject(0).get("since").toString();
          until += timeZone.getJSONObject(0).get("until").toString();

          String tmpKey = "";
          JSONArray tagList = new JSONArray('[' + tagDateList.getJSONObject(i).get("tags").toString() + ']');
          
          // Filtern aller Key-Value Paare eines Zeitraumes
          for (int j = 0; j < tagList.getJSONObject(0).length(); j++) {                // Ausfiltern der Tag keys und Values des aktuellen Objekts
            tmpKey = tagList.getJSONObject(0).names().getString(j);
            tagKeys += tmpKey;
            tagValues += tagList.getJSONObject(0).getString(tmpKey);
            if (j < tagList.getJSONObject(0).length() - 1) {
              tagKeys += "#";
              tagValues += "#";
            }
          }
          // Trennen der Zeiträume
          if (i < timeCounter - 1) {
            since += "#";
            until += "#";
            tagKeys += "####";
            tagValues += "####";
          }
        }
        
        
        tagValues = new String(tagValues.getBytes(), "UTF-8");                            // UTF-8 entschlüsseln

        tagKeys = new String(tagKeys.getBytes(), "UTF-8");                                // UTF-8 entschlüsseln

      } catch (Exception e) {
        out.println("Keine Parameter gefunden");
        origId = "";
      }
    %>

    <script type="text/javascript">
      var since = '<%= since%>'.split("#");                                             // Since und until aufnehmen und in Arrays umwandeln
      var until = '<%= until%>'.split("#");
      var tagKeys = '<%= tagKeys%>'.split("####");                                      // Key- und Value-String auftrennen und in Array umwandeln
      var tagValues = '<%= tagValues%>'.split("####");
      var listOrder = [];
      var completeData = [];
      
      var keyUp = 1;
      var valueUp = 0;
      var sinceUp = 0;
      var untilUp = 0;

      var rowId = 0;

      function init() {
        if ('<%= origId%>' == "" || '<%= origId%>' == null) {
          alert("Keine Parameter gefunden... Zurück zum Anfang")
          backToIndex();
        }
        // erstellung Tabelle
        createHeadRow("table","key#value#Gültig von#Gültig bis#Löschen","sortKeys()#sortValues()#sortSince()#sortUntil()#");
        fillListUnordered();
        sortKeys();
        fillMainSelect();
      }

      /**
       * Speichert Änderungen in der Tabelle
       */
      function saveChange(id, row, ele) {
        var tmp = completeData[row].split('###');
        tmp[ele] = document.getElementById(id).value;
        completeData[row] = tmp.join('###');
      }

      /**
       * Füllt Liste mit allen Daten in der Reihenfolge wie sie aus dem JSON
       * gefiltert wurden
       */
      function fillListUnordered() {
        for (var i = 0; i < tagKeys.length; i++) {
          var tmpKeys = tagKeys[i].split("#");
          var tmpValues = tagValues[i].split("#");
          var tmpSince = since[i];
          var tmpUntil = until[i];
          for (var j = 0; j < tmpKeys.length; j++) {
            //
            completeData.push(tmpKeys[j] + "###" + tmpValues[j] + "###" + tmpSince + "###" + tmpUntil);
          }
        }
      }

////////////////////////////////Sortieren///////////////////////////////////////

      /**
       * Ändert die Namen im Kopf der Tabelle
       * @param key Name für den ersten Tabellenkopf
       * @param value Name für den zweiten Tabellenkopf
       * @param since Name für den dritten Tabellenkopf
       * @param until Name für den vierten Tabellenkopf
       */
      function switchNames(key, value, since, until) {
        document.getElementById("keyId").textContent = key;
        document.getElementById("valueId").textContent = value;
        document.getElementById("Gültig vonId").textContent = since;
        document.getElementById("Gültig bisId").textContent = until;
      }

      /**
       * Sortiert die Tabelle nach Keys
       * wechselnd auf- und absteigend
       */
      function sortKeys() {
        completeData.sort(function (a, b) {
          return a.toLowerCase().localeCompare(b.toLowerCase());
        });
        ;
        if (keyUp == 1) {
          keyUp = 0;
          valueUp = 1;
          sinceUp = 1;
          untilUp = 1;
          switchNames("key \u2228", "value", "Gültig von", "Gültig bis");
        } else {
          keyUp = 1;
          completeData.reverse();
          switchNames("key \u2227", "value", "Gültig von", "Gültig bis");
        }
        writeData();
      }

      /**
       * Sortiert die Tabelle nach Values
       * wechselnd auf- und absteigend
       */
      function sortValues() {
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[1] + "###" + tmpCompleteData[2] + "###" + tmpCompleteData[3] + "###" + tmpCompleteData[0];
        }
        completeData.sort(function (a, b) {
          return a.toLowerCase().localeCompare(b.toLowerCase());
        });
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[3] + "###" + tmpCompleteData[0] + "###" + tmpCompleteData[1] + "###" + tmpCompleteData[2];
        }
        if (valueUp == 1) {
          keyUp = 1;
          valueUp = 0;
          sinceUp = 1;
          untilUp = 1;
          switchNames("key", "value \u2228", "Gültig von", "Gültig bis");
        } else {
          valueUp = 1;
          completeData.reverse();
          switchNames("key", "value \u2227", "Gültig von", "Gültig bis");
        }
        writeData();
      }

      /**
       * Sortiert die Tabelle nach Sincedaten
       * wechselnd auf- und absteigend
       */
      function sortSince() {
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[2] + "###" + tmpCompleteData[3] + "###" + tmpCompleteData[0] + "###" + tmpCompleteData[1];
        }
        completeData.sort(function (a, b) {
          a = createDate(a.split('###')[0]);
          b = createDate(b.split('###')[0]);
          return a.getTime() - b.getTime()
        });
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[2] + "###" + tmpCompleteData[3] + "###" + tmpCompleteData[0] + "###" + tmpCompleteData[1];
        }
        if (sinceUp == 1) {
          keyUp = 1;
          valueUp = 1;
          sinceUp = 0;
          untilUp = 1;
          switchNames("key", "value", "Gültig von \u2228", "Gültig bis");
        } else {
          sinceUp = 1;
          completeData.reverse();
          switchNames("key", "value", "Gültig von \u2227", "Gültig bis");
        }
        writeData();
      }

      /**
       * Sortiert die Tabelle nach Untildaten
       * wechselnd auf- und absteigend
       */
      function sortUntil() {
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[3] + "###" + tmpCompleteData[0] + "###" + tmpCompleteData[1] + "###" + tmpCompleteData[2];
        }
        completeData.sort(function (a, b) {
          a = createDate(a.split('###')[0]);
          b = createDate(b.split('###')[0]);
          return a.getTime() - b.getTime()
        });
        for (var i = 0; i < completeData.length; i++) {
          var tmpCompleteData = completeData[i].split("###");
          completeData[i] = tmpCompleteData[1] + "###" + tmpCompleteData[2] + "###" + tmpCompleteData[3] + "###" + tmpCompleteData[0];
        }
        if (untilUp == 1) {
          keyUp = 1;
          valueUp = 1;
          sinceUp = 1;
          untilUp = 0;
          switchNames("key", "value", "Gültig von", "Gültig bis \u2228");
        } else {
          untilUp = 1;
          completeData.reverse();
          switchNames("key", "value", "Gültig von", "Gültig bis \u2227");
        }
        writeData();
      }

/////////////////////////Schreiben//////////////////////////////////////////////

      /**
       * Löscht beim anfügen oder entfernen von Zeilen die Tabelle und schreibt 
       * die neue, aktuelle Tabelle
       */
      function writeData() {

        var tags = document.getElementsByClassName("nonHead");
        var lengthTags = tags.length;
        for (var i = 0; i < lengthTags; i++) {
          var container = document.getElementById("table");
          container.removeChild(tags[0]);
        }
        rowId = 0;
        for (var i = 0; i < completeData.length; i++) {
          var tmpList = completeData[i].split('###');
          createRowTag(tmpList[0], tmpList[1], tmpList[2], tmpList[3], rowId, "table");
          rowId++;
        }
      }

      /**
       * Fügt, nach kompletter Überprüfung auf Richtigkeit, eine neue Zeile/Tag
       * in die Tabelle ein
       * (Dopplungen noch nicht behandelt)
       */
      function addTag() {
        var keyBox = document.getElementById("keyContainer");
        var valueBox = document.getElementById("valueContainer");
        var sinceBox = document.getElementById("sinceContainer");
        var untilBox = document.getElementById("untilContainer");
        var btnBox = document.getElementById("btnContainer");

        var keyField = document.getElementById("keyField").value;
        var valueField = document.getElementById("valueField").value;
        var sinceField = document.getElementById("sinceField").value;
        var untilField = document.getElementById("untilField").value;

        if (keyField == "" || valueField == "" || sinceField == "" || untilField == "") {
          alert("Alle Felder müssen ausgefüllt werden!");
        } else {
          var tmpSinceField = sinceField;
          var tmpUntilField = untilField;
          if (checkIfCorrectDate(getSingleDates(tmpSinceField)) == 1 || checkIfCorrectDate(getSingleDates(tmpUntilField)) == 1) {
            alert("Die Daten sind nicht in der korrekten Form (YYYY-MM-DD)!")
          } else {
            tmpSinceField = createDate(tmpSinceField);
            tmpUntilField = createDate(tmpUntilField);
            if (tmpUntilField < tmpSinceField) {
              alert("'bis:' muss zeitlich nach 'Von:' liegen!");
            } else {
              createRowTag(keyField, valueField, sinceField, untilField, rowId, "table");
              rowId++;
              completeData.push(keyField + "###" + valueField + "###" + sinceField + "###" + untilField);

              document.getElementById("mainTagSelect").value = "";
              document.getElementById("secondaryTagSelect").value = "";
              document.getElementById("chooseSecondaryCategory").style.visibility = "hidden";

              keyBox.style.visibility = "hidden";
              valueBox.style.visibility = "hidden";
              sinceBox.style.visibility = "hidden";
              untilBox.style.visibility = "hidden";
              btnBox.style.visibility = "hidden";

              keyField.value = "";
              valueField.value = "";
              sinceField.value = "";
              untilField.value = "";
            }
          }
        }
      }

      /**
       * Nach Prüfung auf Richtigkeit wird die Tabelle in einen JSON umgewandelt 
       * und an die nächste Seite gesendet
       */
      function finish() {
        if (checkAll() == true) {
          var origId = '<%= origId%>';
          var newJSON = '[';
          for (var i = 0; i < completeData.length; i++) {
            var tmp = completeData[i].split("###");

            newJSON += '{"tags":{"' + tmp[0] + '":"' + tmp[1] + '"},"valid":{"since":"'
                    + tmp[2] + '","until":"' + tmp[3] + '"}}';
            if (i < completeData.length - 1) {
              newJSON += ",";
            }
          }
          newJSON += "]";
          document.cookie = "allowSend=true";
          document.cookie = "sendKind=tag";

          document.getElementById("originalId").value = origId;
          document.getElementById("JSONString").value = newJSON;
          document.getElementById("JSON_submit").click();
        } else {
          alert("Angegebene Daten sind nicht korrekt, speichern nicht möglich!");
        }
      }

      /**
       * Überprüft alle Elemente der Tabelle auf Richtigkeit und gibt true 
       * zurück wenn alles stimmt
       * @returns {Boolean} true wenn Tabelle korrekt, false sonst     
       */
      function checkAll() {
        var sinceList = document.getElementsByClassName("since");
        var untilList = document.getElementsByClassName("until");
        var correct = true;
        if (sinceList.length == 0) {
          correct = false;
          alert("Keine Tags mehr vorhanden!");
        } else {
          for (var i = 0; i < sinceList.length; i++) {
            if (sinceList[i].value == "" || untilList[i].value == "") {
              alert("Alle Felder müssen ausgefüllt werden!");
              correct = false;
              i = sinceList.length;
            } else {
              if (compareTimesPrep(sinceList[i].value, untilList[i].value) == 1) {
                alert("Fehlerhafte Eingabe, speichern der Änderungen ist nicht gestattet!")
                correct = false;
                i = sinceList.length;
              }
            }
          }
        }
        return correct;
      }
      
      /**
       * Zurück zur Startseite
       */
      function backToIndex() {
        window.location = "index.jsp";
      }

    </script>

    <style>
      .inputContainer {
        width: 400px;     
        padding-top: 20px;
      }

      .headDiv {
        width: 725px;
        //margin: 0px auto;
        padding-top: 20px;
        padding-bottom: 40px;
        background-color: red;
      }

      .inputField {
        float: right;
      }

      .validField {
        float: left;
        padding-left: 10px;
        padding-right: 10px;
      }


      #table {
        width: 1000px;


      }

      .row {
        display: table;
        width: 100%; 
        table-layout: fixed; 
        border-spacing: 5px; 
      }

      .column {
        display: table-cell;

      }

      .columnInput{        
        width: 95%;        
        //margin-right: 0.5%;
      }

      .Btn {
        margin-top: 20px;
      }

      .inputFieldContainer {
        margin-top: 15px;
        width:200px;
      }      

      #chooseSecondaryCategory, #btnContainer, #chooseCategory, #keyValueList {
        margin-top: 15px;
      }

      .inputFieldTag {
        float: right;   
        width: 150px;
      }  
    </style>

  </head>
  <body onload="init()">
    <h1>Tags Editieren</h1> 
    <!--    <select id="existingTimeZones" onchange="changeStart()" ></select> -->
    <div id="table"></div>

    <a id="filterIntro">Neues Tag erstellen:</a>

    <div id="chooseCategory">
      <label for="mainTagSelect">Bitte eine Kategorie wählen: </label>
      <select id="mainTagSelect" onchange="createContentMain(2)"> </select>
    </div>
    <div id="chooseSecondaryCategory" style="visibility:hidden;">
      <label for="secondaryTagSelect">Bitte passenden Tag wählen: </label>
      <select id="secondaryTagSelect" onchange="handleSecond(2)"> </select>
    </div>
    <div id="keyContainer" class="inputFieldContainer" style="visibility:hidden;">
      <label id="label" for="keyField">Key: </label>
      <input type="text" class="inputFieldTag" id="keyField" value =""  />          
    </div>
    <div id="valueContainer" class="inputFieldContainer" style="visibility:hidden;">
      <label id="label" for="valueField">Value: </label>
      <input type="text" class="inputFieldTag" id="valueField" value ="" />          
    </div>        
    <div id="sinceContainer" class="inputFieldContainer" style="visibility:hidden;">
      <label id="label" for="valueField">Von: </label>
      <input type="text" onchange="checkNchange('sinceField')" class="inputFieldTag" id="sinceField" value ="" />          
    </div>     
    <div id="untilContainer" class="inputFieldContainer" style="visibility:hidden;">
      <label id="label" for="valueField">bis: </label>
      <input type="text" onchange="checkNchange('untilField')" class="inputFieldTag" id="untilField" value ="" />          
    </div>     
    <div id="btnContainer" style="visibility:hidden;">          
      <input type="button" onclick="addTag()" class="btn" id="btn" value ="Tag hinzufügen"/>          
    </div>

    <button id="finish" onclick="finish()" class="Btn">Änderungen beenden und speichern</button>
    <button id="abord" onclick="backToIndex()" class="Btn">Änderungen verwerfen und zurück zum Anfang</button>


    <form action="transmit.jsp" id="formular" method="post" accept-charset="UTF-8">
      <input id="originalId" name="originalId" type="text" style="display: none;"/>
      <input id="JSONString" name="JSONString" type="text" style="display: none;"/>      
      <input id="JSON_submit" type="submit" style="display: none;"/>
    </form>
  </body>
</html>
