library hubub.views;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'server.dart';
import 'package:alchemy/core.dart';
import 'package:plumbing/models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_static/shelf_static.dart' as static;
import 'package:shelf_exception_response/exception_response.dart';

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

_streamHandler(Request req) {
  var page  = int.parse(_get(req.requestedUri.queryParameters, "page", "1"));
  var limit = int.parse(_get(req.requestedUri.queryParameters, "limit", "30"));
  var start = (page - 1) * limit;
  
  return Connection.current[Activity].find({ 
         "verb": { 
           "\$in" : [ "post", "share" ]
          }
       }, 
       skip: start, 
       limit: limit, 
       sort: {"published": -1}).toList().then((List<Activity> activities) {
    
    return Future.wait(activities.map((a) => a.export(depth: 3)));
  }).then((List<Map> items) {
    // Build the collection object
    var links = {};
    var baseUri = req.requestedUri;
    
    if(items.length >= limit) {
      var nextUri = baseUri.resolveUri(new Uri(queryParameters: {'page': '${page+1}', 'limit': '$limit'}));
      links['next'] = nextUri.toString();
    }
    
    if(page > 1) {
      var prevUri = baseUri.resolveUri(new Uri(queryParameters: {'page': '${page-1}', 'limit': '$limit'}));
      links['prev'] = prevUri.toString();
    }
    
    var collection = {
      'itemsPerPage': limit,
      'links': links,
      'items': items,
    };
    
    var body = JSON.encode(collection);
    return new Response.ok(body, headers: {"Content-Type": "application/json"});
  });
}

_makeRootHandler() {
  var main = static.createStaticHandler(
          Platform.script.resolve('../build/web').toFilePath(), 
          defaultDocument: 'hubub.html',
          serveFilesOutsidePath: true);
  
  if(developerMode) {
    var dev = static.createStaticHandler(
        Platform.script.resolve('../web').toFilePath(), 
        defaultDocument: 'hubub.html',
        serveFilesOutsidePath: true);
    
    return (Request req) {
      if(req.headers["User-Agent"].contains("Dart")) {
        return dev(req);
      } else {
        return main(req);
      }
    };
  } else {
    return main;
  }
}

routes() {
  var r = new Router()
    ..get("/stream.json", _streamHandler)
    ..get("/", _makeRootHandler())
    ..addRoute(_notFound)
    ;
  
  return r.handler;
}