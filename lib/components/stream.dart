library hubub.components.stream;
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('hubub-stream')
class HububStream extends PolymerElement {
  @observable List posts = null;
  @observable int page = 0;
  HttpRequest request = null;

  HububStream.created() : super.created() {
    print("HububStream created $this");
    posts = new ObservableList();
    request = new HttpRequest()
      ..onLoad.listen(_onLoadEvent);
  }
  
  @override
  attached() {
    this.async((_) {
      _onHashChange();
      onPropertyChange(this, #page, _changePage);
      onPropertyChange(windowLocation, #hash, _onHashChange);
    });
  }
  
  _onHashChange() {
    var hash = windowLocation.hash;
    print("onHashChange $hash");
    var pageNum = 1;
    
    if(hash.length > 1) {
      var parts = Uri.splitQueryString(hash.substring(1));
      if(parts.containsKey("page")) {
        pageNum = int.parse(parts["page"], onError: (_) => 1);        
      }
    }
    
    print("$page $pageNum ${request.readyState}");
    page = pageNum;
        
    if(request.readyState != HttpRequest.UNSENT || request.readyState != HttpRequest.DONE) {
      request.abort();
    }
    request.open("GET",  "/stream.json?page=$page");
    request.send();
  }
  
  _onLoadEvent(_) {
    var stream = JSON.decode(request.responseText);
    posts
      ..clear()
      ..addAll(stream["items"]);
  }
  
  _changePage() {
    posts.clear();
    window.location.replace("#page=$page");
    window.scrollTo(0,  0);
  }
}