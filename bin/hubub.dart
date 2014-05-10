import 'dart:io';
import 'package:hubub/server.dart';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart' as yaml;

void main(List<String> argv) {
  var args = new ArgParser();
  args.addOption("config", defaultsTo: "hubub.yaml", help: "Configuration file path");
  args.addFlag("debug", abbr: "d", help: "More verbose logging");
  
  var results = args.parse(argv);
  
  // Setup logging
  Logger.root.level = results['debug'] ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.loggerName} ${rec.time}: ${rec.message}');
    if(rec.error != null) {
      print(rec.error);
    }
    if(rec.stackTrace != null) {
      print(rec.stackTrace);
    }
  });
  
  // Open config
  Map config = yaml.loadYaml(new File(results["config"]).readAsStringSync());
  
  // Start server
  startServer(config);
}
