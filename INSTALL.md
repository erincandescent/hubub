Before installing Hubub, make sure you meet the requirements:

* The Dart SDK must be installed (the version required is declared in·
   pubspec.yaml). Get it from http://dartlang.org/
* You must have a MongoDB database installed
* You'll want a web server to place in front of, and proxy, Hubub.


## Installing
For the following instructions, we assume that you have placed the Dart SDK's bin folder on your path

 1. Clone this repository to your machine
 2. Run "pub get" to download and install dependencies
 3. Run "pub build" in order to build the web pages which will be served
 4. Copy `hubub.sample.yaml` to create the configuration file you want. By default, hubub will load its' settings from `hubub.yaml` in the current directory; you can override this using the `--config` parameter. Instructions on configuring Hubub can be found in the configuration file

To start your server, using `dart bin/hubub.dart` You can pass the option `--config yourconfig.yaml` in order to override the default configuration file. If you want more verbose logging, pass the `-d` option. 

**You must run Hubub behind a frontend proxy.** The Dart web libraries assume this is the case and interpret various headers normally passed by reverse proxies. If you don't run Hubub behind a frontend proxy, you may suffer random issues and malfunctions. You are warned.

**Caching.** Hubub sets the Last-Modified HTTP header, and interprets the If-Modified-Since header when serving static files. If you want more intensive caching, serve the `/packages/` folder (created by `pub get`) straight from your HTTP server with your desired caching configuration.

**Request compression.** Feel free to enable request compression on your server. In fact, it is recommended: The client JavaScript shrinks by a factor of 5 when compressed.