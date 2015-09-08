<%-- 
    Document   : geometrieErstellen
    Created on : 16.06.2015, 17:02:19
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
      String geom = "";
      try {
        response.setContentType("text/html;charset=UTF-8");
        geom = request.getParameter("geom");                                       // Geometrie einlesen
      } catch (Exception e) {
        out.println("Keine Parameter gefunden");
      }
    %>

    <script type="text/javascript">
      var drawControls;
      var map;
      var layers;
      var Layer;

      function init() {
        if ('<%= geom %>' === "" || '<%= geom %>' === "null") {
          alert("Keine Parameter gefunden... Zurück zum Anfang")
          backToIndex();
        }
        
        // erstellen der Map
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
        
        // Style der Layer
        var defStyle = {strokeColor: "black", strokeOpacity: "0.7", strokeWidth: 3, fillColor: "blue", pointRadius: 3, cursor: "pointer"};
        var sty = OpenLayers.Util.applyDefaults(defStyle, OpenLayers.Feature.Vector.style["default"]);
        var sm = new OpenLayers.StyleMap({
          'default': sty,
          'select': {strokeColor: "red", fillColor: "red"}
        });

        Layer = new OpenLayers.Layer.Vector("geom", {styleMap: sm});
        map.addLayer(Layer);

        var wkt = new OpenLayers.Format.WKT();

        // einlesen der Geometrie
        var LayerFeature = wkt.read('<%= geom%>');
        LayerFeature.geometry.transform(map.displayProjection, map.getProjectionObject());
        // darstellen der Geometrie
        Layer.addFeatures([LayerFeature]);
        // Fokus auf die Geometrie
        map.zoomToExtent(Layer.getDataExtent());
        // bearbeiten der Geometrie
        var mF = new OpenLayers.Control.ModifyFeature(Layer);
        mF.selectFeature(Layer.features[0]);

        var editPanel = new OpenLayers.Control.Panel();
        editPanel.addControls(mF);
        editPanel.defaultControl = mF;
        map.addControl(editPanel);

        map.addControl(new OpenLayers.Control.MousePosition());
      }

      /**
       * Fertigstellen der Geometrie, erstellung eines JSONs und weiterleiten
       * zur nächsten Seite
       */
      function weiter() {
        var nameInput = document.getElementById("name").value;
        var sinceInput = document.getElementById("since").value;
        var untilInput = document.getElementById("until").value;

        if (nameInput == "") {
          alert("Das Objekt benötigt einen Namen!");
        } else {
          if (sinceInput == "" && untilInput == "") {
            alert("Es muss wenigstens ein Gültigkeitszeitraum ausgefüllt werden!");
          } else {
            if (sinceInput == "") {
              sinceInput = untilInput;
            }
            if (untilInput == "") {
              untilInput = sinceInput;
            }

            if (checkIfCorrectDate(getSingleDates(sinceInput)) === 1 || checkIfCorrectDate(getSingleDates(untilInput)) === 1) {
              alert("Fehler bei den eingegebenen Daten");
            } else {
              if (compareTimes(sinceInput, untilInput) == 1) {
                alert("Das Datum von 'Bis:' muss zeitlich gleich oder nach 'Von:' liegen!");
              }
              else {
                var wkt = new OpenLayers.Format.WKT();
                var geom = wkt.write(Layer.features[0]);
                geom = "MULTI" + geom;
                geom = geom.replace("(", "((");
                geom = geom.replace(")", "))");
                var type = geom.substr(0, geom.indexOf("("));

                createJSON(geom, type, nameInput, createCorrectDate(sinceInput), createCorrectDate(untilInput));
              }
            }
          }
        }
      }
      
      /**
       * Erstellung eines validen JSONs und senden an die nächste Seite
       * @param {type} geom Die gezeichneten Geometriedaten
       * @param {type} type Art der Geometrie
       * @param {type} name Name des erzeugten Geoobjektes
       * @param {type} since Start der Gültigkeit des Geoobjektes
       * @param {type} until Ende der Gültigkeit des Geoobjektes
       */
      function createJSON(geom, type, name, since, until) {
        var JSON = '{"originalId":12345,"attributes":{},'
                + '"externalSourceId":2,"geoBlobDates":null,';

        JSON += '"tagDates":[{"tags":{"name":"' + name + '"},"valid":{"since":"'
                + since + '","until":"' + until + '"}}],';

        JSON += '"geometricObjects":[{"valid":{"since":"' + since + '","until":"'
                + until + '"},"' + type.toLowerCase() + '":"' + geom + '"}]}';

        document.cookie = "allowCreate=true";
        document.cookie = "usedType=" + type.toLowerCase();
        send(JSON);
      }
      
      /**
       * Senden des erstellten JSONs
       * @param {type} JSON Der erstellte JSON
       */
      function send(JSON) {
        document.getElementById("JSONString").value = JSON;
        document.getElementById("create_submit").click();
      }
      
      /**
       * Rückkehr zur Startseite
       */
      function backToIndex() {
        window.location = "index.jsp";
      }

    </script>

    <style>
      #information {
        width: 300px;
      }
      .clickBtn {
        margin-top: 20px;
        width: 300px;
      }
      .info {
        margin-bottom: 15px;

      }
      .input {
        float: right;
      }
    </style>


  </head>
  <body onload="init()">
    <div
      id="map"
      style="width: 100%; height: 70%; min-height: 400px; min-width: 600px; border: 2px solid #000">
    </div>

    <h1 id="title">Nötige Daten eingeben</h1>

    <div id="information">
      <div class="info">
        <a>Name:</a>
        <input class="input" id="name" name="name" type="text"/>
      </div>
      <div class="info">
        <a>Gültig von:</a>
        <input class="input" id="since" onchange="checkNchange('since');" name="since" type="text" placeholder="YYYY-MM-DD"/>
      </div>
      <div class="info">
        <a>Bis:</a>
        <input class="input" id="until" onchange="checkNchange('until');" name="until" type="text" placeholder="YYYY-MM-DD"/>
      </div>
      <input class="clickBtn" type="submit" onclick="weiter();" value="Weiter">
      <input class="clickBtn" type="submit" onclick="backToIndex();" value="Zurück">      
    </div>

    <form action="createComplete.jsp" id="formular" method="post" accept-charset="UTF-8">

      <input id="JSONString" name="JSONString" type="text" style="display: none;"/>
      <input id="create_submit" type="submit" style="display: none;"/>

    </form>

  </body>
</html>
