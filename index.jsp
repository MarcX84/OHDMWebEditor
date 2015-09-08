<%-- 
    Document   : index
    Created on : 09.03.2015, 18:34:27
    Author     : Tommy Ball
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>OHDM - Editor</title>
    <script src="http://openlayers.org/api/OpenLayers.js"></script>
    <script type="text/javascript" src="tagList.js"></script>
    <script type="text/javascript" src="tagDropdown.js"></script>
    <script type="text/javascript">
      var drawControls;
      var map;
      var layers;
      var mode;
      var filterCount = 0;

      function init() {

        fillMainSelect();
        getFilterList();

        mode = 0;

        switchMode();

        // Erstellung der Map

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

        // Setzen des Fokus der Karte auf eine bestimmte Koordinate 
        // (Ohne vorher genutzte Koordinate Fokus auf berlin)
        var extend = getExtend();
        if (extend == "") {
          map.setCenter(new OpenLayers.LonLat(13.39115, 52.52008), 8);
        } else {
          map.zoomToExtent(extend);
        }

        // Style der OpenLayers Elemente
        var defStyle = {strokeColor: "black", strokeOpacity: "0.7", strokeWidth: 3, fillColor: "blue", pointRadius: 3, cursor: "pointer"};
        var sty = OpenLayers.Util.applyDefaults(defStyle, OpenLayers.Feature.Vector.style["default"]);
        var sm = new OpenLayers.StyleMap({
          'default': sty,
          'select': {strokeColor: "red", fillColor: "red"}
        });

        // Erstellung der einzelnen Layers
        var pointLayer = new OpenLayers.Layer.Vector("point", {styleMap: sm});
        var lineLayer = new OpenLayers.Layer.Vector("line", {styleMap: sm});
        var polygonLayer = new OpenLayers.Layer.Vector("polygon", {styleMap: sm});

        layers = {
          point: pointLayer,
          line: lineLayer,
          polygon: polygonLayer
        };

        map.addLayers([pointLayer, lineLayer, polygonLayer]);
        map.addControl(new OpenLayers.Control.MousePosition());
        map.addControl(new OpenLayers.Control.Navigation());

        // anfügen der Draw-Features
        var pointDrawFeature = new OpenLayers.Control.DrawFeature(pointLayer,
                OpenLayers.Handler.Point, {handlerOptions: {style: sty}});

        var lineDrawFeature = new OpenLayers.Control.DrawFeature(lineLayer,
                OpenLayers.Handler.Path, {handlerOptions: {style: sty}});

        var polygonDrawFeature = new OpenLayers.Control.DrawFeature(polygonLayer,
                OpenLayers.Handler.Polygon, {handlerOptions: {style: sty}});

        drawControls = {
          point: pointDrawFeature,
          line: lineDrawFeature,
          polygon: polygonDrawFeature
        };

        // Fubktion zum Fortfahren zu den nächsten Seiten
        for (var key in drawControls) {
          map.addControl(drawControls[key]);
          // register a listener on each control
          drawControls[key].events.register('featureadded', drawControls[key], function (f) {
            var extend = this.map.getExtent();
            document.cookie = "extend=" + extend;
            // create a WKT reader/parser/writer          
            var wkt = new OpenLayers.Format.WKT();
            // write out the feature's geometry in WKT format
            var geom = wkt.write(f.feature);
            if (mode === 1) {
              var lonlat = getlonlat(geom);
              document.getElementById('long').value = lonlat[0];
              document.getElementById('lat').value = lonlat[1];
            } else {
              var newGeom = geom;
              document.getElementById('geom').value = newGeom;
            }
            document.getElementById('long_lat_submit').click();
            alert("Ihre Auswahl wird bearbeitet!");
          });
        }
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
       * Filtert Daten von lon und lat aus Punkt Geometrie
       * @param {type} out Eingelesen Daten beim setzen eines Punktes
       * @returns Longitude und Latitude durch komma getrennt
       */
      function getlonlat(out) {
        var point = out.replace("POINT(", "");
        point = point.replace(")", "");
        point = point.split(" ");
        return point;
      }

      /**
       * Fügt eine Filteroption für das Suchen von vorhandenen Geometrien 
       * hinzu und zeigt diese an
       */      
      function addFilter() {
        var keyBox = document.getElementById("keyContainer");
        var valueBox = document.getElementById("valueContainer");
        var btnBox = document.getElementById("btnContainer");

        var keyField = document.getElementById("keyField");
        var valueField = document.getElementById("valueField");

        if (keyField.value === "" || valueField.value === "") {
          alert("Beide Felder müssen ausgefüllt werden!");
        } else {
          filterCount++;
          var filterPos = document.getElementById("keyValueList");
          if (!filterPos.hasChildNodes()) {
            var text = document.createElement("div");
            text.textContent = "Bisherige Filtertags: ";
            text.setAttribute("id", "showFilterList");
            filterPos.appendChild(text);
            document.getElementById("filterIntro").textContent = "Wollen Sie weitere Filter hizufügen?";
          }

          var id = keyField.value + "+" + valueField.value;
          var eraserCommand = "removeFilter('" + id + "')";

          var showContainer = document.createElement("div");
          showContainer.setAttribute("id", id);

          var showKeyValue = document.createElement("input");
          showKeyValue.setAttribute("class", "showKeyValue");
          showKeyValue.setAttribute("value", keyField.value + "=" + valueField.value);
          showKeyValue.disabled = true;
          showContainer.appendChild(showKeyValue);

          var eraser = document.createElement("a");
          eraser.textContent = " löschen";
          eraser.setAttribute("style", "cursor: pointer; color: blue;");
          eraser.setAttribute("onclick", eraserCommand);
          showContainer.appendChild(eraser);

          filterPos.appendChild(showContainer);

          document.getElementById("mainTagSelect").value = "";
          document.getElementById("secondaryTagSelect").value = "";
          keyBox.style.visibility = "hidden";
          valueBox.style.visibility = "hidden";
          btnBox.style.visibility = "hidden";
          document.getElementById("chooseSecondaryCategory").style.visibility = "hidden";
          keyField.value = "";
          valueField.value = "";
          getFilterList();
        }
      }

      /**
       * Entfernt eine gewünschte Filteroption wieder aus den Suchoptionen
       * @param input ID des zu löschenden Filterelements
       */ 
      function removeFilter(input) {
        filterCount--;
        if (filterCount === 0) {
          document.getElementById("filterIntro").textContent = "Wollen Sie die Ergebnisse auf bestimmte Tags begrenzen?";
          document.getElementById("keyValueList").removeChild(document.getElementById("showFilterList"));
        }
        var toBeErased = document.getElementById(input);
        document.getElementById("keyValueList").removeChild(toBeErased);
        getFilterList();
      }

      /**
       * Sucht alle Filterelemente und schreibt sie in ein Inputelement
       */
      function getFilterList() {
        var filterListString = "";
        var filterList = document.getElementsByClassName("showKeyValue");
        for (var i = 0; i < filterList.length; i++) {
          filterListString += filterList[i].value;
          if (i < filterList.length - 1)
            filterListString += ",";
        }
        document.getElementById("filterList").value = filterListString;
      }

      /**
       * Wechselt zwischen dem Modus zum erstellen neuer Objekte und dem Modus 
       * zum finden bereits vorhandener Objekte und führt nötige Änderungen 
       * durch.
       */
      function switchMode() {
        if (mode === 0) {
          document.getElementById("title").textContent =
                  "Bitte Referenzpunkt zum finden vorhandener Objekte einzeichnen";

          document.getElementById("pointLabel").textContent = "Objekt auswählen";

          document.getElementById("switchText").textContent = "oder wollen Sie ein";
          document.getElementById("switchBtn").value = "neues Objekt erstellen";

          document.getElementById("lineToggle").style.visibility = "hidden";
          document.getElementById("polygonToggle").style.visibility = "hidden";
          

          document.getElementById("noneToggle").checked = "checked";

          toggleControl("none");

          document.getElementById("formular").action = "chooseNextAction.jsp";

          document.getElementById("rightContainer").style.visibility = "visible";

          mode = 1;
        } else {
          document.getElementById("title").textContent =
                  "Bitte Koordinaten des neuen Objektes einzeichnen";

          document.getElementById("pointLabel").textContent = "Punkt einzeichnen";

          document.getElementById("switchText").textContent = "oder wollen Sie";
          document.getElementById("switchBtn").value = "vorhandene Objekte bearbeiten";

          document.getElementById("lineToggle").style.visibility = "visible";
          document.getElementById("polygonToggle").style.visibility = "visible";

          document.getElementById("noneToggle").checked = "checked";

          toggleControl("none");

          document.getElementById("formular").action = "geometrieFertigstellen.jsp";

          document.getElementById("rightContainer").style.visibility = "hidden";
          document.getElementById("chooseSecondaryCategory").style.visibility = "hidden";
          document.getElementById("keyContainer").style.visibility = "hidden";
          document.getElementById("valueContainer").style.visibility = "hidden";
          document.getElementById("btnContainer").style.visibility = "hidden";    
          
          document.getElementById("mainTagSelect").value = "";

          mode = 0;
        }
      }

      /**
       * Wechselt den genutzten Layertyp (Punkt/Linie/Polygon)
       * @param {type} element Typ des genutzten Layertyps
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
    </script>
    <style>
      #title {
        min-width: 600px;
      }

      #map {
        width: 100%; 
        height: 70%; 
        min-height: 400px; 
        min-width: 600px; 
        border: 2px solid #000;               
      }

      #container {
        margin-top: 20px;
      }

      #switchBtn {
        margin-left: 15px;
        margin-top: -3px;
      }

      #leftContainer {
        float: left;
        width: 350px;
      }

      #rightContainer, #switchText {
        float: left;
      }

      #valueContainer, #keyContainer {
        margin-top: 15px;
        width:200px;
      }      

      #chooseSecondaryCategory, #btnContainer, #chooseCategory, #keyValueList {
        margin-top: 15px;
      }

      #keyField, #valueField {
        float: right; 
        width: 150px;
      }      

      #keyValueList {
        width: 350px;
        margin-bottom: 20px;
      }

      #showFilterList {
        margin-bottom: 15px;        
      }

      #btn {
        width: 200px;
        margin-bottom: 70px;
      }

      .showKeyValue {
        width: 250px;
      }
      #switchContainer {
        margin-bottom: 300px;
      }      

    </style>
  </head>
  <body onload="init()">

    <div id="map" class="smallmap"></div>

    <h1 id="title"></h1>    

    <form action="chooseNextAction.jsp" method="post" accept-charset="UTF-8" id="formular">
      <input id="geom" name="geom" type="text" value="0" style="display: none;"/>
      <input id="long" name="long" type="text" value="0" style="display: none;"/>
      <input id="lat" name="lat" type="text" value="0" style="display: none;"/>
      <input id="filterList" name="filterList" type="text" value="0" style="display: none;"/>
      <input id="long_lat_submit" type="submit" style="display: none;"/>
    </form>

    <div id="container">
      <div id="switchText">oder wollen Sie ein </div>
      <input id="switchBtn" type="button" value="neues GeoObjekt erstellen" 
             onclick="switchMode()">
    </div>

    <div id="switchContainer">
      <div id="leftContainer">
        <ul id="controlToggle">
          <li>
            <input type="radio" name="type" value="none" id="noneToggle" class="radio"
                   onclick="toggleControl(this);" checked="checked" />
            <label for="noneToggle">Karte Bewegen</label>
          </li>
          <li id="pointToggle">
            <input type="radio" name="type" value="point" onclick="toggleControl(this);" class="radio"/>
            <label for="pointToggle" id="pointLabel" >Punkt einzeichnen</label>
          </li>
          <li id="lineToggle">
            <input type="radio" name="type" value="line"  onclick="toggleControl(this);" class="radio"/>
            <label for="lineToggle">Linie einzeichnen</label>
          </li>
          <li id="polygonToggle">
            <input type="radio" name="type" value="polygon"  onclick="toggleControl(this);" class="radio"/>
            <label for="polygonToggle">Polygon einzeichnen</label>
          </li> 
        </ul>
      </div>
      <div id = "rightContainer" style = "visibility: hidden;">
        <div id="keyValueList"></div>
        <a id="filterIntro">Wollen Sie die Ergebnisse auf bestimmte Tags begrenzen?</a>

        <div id="chooseCategory">
          <label for="mainTagSelect">Bitte eine Objekt-Kategorie wählen: </label>
          <select id="mainTagSelect" onchange="createContentMain(1)"> </select>
        </div>
        <div id="chooseSecondaryCategory" style="visibility: hidden;">
          <label for="secondaryTagSelect">Bitte passenden Tag wählen: </label>
          <select id="secondaryTagSelect" onchange="handleSecond(1)"> </select>
        </div>
        <div id="keyContainer" style="visibility: hidden;">
          <label id="label" for="keyField">Key: </label>
          <input type="text" id="keyField" value =""  />          
        </div>
        <div id="valueContainer" style="visibility: hidden;">
          <label id="label" for="valueField">Value: </label>
          <input type="text" id="valueField" value ="" />          
        </div>        
        <div id="btnContainer" style="visibility: hidden;">          
          <input type="button" onclick="addFilter()" id="btn" value ="Filteroption hinzufügen"/>          
        </div>
      </div>
    </div>    
  </body>
</html>
