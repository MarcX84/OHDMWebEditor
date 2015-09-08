<%-- 
    Document   : chooseNextAction
    Created on : 09.03.2015, 18:35:33
    Author     : Tommy Ball
--%>

<%@page import="org.json.JSONString"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.net.URL"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

    <title>OHDM - Editor</title>
    <script src="http://openlayers.org/api/OpenLayers.js"></script>    
    <script type="text/javascript" src="dateRelated.js"></script>
    <script type="text/javascript" src="createContent.js"></script>
    <style type="text/css"></style>

    <%

      response.setContentType("text/html;charset=UTF-8");

      String name = "";

      String type = "";                                                                 // String der Typen aller Objekte (getrennt mittels #)

      String koord = "";                                                                // String der Koordinaten aller Objekte (getrennt mittels #)

      String objectID = "";                                                        // IDs der erhaltenen Objekte

      String since = "";

      String until = "";

      String validName = "";

      String keyValue = "";

      int responseCode = -1;

      StringBuilder aresponse = null;

      String longitude = "";
      String latitude = "";                                      // latitude einlesen
      String filterList = "";

      try {

        longitude = request.getParameter("long");                                       // longitude einlesen
        latitude = request.getParameter("lat");                                         // latitude einlesen
        filterList = request.getParameter("filterList");

        String token = "74dc2f347d73ef4fbec38de0429b1357fcb5687f1879495c6e2bf289f6d3411eb391bf4bd2608176749040478bdac6fb5566543cedc9b963114a3b4cc98a032f";

        Cookie[] cookies = request.getCookies();

        if (cookies != null && longitude != null && latitude != null && filterList != null) {
          for (Cookie cookie : cookies) {
            if (cookie.getName().equals("copyObject")) {
              if (cookie.getValue().equals("true")) {                                         // Erstellen einer Kopie eines bereits vorhandenen Geoobjektes
                String JSONString = request.getParameter("JSONString");

                URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
                //URL url = new URL("http://127.0.0.1:8080/OhdmApi/"
                        + "geographicObject/");

                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                // Verbindung herstellen
                con.setRequestMethod("PUT");
                con.setRequestProperty("Content-Type",
                        "application/json; charset=utf-8");
                con.setRequestProperty("Authorization", "Bearer " + token);

                con.setDoOutput(true);
                OutputStreamWriter conOut = new OutputStreamWriter(con.getOutputStream());
                conOut.write(JSONString);
                conOut.flush();
                conOut.close();

                con.getResponseCode();

                cookie = new Cookie("copyObject", "false");
                cookie.setMaxAge(-1);
                response.addCookie(cookie);
              }
            }
            if (cookie.getName().equals("updateObject")) {                          // anfügen einer neuen Zeitachse an ein bereits existierendes Objekt
              if (cookie.getValue().equals("true")) {
                String JSONString = request.getParameter("JSONString");
                String origId = request.getParameter("originalId");
                URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
                //URL url = new URL("http://127.0.0.1:8080/OhdmApi/"
                        + "geographicObject/" + origId);                  // Die Eingangsgeometrie (data)

                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                // Verbindung herstellen
                con.setRequestMethod("POST");
                con.setRequestProperty("Content-Type",
                        "application/json; charset=utf-8");
                con.setRequestProperty("Authorization", "Bearer " + token);

                con.setDoOutput(true);
                OutputStreamWriter conOut = new OutputStreamWriter(con.getOutputStream());
                conOut.write(JSONString);
                conOut.flush();
                conOut.close();

                con.getResponseCode();

                cookie = new Cookie("updateObject", "false");
                cookie.setMaxAge(-1);
                response.addCookie(cookie);
              }
            }
          }
        }

        if (longitude != null && latitude != null && filterList != null) {
          URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
          //URL url = new URL("http://127.0.0.1:8080/OhdmApi/"                              // Auslesen aller Objekte an der gewählten Position
                  + "geographicObject/nearObjects" // Suche nach nahen Objekten
                  + "/" + filterList // Tag Einschraenkungen
                  + "/10/" // mit einem Abstand von bis zu 10 Metern zur eingangs Geometrie
                  + longitude + "/"
                  + latitude);
          //out.println(url.toString());

          HttpURLConnection con = (HttpURLConnection) url.openConnection();                 // Verbindung herstellen
          con.setRequestMethod("GET");
          con.setRequestProperty("Content-Type",
                  "application/json; charset=utf-8");
          con.setRequestProperty("Authorization", "Bearer " + token);

          responseCode = con.getResponseCode();                                         // Antwortcode erhalten (Code - 200 -> erfolgreich)

          name = "##0##";

          type = "##0##";                                                                 // String der Typen aller Objekte (getrennt mittels #)

          koord = "";                                                                // String der Koordinaten aller Objekte (getrennt mittels #)

          objectID = "##0##";                                                        // IDs der erhaltenen Objekte

          since = "##0##";

          until = "##0##";

          validName = "##0##";

          keyValue = "##0##";

          aresponse = new StringBuilder();

          if (responseCode == 200) {                                                        // Nur bei Erfolg auszufuehren

            BufferedReader in = new BufferedReader(
                    new InputStreamReader(con.getInputStream()));
            String inputLine;
            // StringBuilder fuer die zu empfangenden Daten

            while ((inputLine = in.readLine()) != null) {
              aresponse.append(inputLine);                                                  // Empfangene Daten Zeilenweise zusammensetzen
            }
            in.close();

            //out.println(aresponse.toString());
            JSONArray jsonArray = new JSONArray(aresponse.toString());                      //komplettes JSONArray -> alle erhaltenen Daten
            String gObject;                                                                 // String eines einzelnen geometrischen Obejekts
            JSONObject jsonEnd;                                                             // JSON Objekt des geometrischen Objekts
            //out.println(aresponse.toString());
            String tmpKo = "";                                                              // String der Koordinate der aktuellen objekts
            String tmpTy = "";                                                              // String des Types des aktuellen Objekts

            JSONArray tagDateArray;                                                         // Generiertes Array der tagDates des aktuellen Objekts

            JSONArray validArray;

            JSONArray tagArray = null;                                                      // Array der Tags des aktuellen Objekts

            List<List<String>> tagNameArray = new ArrayList<List<String>>();                // Liste der Listen aller Tags der Geometrien

            for (int i = 0; i < jsonArray.length(); i++) {                                  // durchgehen aller Geometrien

              //////////////////////Filtere Geometrie-ID//////////////////////
              objectID += jsonArray.getJSONObject(i).get("geographicObjectId").toString() + "##" + (i + 1) + "##";

              //////////////////////Filtere Geometrie-Koordinaten + Namensfindung//////////////////////
              gObject = jsonArray.getJSONObject(i).get("geometricObjects").toString();      // Immer ein einzelnes Geoobjekt herausfiltern
              jsonEnd = new JSONObject(gObject.substring(1, gObject.length() - 1));         // Erstellung JSON-Objekt aus String des Geoobjekts.
                  //Ermitteln der Geometrieart
              if (!jsonEnd.get("multipoint").toString().equals("null")) {
                tmpKo = jsonEnd.get("multipoint").toString();
                tmpTy = "MULTIPOINT";
              }

              if (!jsonEnd.get("multilinestring").toString().equals("null")) {
                tmpKo = jsonEnd.get("multilinestring").toString();
                tmpTy = "MULTILINESTRING";
              }

              if (!jsonEnd.get("multipolygon").toString().equals("null")) {
                tmpKo = jsonEnd.get("multipolygon").toString();
                tmpTy = "MULTIPOLYGON";
              }

              type += tmpTy + "##" + (i + 1) + "##";

              koord = koord + tmpKo.substring(tmpKo.indexOf(";") + 1);

              if (i < (jsonArray.length() - 1)) {
                koord = koord + "#";
              }

              //////////////////////Filtere Valid-Daten aus Geometrie//////////////////////
              tagDateArray = new JSONArray(jsonArray.getJSONObject(i).get("tagDates").toString());          // String der tagDates
              String tmpName = "";
              String validN = "";

              for (int j = 0; j < tagDateArray.length(); j++) {
                validArray = new JSONArray("[" + tagDateArray.getJSONObject(j).get("valid").toString() + "]");              // String der tagDates
                tagArray = new JSONArray("[" + tagDateArray.getJSONObject(j).get("tags").toString() + "]");                 // Array der Tags
                tmpName = tmpTy;
                validN = "false";

                for (int k = 0; k < tagArray.getJSONObject(0).length(); k++) {                // Ausfiltern der Tag keys und Values des aktuellen Objekts              
                  String key = tagArray.getJSONObject(0).names().getString(k);
                  String value = tagArray.getJSONObject(0).get(key).toString();
                  keyValue += "\"" + key + "\":\"" + value + "\"";
                  if (k < tagArray.getJSONObject(0).length() - 1) {
                    keyValue += ",";
                  }
                  if (tagArray.getJSONObject(0).names().getString(k).toLowerCase().equals("name")) {
                    tmpName = tagArray.getJSONObject(0).get("name").toString();
                    validN = "true";
                  }
                }

                name = name + tmpName;
                validName += validN;

                since += validArray.getJSONObject(0).get("since");
                until += validArray.getJSONObject(0).get("until");
                if (j < tagDateArray.length() - 1) {
                  name += "#";
                  since += "#";
                  until += "#";
                  validName += "#";
                  keyValue += "#";
                }
              }
              name += "##" + (i + 1) + "##";
              validName += "##" + (i + 1) + "##";
              since += "##" + (i + 1) + "##";
              until += "##" + (i + 1) + "##";
              keyValue += "##" + (i + 1) + "##";
            }
            name = new String(name.getBytes(), "UTF-8");
          }
        } else {
          out.println("Keine Parameter Gefunden");
        }
      } catch (Exception e) {
        out.println(e.toString());
      }
    %>

    <script type="text/javascript">
      var drawControls;
      var map;
      var layers;
      var listOrder;
      var choice = 0;
      var sinceTimeLine = "##0##";
      var untilTimeLine = "##0##";

      if (<%= responseCode%> === 200) {
        var nameList = "<%= name%>"; // Liste der Typen der Geometrien
        var koordList = "<%= koord%>"; // Liste der Koordinaten der Geometrien
        koordList = koordList.split("#");
        var LayerList = new Array(koordList.length); // Liste der Anzulegenden Layer
      }

      function init() {
        if ("<%= name%>" === "") {
          alert("Keine nahen Objekte gefunden, zurück zur Auswahl...");
          window.location = "index.jsp";
        } else {
          // Map erstellen
          var options = {
            resolutions: [
              0.703125, 0.3515625, 0.17578125, 0.087890625,
              0.0439453125, 0.02197265625, 0.010986328125,
              0.0054931640625, 0.00274658203125, 0.001373291015625,
              6.866455078125E-4, 3.4332275390625E-4, 1.71661376953125E-4,
              8.58306884765625E-5, 4.291534423828125E-5, 2.1457672119140625E-5,
              1.0728836059570312E-5, 5.364418029785156E-6, 2.682209014892578E-6,
              1.341104507446289E-6, 6.705522537231445E-7, 3.3527612686157227E-7
            ],
            projection: new OpenLayers.Projection('EPSG:4326'),
            maxExtent: new OpenLayers.Bounds(-180.0, -90.0, 180.0, 90.0),
            units: "degrees",
            controls: []
          };
          map = new OpenLayers.Map('map', options);
          var demolayer = new OpenLayers.Layer.WMS(
                  "ohsm:ohdm_berlin_dev2", "http://ohsm.f4.htw-berlin.de:8080/geoserver/gwc/service/wms",
                  {layers: 'ohsm:ohdm_berlin_dev2', format: 'image/png'},
          {tileSize: new OpenLayers.Size(256, 256)}
          );
          map.addLayer(demolayer);
          map.addControl(new OpenLayers.Control.Navigation());
          map.addControl(new OpenLayers.Control.MousePosition());
          if (<%= responseCode%> === 200) {

            for (var i = 0; i < koordList.length; i++)
              LayerList[i] = addNewLayers(map, i, i + 1); // Layerliste füllen

          } else {
            alert("Es gab Probleme bei der Datenübertragung... Versuchen Sie es noch einmal." + <%= responseCode%>);
            window.location = "index.jsp";
          }

          switchLayer(0);
          createHeadRow("table", "#ID#Name/n#Gültig von#Gültig bis", "####");
          fillTable();
          addTimeButtons();
          document.getElementById("0+0+0").checked = true;
        }
      }

      /**
       * Fügt neuen Laayer an die Map an und gibt dessen Daten zurück
       * @param map Der "Container" für alle Layer
       * @param type Typ oder, wenn vorhanden, Name des Geoobjektes
       * @param number Das n-te Element der Layerliste
       * @returns Layerelement
       */
      function addNewLayers(map, type, number) {
        var defStyle = {strokeColor: "black", strokeOpacity: "0.7", strokeWidth: 3, fillColor: "blue", pointRadius: 3, cursor: "pointer"};
        var sty = OpenLayers.Util.applyDefaults(defStyle, OpenLayers.Feature.Vector.style["default"]);
        var sm = new OpenLayers.StyleMap({
          'default': sty,
          'select': {strokeColor: "red", fillColor: "red"}
        });
        var tmp = number + " " + type;
        var Layer = new OpenLayers.Layer.Vector(tmp, {styleMap: sm});
        map.addLayer(Layer);
        var wkt = new OpenLayers.Format.WKT();
        var LayerFeature = wkt.read(koordList[number - 1]);
        LayerFeature.geometry.transform(map.displayProjection, map.getProjectionObject());
        Layer.addFeatures([LayerFeature]);
        return Layer;
      }

      /**
       * Füllt die Tabelle mit den Daten der gefunden Geodaten  
       */
      function fillTable() {
        nameList = splitTagList(nameList, koordList.length);
        var idList = splitTagList('<%= objectID%>', koordList.length);
        var sinceList = splitTagList('<%= since%>', koordList.length);
        var untilList = splitTagList('<%= until%>', koordList.length);
        var validNameList = splitTagList('<%= validName%>', koordList.length);

        for (var i = 0; i < idList.length; i++) {
          if (i != 0) {
            createSeperator();
          }
          var varobjectValidNameList = validNameList[i].split('#');
          var objectNameList = nameList[i].split('#');
          var objectSinceList = sinceList[i].split('#');
          var objectUntilList = untilList[i].split('#');
          var linkedTimesSince = [];
          var linkedTimesUntil = [];
          orderTimes(objectSinceList);

          linkTimes(objectSinceList, objectUntilList, linkedTimesSince, linkedTimesUntil, varobjectValidNameList, objectNameList, idList[i], i);
        }
      }

      /**
       * Erstellt Trenner zwischen verschiedenen Geoobjekten in der Tabelle
       * (Schwarzer Strich)
       */
      function createSeperator() {
        var container = document.getElementById("table");
        var div = document.createElement("div");
        div.setAttribute("style", "background-color: black; width: 100%; height: 3px;");
        container.appendChild(div);
      }

      /**
       * Fast Daten die überlappen zusammen zu einzel Daten zusammen
       * @param since Liste der vorhandenen Sincedaten 
       * @param until Liste der vorhandenen Untildaten 
       * @param newSince Die neuen Sincedaten wenn die Zeiten nicht 
       * mehr überlappen
       * @param newUntil Die neuen Untildaten wenn die Zeiten nicht 
       * mehr überlappen
       * @param valids Liste ob Geoobjekte einen eigenen Namen besitzen
       * Gibt true an wenn für das Geoobjekt wenigstens ein 
       * Name vorhanden ist
       * @param names List von Namen der gefundenen Geoobjekte
       * @param id Liste von IDs der gefundenen Objekte
       * @param objectNumber n-tes Objekt der Liste
       */
      function linkTimes(since, until, newSince, newUntil, valids, names, id, objectNumber) {
        var tmpSince = since[listOrder[0]];
        var tmpUntil = until[listOrder[0]];
        for (var i = 0; i < since.length; i++) {
          var compareTo;
          var compareWith;
          var changeWith;

          compareTo = createDate(since[listOrder[i]]);
          compareWith = createDate(tmpUntil);

          if (compareTo <= compareWith) {

            changeWith = createDate(until[listOrder[i]]);

            if (changeWith > compareWith) {
              tmpUntil = until[listOrder[i]];
            }
          } else {
            sinceTimeLine = sinceTimeLine + tmpSince + "#";
            untilTimeLine = untilTimeLine + tmpUntil + "#";
            newSince.push(tmpSince);
            newUntil.push(tmpUntil);

            tmpSince = since[listOrder[i]];
            tmpUntil = until[listOrder[i]];
          }
        }
        sinceTimeLine = sinceTimeLine + tmpSince + "##" + parseInt(objectNumber + 1) + "##";
        untilTimeLine = untilTimeLine + tmpUntil + "##" + parseInt(objectNumber + 1) + "##";

        newSince.push(tmpSince);
        newUntil.push(tmpUntil);
        getRows(valids, names, newSince, newUntil, id, objectNumber);
      }

      /**
       * Fügt alle nötigen Zeilen für des aktuelle Geoobjekt an
       * @param valids Liste ob Geoobjekte einen eigenen Namen besitzen
       * Gibt true an wenn für das Geoobjekt wenigstens ein 
       * Name vorhanden ist
       * @param names List von Namen der gefundenen Geoobjekte
       * @param since Liste der genutzten Startdaten
       * @param until Liste der genutzten Enddaten
       * @param id ID des genutzten Geoobjekts
       * @param ObjectNumber n-tes Objekt der Liste
       */
      function getRows(valids, names, since, until, id, objectNumber) {
        var nameList = [];
        var nameString = "";
        var rowIntern = 0;
        for (var i = 0; i < names.length; i++) {
          if (valids[i] == "true") {
            if (nameList.indexOf(names[i]) == -1) {
              nameList.push(names[i]);
              nameString += ", " + names[i];
            }
          }
        }
        if (nameString != "") {
          nameString = nameString.substring(2);
        } else {
          nameString = "noName";
        }
        for (var i = 0; i < since.length; i++) {
          createRow(id, nameString, since[i], until[i], objectNumber, "table", rowIntern);
          rowIntern++;
        }
      }


      /**
       * Erstellt Liste aller Taglisten eines Geoobjektes
       * @param List Liste einer Liste von Daten der Form ##n##Inhalt##n+1##
       * @param Anzahl der Elemente in der Liste
       * @return Die erstellte Liste
       */
      function splitTagList(List, length) {
        var splitedList = [];
        for (var i = 0; i < length; i++) {
          splitedList.push(splitTag(List, i));
        }
        return splitedList;
      }

      /**
       * Wechselt den dargestellten Layer auf einen anderen
       * @param number Die ID des gewählten Layers
       */
      function switchLayer(number) {

        for (var i = 0; i < LayerList.length; i++) {
          LayerList[i].setVisibility(false);
        }
        LayerList[number].setVisibility(true);
        map.zoomToExtent(LayerList[number].getDataExtent());

        choice = number;
      }

      /**
       * Erstellt Menü für das Kopieren eines ausgewählten Geoobjektes bzw. das
       * Anfügen eine Zeitzone an ein Geoobjekt
       */
      function addTimeButtons() {
        var containerAll = document.getElementById("infoText");

        var addTimeDiv = document.createElement("div");
        addTimeDiv.setAttribute("id", "addTimeDiv");
        containerAll.appendChild(addTimeDiv);

        createButton("Aktives Objekt...", containerAll, "addNewTimeFields()", "addTimeBtn");
      }

      /**
       * Füllt Menü für das Kopieren eines ausgewählten Geoobjektes bzw. das
       * Anfügen eine Zeitzone an ein Geoobjekt
       */
      function addNewTimeFields() {
        var container = document.getElementById("addTimeDiv");

        addRadioNewTime(container, "operation", "Kopieren", "toggleNewTimeBtn(1)");
        addRadioNewTime(container, "operation", "Zeit anfügen", "toggleNewTimeBtn(0)");

        container.setAttribute("style", "border: solid 2px; height: 450px; width: 350px; background-color: #f3f3f3; margin-top: 25px; margin-bottom: 25px;");

        document.getElementById("addTimeBtn").disabled = true;

        addInputNewTime("Name des neuen Objektes", "nameInput", container, "Name:", "");
        addInputNewTime("YYYY-MM-DD", "sinceInput", container, "Gültig von:", "checkNchange('sinceInput')");
        addInputNewTime("YYYY-MM-DD", "untilInput", container, "Gültig bis:", "checkNchange('untilInput')");

        addDiv(container, "Sollen Tags aus einem bestimmten Zeitraum kopiert werden? "
                + "So geben Sie im folgendem Feld das Datum mit den gewünschten Tags an, "
                + "sollten Sie nichts kopieren wollen so lassen Sie das Feld leer.");

        addInputCopyTagsFrom("YYYY-MM-DD", "copyInput", container);


        createButton("Zeit anfügen", container, "showAlert('Bitte Vorgehensweise auswählen!')", "addNewTimeBtn");

        document.getElementById("addNewTimeBtn").setAttribute("style", "width: 250px; display: block; margin: 0px auto; margin-top: 25px;");

      }

      /**
       * Erstellt ein Div zum anzeigen von Text mit spezieller Größe
       * @param {type} container Oberelement
       * @param {type} text Anzuzeigender Text
       */
      function addDiv(container, text) {
        var div = document.createElement("div");
        div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");
        div.textContent = text;
        container.appendChild(div);
      }

      /**
       * Erstellt ein Div zum anzeigen von Text mit spezieller Größe
       * @param {type} placeholder  Placeholder des Inputs
       * @param {type} id ID des Inputs
       * @param {type} container Oberelement des inputs
       */
      function addInputCopyTagsFrom(placeholder, id, container) {

        var div = document.createElement("div");
        div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");
        div.setAttribute("align", "center");

        var input = document.createElement("input");
        input.setAttribute("placeholder", placeholder);
        input.setAttribute("id", id);
        input.setAttribute("onchange", "checkNchange('" + id + "')");
        div.appendChild(input);

        container.appendChild(div);
      }

      /**
       * Erlaubt variables Alert aufzurufen
       * @param value Text der im Alert stehen soll
       */
      function showAlert(value) {
        alert(value);
      }

      /**
       * Überprüft Eingaben und, wenn alle Angaben stimmen, lässt eine neue
       * Zeitzone an ein Objekt anfügen bzw. eine Kopie des Geoobjektes
       * erstellen
       * @param mode  Der Modus der genutzt werden soll, 0 für das Anfügen einer
       * Zeitzone, 1 für die Erstellung einer Kopie für das Geoobjekt
       */
      function addTimeOrObject(mode) {
        var objectSinceList = splitTagList(sinceTimeLine, koordList.length)[choice].split('#');
        var objectUntilList = splitTagList(untilTimeLine, koordList.length)[choice].split('#');
        var nameInput = document.getElementById("nameInput").value;
        var sinceInput = document.getElementById("sinceInput").value;
        var untilInput = document.getElementById("untilInput").value;
        var copyInput = document.getElementById("copyInput").value;
        var goOn = true;
        var copyTrue = false;
        if (nameInput == "" || sinceInput == "" || untilInput == "") {
          alert("Alle notwendigen Felder müssen ausgefüllt werden!");
        } else {
          if (compareTimesPrep(sinceInput, untilInput) != 0) {
            alert("Fehlerhafte Eingabe der Daten!");
          } else {
            if (copyInput != "") {
              if (checkIfCorrectDate(getSingleDates(copyInput)) != 0) {
                alert("Fehlerhafte Eingabe beim Kopier-Zeitraum");
                goOn = false;
              } else {
                document.getElementById("copyInput").value = createCorrectDate(copyInput);
                copyInput = createCorrectDate(copyInput);
              }
            }
            if (goOn == true) {
              document.getElementById("sinceInput").value = createCorrectDate(sinceInput);
              document.getElementById("untilInput").value = createCorrectDate(untilInput);
              sinceInput = createCorrectDate(sinceInput);
              untilInput = createCorrectDate(untilInput);
              for (var i = 0; i < objectSinceList.length; i++) {
                if (checkIfBetween(sinceInput, objectSinceList[i], objectUntilList[i]) == 1 || checkIfBetween(untilInput, objectSinceList[i], objectUntilList[i]) == 1) {
                  alert("Die Daten müssen sich in einem noch nicht genutztem Zeitraum befinden!");
                  goOn = false;
                  break;
                } else {
                  if (checkIfBetween(objectSinceList[i], sinceInput, untilInput) == 1) {
                    alert("Die Daten umschliesen bereits genutzte Zeiten");
                    goOn = false;
                    break;
                  } else {
                    if (copyInput != "") {
                      if (checkIfBetween(copyInput, objectSinceList[i], objectUntilList[i]) == 1) {
                        copyTrue = true;
                      }
                    } else {
                      copyTrue = true;
                    }
                  }
                }
              }
              if (copyTrue == false && goOn == true) {
                alert("Das Datum der Kopie muss sich in einem bereits genutzten Zeitraum befinden");
                goOn = false;
              }
              if (goOn == true) {
                var tags = "";
                tags = getTags(copyInput);
                if (mode == 0) {
                  addToUsedObject(tags);
                } else {
                  createNewObject(tags);
                }
              }
            }
          }
        }
      }

      /**
       * Erstellt einen JSON der genutzt wird um an das gewählte Geoobjekt eine 
       * neue Zeitzone mit Tags einer bestimmten Zeit anzufügen 
       * @param tags Liste der Tags die zu einem Bestimmten Zeitraum
       * golten
       */
      function addToUsedObject(tags) {

        var id = splitTag('<%= objectID%>', choice);
        var JSON = getUsedObject(id);
        var since = document.getElementById("sinceInput").value;
        var until = document.getElementById("untilInput").value;

        var JSONA = JSON.split("\"tagDates\":[{")[0];
        var JSONC = JSON.split("\"tagDates\":[{")[1];

        var JSONB = "\"tagDates\":[{";

        JSONB += "\"tags\":{" + tags + "},\"valid\":{\"since\":\"" + since + "\",\"until\":\"" + until + "\"}},{";

        JSON = JSONA + JSONB + JSONC;

        document.cookie = "updateObject=true";

        send(JSON, id);
      }

      /**
       * Erstellt einen JSON zu einem Geoobjekt mit einer bestimmten ID
       * @param  id ID des Geoobjektes
       * @returns JSON mit den Tags des gesuchten Geoobjektes
       */
      function getUsedObject(id) {
        var JSON = '<%= aresponse.toString()%>';

        JSON = JSON.substr(JSON.indexOf(id), JSON.length);
        if (JSON.indexOf(",{\"geographicObjectId\":") != -1) {
          JSON = JSON.substr(0, JSON.indexOf(",{\"geographicObjectId\":"));
        }
        JSON = "{\"geographicObjectId\":" + JSON;

        if (JSON[JSON.lenth - 1] == "]") {
          JSON = JSON.substr(0, JSON.lenth - 1);
        }
        return JSON;
      }

      /**
       * Erstellt einen JSON der genutzt wird um eine Kopie des gewählte 
       * Geoobjekt zu erstellen
       * @param tags Liste der Tags die zu einem Bestimmten Zeitraum
       */
      function createNewObject(tags) {
        var geom = '<%= koord%>'.split("#")[choice];
        var type = geom.substr(0, geom.indexOf("(")).toLowerCase();
        var since = document.getElementById("sinceInput").value;
        var until = document.getElementById("untilInput").value;

        var JSON = '{"originalId":12345,"attributes":{},'
                + '"externalSourceId":2,"geoBlobDates":null,';

        JSON += '"tagDates":[{"tags":{' + tags + '},"valid":{"since":"'
                + since + '","until":"' + until + '"}}],';

        JSON += '"geometricObjects":[{"valid":{"since":"' + since + '","until":"'
                + until + '"},"' + type.toLowerCase() + '":"' + geom + '"}]}';

        document.cookie = "copyObject=true";

        send(JSON, 0);

      }

      /**
       * Sendet JSON um Kopie des Geoobjektes zu erstellen uder 
       * neue Zeitzone an das Geoobjekt anzufügen
       * @param {type} JSON Der JSON für das senden
       * @param {type} id Die ID des Geoobjektes
       */
      function send(JSON, id) {
        document.getElementById("long").value = '<%= longitude%>';
        document.getElementById("lat").value = '<%= latitude%>';
        document.getElementById("filterList").value = '<%= filterList%>';
        document.getElementById("originalId").value = id;
        document.getElementById("JSONString").value = JSON;
        document.getElementById("create_submit").click();
      }

      /**
       * Gibt alle Tags zurück die zu einem gewähltem Datum gültig waren
       * @param date Das gewählte Datum
       * @returns Liste der aktiven Tags
       */
      function getTags(date) {

        var tagList = "";
        var name = document.getElementById("nameInput").value;

        if (date != "") {
          var tags = splitTag('<%= keyValue%>', choice).split("#");
          var since = splitTag('<%= since%>', choice).split("#");
          var until = splitTag('<%= until%>', choice).split("#");

          for (var i = 0; i < since.length; i++) {
            if (checkIfBetween(date, since[i], until[i]) == 1) {
              tagList += "," + tags[i];
            }
          }
          tagList = tagList.substr(1);
          tagList = tagList.split("\"name\":");
          for (var i = 1; i < tagList.length; i++) {
            if (tagList[i].indexOf(",") == -1) {
              tagList[i] = "";
            } else {
              tagList[i] = tagList[i].substring(tagList[i].indexOf(",") + 1);
            }
          }
          tagList = tagList.join("");
          if (tagList[tagList.length - 1] != ",") {
            tagList = tagList + ",";
          }
        }
        tagList += "\"name\":\"" + name + "\"";
        return tagList;
      }

      /**
       * Wechselt Buttontext und Onclick funktion
       * @param value Gibt den Modus auf den gewechselt werden soll an,
       * 0 für Zeit anfügen, 1 für Kopie erstellen
       */
      function toggleNewTimeBtn(value) {
        var btn = document.getElementById("addNewTimeBtn");
        if (value == 0) {
          btn.textContent = "Zeit anfügen";
          btn.setAttribute("onclick", "addTimeOrObject(0)");
        } else {
          btn.textContent = "Kopie erstellen";
          btn.setAttribute("onclick", "addTimeOrObject(1)");
        }
      }

      /**
       * Erstellt Radiobox in einem Div mit bestimmter Größe
       * @param {type} container Oberelement des Divs
       * @param {type} name Name der Radiobox
       * @param {type} text Text des Labels und id der Radiobox
       * @param {type} func Onchange Funktion der Radiobox
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

      /**
       * Erstellt Input in Div bestimmter Größe
       * @param {type} placeholder Platzhalter für Input
       * @param {type} id ID für Input
       * @param {type} container Oberelement des inputs
       * @param {type} labelText Text für das Label
       * @param {type} onChFun onchange Funktion für das Input
       */
      function addInputNewTime(placeholder, id, container, labelText, onChFun) {

        var div = document.createElement("div");
        div.setAttribute("style", "width: 250px; margin: 0px auto; margin-top: 20px;");

        var label = document.createElement("label");
        label.setAttribute("for", id);
        label.textContent = labelText;
        div.appendChild(label);

        var input = document.createElement("input");
        input.setAttribute("placeholder", placeholder);
        input.setAttribute("style", "float: right;");
        input.setAttribute("id", id);
        input.setAttribute("onchange", onChFun);
        div.appendChild(input);

        container.appendChild(div);

      }

      //Zurück zur Startseite
      function backToIndex() {
        window.location = "index.jsp";
      }

      /**
       * Wenn ein Geoobjekt ausgewählt wurde wird hier bestimmt auf welche Seite 
       * weitergeleitet wird
       * @param action Bestimmt das weiter Vorgehen, 0 - Tags werden Editiert,
       * 1 - Geodaten werden Editiert
       */
      function nextStep(action) {
        var originalId = splitTag("<%= objectID%>", choice);
        var type = splitTag("<%= type%>", choice);
        document.cookie = "usedType=" + type.toLowerCase();
        if (action === 0) {
          document.getElementById("formular").setAttribute("action", "tagEdit.jsp");
        } else {
          document.getElementById("formular").setAttribute("action", "geoEdit.jsp");
        }
        document.getElementById('originalID').value = originalId;
        document.getElementById('tag_submit').click();
      }

      /**
       * Splittet Daten der Form ...##n##Inhalt##n+1##...
       * @param tagList String mit mehreren Daten getrennt durch ##n##
       * @param number Das Element n welches gewählt wurde
       * @returns Daten die zwischen ##number## und ##number+1## stehen 
       */
      function splitTag(tagList, number) {
        tagList = tagList.split("##" + number + "##");
        tagList = tagList[1].split("##" + parseInt(parseInt(number) + 1) + "##");
        return tagList[0];
      }


    </script>

    <style>

      .olControlLayerSwitcher .layersDiv {
        max-height: 350px;                
        overflow: scroll;
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
      }

    </style>


  </head>
  <body onload="init()">
    <h1>Bitte das weitere Vorgehen bestimmen</h1>
    <div
      id="map"
      style="width: 100%; height: 70%; min-height: 400px; min-width: 600px; border: 2px solid #000">
    </div>



    <h1 id="title">Bitte wählen Sie ihr zu bearbeitendes Objekt aus:</h1>

    <div id="table"></div>


    <input type="submit" onclick="nextStep(0);" value="Tags Bearbeiten">
    <input type="submit" onclick="nextStep(1);" value="Geodaten bearbeiten">

    <div id="infoText"></div>

    <form action="tagEdit.jsp" id="formular" method="post" accept-charset="UTF-8">

      <input id="originalID" name="originalID" type="text" style="display: none;"/>
      <input id="tag_submit" type="submit" style="display: none;"/>

    </form>

    <form action="chooseNextAction.jsp" id="formular" method="post" accept-charset="UTF-8">

      <input id="long" name="long" type="text" style="display: none;"/>
      <input id="lat" name="lat" type="text" style="display: none;"/>
      <input id="filterList" name="filterList" type="text" style="display: none;"/>
      <input id="JSONString" name="JSONString" type="text" style="display: none;"/>
      <input id="originalId" name="originalId" type="text" style="display: none;"/>
      <input id="create_submit" type="submit" style="display: none;"/>

    </form>

    <h1 id="title">Geometrie nicht dabei?</h1>
    <div style="width: 100%; min-width: 300px;">Ergab die Suche nicht die gewünschten Ergebnisse? Vielleicht sollten Sie beim nächsten Versuch andere Filtereinstellungen verwenden oder Sie haben ihr Ziel verfehlt...</div>
    <br> 
    <input type="submit" onclick="backToIndex();" value="Zurück zum Start">


  </body>
</html>
