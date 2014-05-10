library hubub;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:alchemy/core.dart' as alchemy;
import 'package:hubsubbable/hubsubbable.dart' as hubsub;
import 'package:plumbing/models.dart' as models;
import 'package:shelf_alchemy/shelf_alchemy.dart' as shelf_alchemy;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:oauth/client.dart' as oauth;
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_exception_response/exception_response.dart' as er;
import 'views.dart';
import 'src/utils.dart';

var _l = new Logger("Hubub");
oauth.Client spamClient;

Handler _convertException(Handler h) { 
  return (Request r) {
    return syncFuture(() => h(r)).catchError((e, trace) {
      _l.shout("Caught exception processing request", e, trace);
      throw new er.HttpException(500, e.toString(), {});
    }, test: (e) => e is! er.HttpException);
  };
}

void startServer(Map config) {
  _l.info("Starting...");
  alchemy.processDocumentAnnotations();
  Uri serverName = Uri.parse(config["serverName"]);

  // Error formatter
  //formatter.registerFormatter("html", "text/html", _htmlErrorFormatter);

  // PuSH endpoint
  var subEndpoint = new hubsub.SubscriptionEndpoint(serverName, "/sub");

  // Setup request pipeline
  var pipeline = new Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware(er.exceptionResponse())
    .addMiddleware(_convertException)
    .addMiddleware(shelf_alchemy.connectionManager(config["database"]))
    .addMiddleware(subEndpoint)
    .addHandler(routes());

  var address = new InternetAddress(config["listen"]["address"]);
  var port = config["listen"]["port"];

  _l.info("Listening on address ${address.address} and port ${port}");

  // OAuth
  var token = new oauth.Token(config["spamicity"]["key"],
      config["spamicity"]["secret"]);

  spamClient = new oauth.Client(token);

  shelf_io.serve(pipeline, address, port).then((server) {
    _l.info("Serving on http://${server.address.host}:${server.port}");
  }).then((_) {
    subEndpoint.subscribe(Uri.parse("https://ofirehose.com/feed.json"), 
        Uri.parse("https://ofirehose.com/hub")).listen((data) {
      shelf_alchemy.runWithConnection(() {
        Map<String, dynamic> root = JSON.decode(data);
        var items = root["items"];
        Future.forEach(items, (item) {
          Map<String, dynamic> activity = item["payload"];
  
          String encoded = JSON.encode(activity);
  
          return spamClient.post("https://spamicity.info/is-this-spam", body:
              encoded, headers: {
            "Content-Type": "application/json"
          }).then((response) {
            var result = JSON.decode(response.body);
            if (result["isSpam"]) {
              _l.info("Activity ${activity['id']} discarded as spam");
            } else {
              _l.info(
                  "PuSHed activity ${activity['id']} not spam with probability ${result['probability']}"
                  );
              alchemy.importDocument(models.Activity, activity).then((_) {
                return alchemy.Connection.current.saveAll();
              });
            }
          });
        });
      });
    });
  });
}
