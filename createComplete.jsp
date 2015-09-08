<%-- 
    Document   : createComplete
    Created on : 24.06.2015, 15:41:50
    Author     : Tommy Ball
--%>

<%@page import="org.json.JSONArray"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <script type="text/javascript" src="createContent.js"></script>
    <title>OHDM - Editor</title>
    <%
      String key = "";
      String JSONString = "";
      try {
        request.setCharacterEncoding("UTF-8");
        JSONString = request.getParameter("JSONString");

        String token = "b13d3b247d0c0a4c5ddd6db91b5108e123bdb8fbda9d0cfbdebb806f0a9408c3210579cc53d44d6addd00a78e972747522a4dc3928cd99975a5f462ee1062395";
        Cookie[] cookies = request.getCookies();

        if (cookies != null && JSONString != null) {
          for (Cookie cookie : cookies) {
            if (cookie.getName().equals("allowCreate")) {                         // Überprüfung ob erstellen erlaubt ist
              if (cookie.getValue().equals("true")) {
                // Verbindung öffnen 
                URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
                //URL url = new URL("http://127.0.0.1:8080/OhdmApi/"
                        + "geographicObject/");

                HttpURLConnection con = (HttpURLConnection) url.openConnection();
                // Verbindung herstellen
                con.setRequestMethod("PUT");
                con.setRequestProperty("Content-Type",
                        "application/json; charset=utf-8");
                con.setRequestProperty("Authorization", "Bearer " + token);
                // JSON senden
                con.setDoOutput(true);
                OutputStreamWriter conOut = new OutputStreamWriter(con.getOutputStream());
                conOut.write(JSONString);
                conOut.flush();
                conOut.close();

                BufferedReader in = new BufferedReader(
                        new InputStreamReader(con.getInputStream()));
                String inputLine;
                StringBuilder aresponse = new StringBuilder();                                  // StringBuilder fuer die zu empfangenden Daten

                while ((inputLine = in.readLine()) != null) {
                  aresponse.append(inputLine);                                                  // Empfangene Daten Zeilenweise zusammensetzen
                }
                in.close();

                int responseCode = con.getResponseCode();
                // wenn alles geklappt hat
                if (responseCode >= 200 && responseCode < 300) {
                  key = new JSONArray('[' + aresponse.toString() + ']').getJSONObject(0).get("key").toString();
                  out.println("Daten erfolgreich gesendet!");
                  cookie = new Cookie("allowCreate", "false");
                  cookie.setMaxAge(-1);
                  response.addCookie(cookie);
                  cookie = new Cookie("usedId", key);
                  response.addCookie(cookie);
                } else {
                  out.println("Fehler beim Senden!");

                }
              } else {
                out.println("Senden ist nicht gestattet... Möglicherweise wurde bereits gesendet");
              }
            }
          }
        } else {
          out.println("Keine Parameter vorhanden");
        }
      } catch (Exception e) {
        out.println("Keine Parameter vorhanden");
      }
    %>
    <script type="text/javascript">
      function init() {
        var id = '<%= key%>';
        var fresh = 1;
        if (id == "") {
          fresh = 0;
          var cookies = document.cookie.split(";");
          for (var i = 0; i < cookies.length; i++) {
            var tmp = cookies[i].split("=")[0].split(" ").join("");
            if (tmp == "usedId") {
              id = cookies[i].split("=")[1];
              i = cookies.length;
            }
          }
        }
        if (id == "") {
          fresh = -1;
        }
        nextStep(fresh, id);
      }
      // Menü zum fortfahren erstellen
      function nextStep(fresh, id) {
        var con = document.getElementById("questionContainer");

        var question = document.createElement("div");
        question.setAttribute("style", "width: 63%; margin: 6em auto;")
        if (fresh === -1) {
          question.textContent = "Sie haben bisher kein Objekt bearbeitet!";
          createButton("Zurück zum Anfang!", question, "toIndex()", "");
        } else {
          if (fresh === 1) {
            question.textContent = "Sie haben das Objekt mit der ID:" + id + " erstellt!\n\n\
          Was möchten Sie als nächstes tun?:";
          }
          if (fresh === 0) {
            question.textContent = "Sie haben das Objekt mit der ID:" + id + " zuletzt bearbeitet!\n\n\
          Was möchten Sie als nächstes tun?:";
          }
          createButton("Zurück zum Anfang!", question, "toIndex()", "");
          createButton("Tags von " + id + " bearbeiten", question, "toTagEdit('" + id + "')", "");
          createButton("Geodaten von " + id + " bearbeiten", question, "toGeoEdit('" + id + "')", "");
        }
        con.appendChild(question);
      }
      // Zurück zum start
      function toIndex() {
        window.location = "index.jsp";
      }
      // Zuletzt erfolgreich geändertes Geoobjekt -> Geometrie ändern
      function toGeoEdit(id) {
        document.getElementById("formular").action = "geoEdit.jsp";
        document.getElementById("originalID").value = id;
        document.getElementById("submit").click();
      }
      // Zuletzt erfolgreich geändertes Geoobjekt -> Tags ändern
      function toTagEdit(id) {
        document.getElementById("formular").action = "tagEdit.jsp";
        document.getElementById("originalID").value = id;
        document.getElementById("submit").click();
      }

    </script>

    <style>
      #questionContainer {
        position:absolute;
        top: 50%;
        left: 50%;
        width:40em;
        height:24em;
        margin-top: -12em; 
        margin-left: -20em; 
        border: 1px solid #ccc;
        background-color: #f3f3f3;
      }



      .btn {
        width: 100%;
        margin-top: 25px;
      }
    </style>
  </head>
  <body onload="init()">
    <div id="questionContainer"></div>
    <form action="tagEdit.jsp" id="formular" method="post" accept-charset="UTF-8">
      <input id="originalID" name="originalID" type="text" style="display: none;"/>
      <input id="submit" type="submit" style="display: none;"/>      
    </form>
  </body>
</html>
