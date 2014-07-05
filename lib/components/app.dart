library hubub.components.app;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_overlay.dart';
import 'package:core_elements/core_overlay_layer.dart';
import 'package:core_elements/core_toolbar.dart';
import 'package:core_elements/core_menu_button.dart';
import 'package:core_elements/core_menu.dart';
import 'package:core_elements/core_item.dart';

import 'object.dart';
import 'login.dart';

@CustomTag('hubub-app')
class HububApp extends PolymerElement {
  @published String lock_open = "lock-open";
  @published String more_vert = "more-vert";
  HububApp.created() : super.created() {
    print("HububApp created $this");
  }
  
  void signIn() {
    var v = $['login'];
    v.open();
  }
}

