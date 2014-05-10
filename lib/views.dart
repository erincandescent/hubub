library hubub.views;
import 'dart:async';
import 'dart:io';
import 'package:alchemy/core.dart';
import 'package:plumbing/models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_static/shelf_static.dart' as static;
import 'package:shelf_exception_response/exception_response.dart';
import 'package:page_templates/server.dart';
import 'server.dart';

var _t = new TemplateLibrary("hubub");

Response _notFound(Request _) {
  throw new NotFoundException();
}

_get(map, key, default_) {
  if(map.containsKey(key)) {
    return map[key];
  } else {
    return default_;
  }
}

/*_reportSpam(id) {
  var conn = Connection.current;
  conn[Activity].get({"id": id}).then((v) {
    if(v != null) {
      return v.object.then((obj) {
        var map = new Map.from(v);
        map["object"] = new Map.from(obj);
        
        var body = JSON.encode(map);
        print("ReqBody is ${body}");
        return spamClient.post("https://spamicity.info/tokenize", 
            headers: { "Content-Type": "application/json" },
            body: body).then((resp) {
        
          print("Body is " + resp.body);
          return true;
        });
      });
    } else {
      print("No such object");
      return false;
    }
  });
}*/

_home(Request req) {
  Template template = _t["stream.html"];
  
  int start = int.parse(_get(req.requestedUri.queryParameters, "start", "0"));
  int limit = int.parse(_get(req.requestedUri.queryParameters, "limit", "30"));
  print("Start ${start} limit ${limit} URI ${req.requestedUri}");
  var context = {};
  
  return new Future.sync(() {
    /*print("Method ${req.method}");
    if(req.method == "POST") {
      return req.readAsString().then((String bodyStr) {
        var post = Uri.splitQueryString(bodyStr);
        
        print("Spam report ${post['id']}");
        
        return _reportSpam(post["id"]);
      }).then((res) {
        context["hasMessage"] = true;
        if(res) {
          context["message"] = "Thank you for your report";
        } else {
          context["message"] = "Sorry, an error occurred processing your report";
        }
      });
    }*/
    return null;
  }).then((_) {
    return Connection.current[Activity].find({ 
        "verb": { 
          "\$in" : [ "post", "share" ]
         }
      }, 
      skip: start, 
      limit: limit, 
      sort: {"published": -1}).toList();
  }).then((activities) {
    context["activities"] = activities;
    var haveTime = meanTimeBetweenActivities != null;
    context["haveTime"]   = haveTime;
    if(haveTime) context["time"] = meanTimeBetweenActivities.inSeconds;
      
    return template.evaluate(context).then((doc) {
      return new Response.ok(doc.outerHtml, headers: {
        'Content-Type': 'text/html'
      });
    });
  });
}

routes() {
  var r = new Router()
    ..get("/packages", static.getHandler(Platform.script.resolve('packages').toFilePath(), restrictSymbolicLinks: false))
    ..get("/", _home)
    ..addRoute(_notFound)
    ;
  
  return r.handler;
}