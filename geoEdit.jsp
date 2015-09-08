<%-- 
    Document   : geoEdit.jsp
    Created on : 20.06.2015, 14:21:17
    Author     : Tommy Ball
--%>

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
    <style type="text/css"></style>

    <%
      response.setContentType("text/html;charset=UTF-8");
      String originalID = "";                                     // Object-ID einlesen
      String type = "";

      String since = "";

      String until = "";

      String coordinates = "";

      StringBuilder aresponse = null;

      try {

        originalID = request.getParameter("originalID");

        String token = "b13d3b247d0c0a4c5ddd6db91b5108e123bdb8fbda9d0cfbdebb806f0a9408c3210579cc53d44d6addd00a78e972747522a4dc3928cd99975a5f462ee1062395";

        Cookie[] cookies = request.getCookies();
        for (Cookie cookie : cookies) {
          if (cookie.getName().equals("usedType")) {
            type = cookie.getValue();
          }
        }

        URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/geographicObject/" + originalID);
        //URL url = new URL("http://127.0.0.1:8080/OhdmApi/geographicObject/" + originalID);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
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

        JSONArray geoObjects = new JSONArray(jsonArray.getJSONObject(0).get("geometricObjects").toString());

        int timeCounter = geoObjects.length();
        // Filtern vorhandener since-, until- und Geometriedaten
        // getrennt jeweils durch #
        for (int i = 0; i < timeCounter; i++) {
          String tmpCoord = "";
          JSONArray timeZone = new JSONArray("[" + geoObjects.getJSONObject(i).get("valid").toString() + "]");
          since += timeZone.getJSONObject(0).get("since").toString();
          until += timeZone.getJSONObject(0).get("until").toString();
          tmpCoord = geoObjects.getJSONObject(i).get(type).toString();
          coordinates += tmpCoord.split(";")[1];
          if (i < timeCounter - 1) {
            coordinates += "#";
            since += "#";
            until += "#";
          }
        }
      } catch (Exception e) {
        out.println("Keine Parameter vorhanden");
        originalID = "";
      }
    %>

    <script type="text/javascript">
      var drawControls;
      var map;
      var layers;
      var Layer;
      var listOrder = [];
      var coordinates;
      var finalSince;
      var finalUntil;
      var type;

      function init() {

        if ('<%= originalID%>' == "" || '<%= originalID%>' == null) {
          alert("Keine Parameter gefunden... Zurück zum Anfang")
          backToIndex();
        }

        fillSelect();

        document.getElementById("existingTimeZones").disabled = false;

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

        var defStyle = {strokeColor: "black", strokeOpacity: "0.7", strokeWidth: 3, fillColor: "blue", pointRadius: 3, cursor: "pointer"};
        var sty = OpenLayers.Util.applyDefaults(defStyle, OpenLayers.Feature.Vector.style["default"]);
        var sm = new OpenLayers.StyleMap({
          'default': sty,
          'select': {strokeColor: "red", fillColor: "red"}
        });

        Layer = new OpenLayers.Layer.Vector("geom", {styleMap: sm});
        map.addLayer(Layer);
        var extend = getExtend();
        map.zoomToExtent(extend);


      }
      
      /**
       * Durchsuchen der Cookies nach bereits genutztem Fokus
       * @returns Extend Daten für Fokus oder ""
       */    
      function getExtend() {
        var cookies = document.cookie.split(";");
        var extend = "";
        for (var i = 0; i < cookies.length; i++) {
          var tmp = cookies[i].split("=")[0].split(" ").join("");
          if (tmp == "extend") {
            extend = cookies[i].split("=")[1].split(",");
            extend = new OpenLayers.Bounds(extend[0], extend[1], extend[2], extend[3]);
            i = cookies.length;
          }
        }
        return extend;
      }
      
      /**
       * Füllt dropdown menu mit den vorhandenen Zeiträumen des Geoobjektes
       * Am anfang noch eine leere eingabe
       */
      function fillSelect() {
        var since = '<%= since%>';
        var until = '<%= until%>';
        since = since.split("#");
        until = until.split('#');
        var orderedList = orderTimeZones(since, until);
        var existingTimeZones = document.getElementById("existingTimeZones");
        var filler = document.createElement("option");
        filler.setAttribute("value", "");
        filler.textContent = "";
        filler.setAttribute("style", "display:none");
        existingTimeZones.appendChild(filler);

        for (var i = 0; i < orderedList.length; i++) {
          var option = document.createElement("option");
          option.setAttribute("value", listOrder[i]);
          option.textContent = orderedList[i];
          existingTimeZones.appendChild(option);
        }
        document.getElementById("existingTimeZones").value = "";
      }

      /**
       * Zeigt die Geometrie für den aktuell gewählten Zeitraum an und setzt
       * den Fokus der Karte darauf, zudem wird das Änderungsmenü dargestellt
       */
      function changeStart() {
        coordinates = '<%= coordinates%>';
        coordinates = coordinates.split("#");
        var choice = document.getElementById("existingTimeZones").value;
        document.getElementById("startBtn").style.visibility = "visible";
        document.getElementById("tipp").style.visibility = "visible";
        document.getElementById("sinceInput").value = "";
        document.getElementById("untilInput").value = "";
        document.getElementById("finalAdjustments").style.visibility = "visible";
        change(coordinates[choice]);
      }

      /**
       * Darstellung der aktuell gewählten Geometrie für den Zeitraum, eventuell 
       * bereits dargestellte Geometrien werden dabei entfernt
       */
      function change(coordinate) {
        var selected = 0;
        if (Layer.selectedFeatures.length > 0) {
          selected = 1;
        }
        Layer.removeAllFeatures();
        var wkt = new OpenLayers.Format.WKT();
        var LayerFeature = wkt.read(coordinate);
        LayerFeature.geometry.transform(map.displayProjection, map.getProjectionObject());
        Layer.addFeatures([LayerFeature]);
        if (selected === 1) {
          startChange();
        }
        map.zoomToExtent(Layer.getDataExtent());
      }

      /**
       * Sperrt das weitere Ändern der genutzten Geometrie und beginnt den 
       * Edit-Mode
       */
      function startChange() {
        document.getElementById("existingTimeZones").disabled = true;
        var mF = new OpenLayers.Control.ModifyFeature(Layer);
        mF.selectFeature(Layer.features[0]);
        var editPanel = new OpenLayers.Control.Panel();
        editPanel.addControls(mF);
        editPanel.defaultControl = mF;
        map.addControl(editPanel);
      }

      /**
       * Überprüft vorhandene Daten und wenn alles Korrekt bildung eines JSON
       * und weitersenden an nächste Seite
       */
      function weiter() {
        var wkt = new OpenLayers.Format.WKT();
        var geom = wkt.write(Layer.features[0]);
        var since = document.getElementById("sinceInput").value;
        var until = document.getElementById("untilInput").value;
        if (since == "" || until == "") {
          alert("Bitte beide Datenfelder ausfüllen!");
        } else {
          if (compareTimesPrep(since, until) !== 1) {            
            getNewTimes(geom, '<%= since%>', '<%= until%>');
            getJSON();
          } else {
            alert("Fehlerhafte Eingabe der Daten!");
          }
        }
      }

      /**
      * Erstellung des JSON und senden an nächste Seite      
      */
      function getJSON() {
        var origString = '<%= aresponse.toString()%>';
        var part1 = origString.substr(0, origString.indexOf('"geometricObjects"'));
        var part2 = "";
        part2 += '"geometricObjects":[';

        for (var i = 0; i < listOrder.length; i++) {
          part2 += '{"valid":{"since":"' + createCorrectDate(finalSince[listOrder[i]]) + '",'
                  + '"until":"' + createCorrectDate(finalUntil[listOrder[i]]) + '"},'
                  + '"<%= type%>":"' + coordinates[listOrder[i]] + '"}';
          if (i < listOrder.length - 1)
            part2 += ",";
        }
        part2 += ']}';

        document.cookie = "allowSend=true";
        document.cookie = "sendKind=geo";

        document.getElementById("type").value = '<%= type%>';
        document.getElementById("JSONString").value = part1 + part2;
        document.getElementById("originalId").value = '<%= originalID%>';
        document.getElementById("JSON_submit").click();

      }      

      /**
       * Ändert Drawfunktion für Layer, sollte unnötig sein
       * @param {type} element
       */
      function toggleControl(element) {
        for (key in drawControls) {
          var control = drawControls[key];
          if (element.value === key && element.checked) {
            control.activate();
          } else {
            control.deactivate();
          }
        }
      }

      /**
       * Ändert sichtbarkeit der Layer, sollte unnötig sein
       * @param {type} element
       */
      function toggleVisibility(element) {
        for (key in layers) {
          var layer = layers[key];
          if (element.value === key) {
            layer.setVisibility(element.checked);
          }
        }
      }
      
      /**
       * Zurück zur Startseite
       */
      function backToIndex() {
        window.location = "index.jsp";
      }

    </script>

    <style>

      .olControlLayerSwitcher .layersDiv {
        max-height: 350px;                
        overflow: scroll;
      }    

      .inputContainer, #finalAdjustments{
        margin-top: 15px;
      }
    </style>


  </head>
  <body onload="init()">
    <div
      id="map"
      style="width: 100%; height: 70%; min-height: 400px; min-width: 600px; border: 2px solid #000">
    </div>

    <h1 id="title">Bitte Zeitraum der Ausgangsgeometrie wählen</h1>

    <select id="existingTimeZones" onchange="changeStart()" ></select>

    <input type="submit" id="startBtn" onclick="startChange()" value="Änderungen beginnen" style="visibility:hidden;">
    <br>
    <a id="tipp" style="visibility:hidden;">TIPP: Überschüssige Knoten können markiert und dann per Druck auf "Entf" beseitigt werden.</a>

    <div id="finalAdjustments" style="visibility:hidden;">

      <a>Von wann bis wann sollen die getätigten Änderungen gültig sein?:</a>
      <br>
      <div class="inputContainer">
        <label for="sinceInput">von:</label>
        <input id="sinceInput" onchange="checkNchange('sinceInput');" name="sinceInput" value ="" placeholder="YYYY-MM-DD"/>
      </div>      
      <br>
      <div class="inputContainer">
        <label for="sinceInput">bis:</label>
        <input id="untilInput" onchange="checkNchange('untilInput');" name="untilInput" value ="" placeholder="YYYY-MM-DD"/>
      </div>      
      <br>
      <input type="submit" id="sendBtn" onclick="weiter()" value="Änderungen beenden und speichern">
    </div>

    <button id="abort" onclick="backToIndex()" class="Btn">Änderungen verwerfen und zurück zum Anfang</button>

    <form action="transmit.jsp" id="formular" method="post" accept-charset="UTF-8">

      <input id="originalId" name="originalId" type="text" style="display: none;"/>
      <input id="JSONString" name="JSONString" type="text" style="display: none;"/>      
      <input id="type" name="type" type="text" style="display: none;"/>  
      <input id="JSON_submit" type="submit" style="display: none;"/>
    </form>

    <!--<div id="map" class="smallmap"></div>    -->

  </body>
</html>
