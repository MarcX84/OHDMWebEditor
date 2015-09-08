<%-- 
    Document   : transmit
    Created on : 29.05.2015, 14:28:28
    Author     : Tommy Ball
--%>

<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.OutputStreamWriter"%>
<%@page import="java.net.HttpURLConnection"%>
<%@page import="java.net.URL"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <script type="text/javascript" src="createContent.js"></script>
    <title>OHDM - Editor</title>

    <%
      String origId = "";
      String JSONString = "";
      try {
        request.setCharacterEncoding("UTF-8");
        origId = request.getParameter("originalId");
        JSONString = request.getParameter("JSONString");
        String token = "74dc2f347d73ef4fbec38de0429b1357fcb5687f1879495c6e2bf289f6d3411eb391bf4bd2608176749040478bdac6fb5566543cedc9b963114a3b4cc98a032f";

        Cookie[] cookies = request.getCookies();

        if (cookies != null && origId != null && JSONString != null) {
          for (Cookie cookie : cookies) {
            if (cookie.getName().equals("allowSend")) {
              if (cookie.getValue().equals("true")) {
                URL url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/geographicObject/");
                for (Cookie cookieSecond : cookies) {
                  if (cookieSecond.getName().equals("sendKind")) {
                    if (cookieSecond.getValue().equals("geo")) {
                      url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
                      //url = new URL("http://127.0.0.1:8080/OhdmApi/"
                              + "geographicObject/" + origId);                  // Geometriedaten updaten
                    } else {
                      url = new URL("http://ohsm.f4.htw-berlin.de:8080/OhdmApi/"
                      //url = new URL("http://127.0.0.1:8080/OhdmApi/"
                              + "tagDate/"
                              + "geographicObject/" + origId);                  // Tagdaten updaten
                    }
                  }
                }

                //     out.println(url.toString());
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

                int responseCode = con.getResponseCode();

                out.println(responseCode);

                if (responseCode == 200) {
                  out.println("Daten erfolgreich gesendet!");
                  cookie = new Cookie("allowSend", "false");
                  cookie.setMaxAge(-1);
                  response.addCookie(cookie);
                  cookie = new Cookie("sendKind", "false");
                  cookie.setMaxAge(-1);
                  response.addCookie(cookie);
                  cookie = new Cookie("usedId", origId);
                  response.addCookie(cookie);
                } else {
                  out.println("Fehler beim Senden! Möglicherweise wurden keine Änderungen vorgenommen!");
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

 //     out.println(JSONString);

    %>

    <script type="text/javascript">
      function init() {
        var id = -1;
        var cookies = document.cookie.split(";");
        for (var i = 0; i < cookies.length; i++) {
          var tmp = cookies[i].split("=")[0].split(" ").join("");
          if (tmp == "usedId") {
            id = cookies[i].split("=")[1];
            i = cookies.length;
          }
        }
        nextStep(id);
      }

      /**
       * Menü zur auswahl der nächsten Aktion
       * Nochmaliges bearbeiten des zuletzt erfolgreich bearbeiteten Objektes, 
       * falls vorhanden, oder zurück zum Anfang
       * @param {type} id ID des zuletzt erfolgreich bearbeiteten Geoobjektes,
       * -1 wenn bisher kein Objekt erfolgreich bearbeitet wurde
       */
      function nextStep(id) {
        var con = document.getElementById("questionContainer");

        var question = document.createElement("div");
        question.setAttribute("style", "width: 63%; margin: 6em auto;");

        if (id != -1) {
          question.textContent = "Sie haben das Objekt mit der ID:" + id + " zuletzt erfolgreich bearbeitet!\n\n\
          Was möchten Sie als nächstes tun?:";

          createButton("Zurück zum Anfang!", question, "toIndex()", "");
          createButton("Tags von " + id + " bearbeiten", question, "toTagEdit('" + id + "')", "");
          createButton("Geodaten von " + id + " bearbeiten", question, "toGeoEdit('" + id + "')", "");
        } else {
          question.textContent = "Sie haben bisher kein Objekt erfolgreich bearbeitet!";
          createButton("Zurück zum Anfang!", question, "toIndex()", "");
        }
        con.appendChild(question);
      }
      // Zurück zum Start
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
        margin-top: -12em; /*set to a negative number 1/2 of your height*/
        margin-left: -20em; /*set to a negative number 1/2 of your width*/
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
