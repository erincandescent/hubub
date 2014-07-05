library hubub.components.login;
import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:core_elements/core_pages.dart';
import 'package:paper_elements/paper_dialog.dart';
import 'package:paper_elements/paper_input.dart';
import 'object.dart';

@CustomTag('hubub-login')
class HububLogin extends PolymerElement {
  @published String arrow_forward = "arrow-forward";
  @published @observable bool opened = false;
  
  PaperDialog   get loginDia => $['loginDia'];
  PaperDialog   get waitDia  => $['waitDia'];
  Element       get error    => $['error'];
  PaperInput    get _id      => $['id'];
  
  HububLogin.created() : super.created() {
    print("HububLogin created $this");
  }
  
  attached() {
    super.attached();
    print("Attached $this");
  }
  
  void open() {
    if(!loginDia.opened) { 
      loginDia.toggle();
    }
    
    new Timer(new Duration(milliseconds: 400), () {
      print("opened");
      InputElement input = _id.jsElement['\$']['input'];
      input.focus();
    });
  }
  
  visibilityChange(value) {
    print("visibilityChange");
  }
  
  void doLogin() {
    loginDia.opened = false;
    waitDia.opened = true;
  }
}

