library hubub.components.object;
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'avatar.dart';

class _PermissivePolicy implements UriPolicy {
  bool allowsUri(String uri) {
    return true;
  }
}

class Activity {
  final HububObject tag;
  Activity(this.tag);
  _get(Map m, String k, alternative) => m.containsKey(k) ? m[k] : alternative;
  _getd(Map m, String k, alternative) => m.containsKey(k) ? m[k] : alternative();
  
  Map get raw => tag.activity;
  
  Map get actor  => _get(raw, "actor",  {});
  Map get object => _get(raw, "object", {});
  
  Map get author => _getd(object, "author", () => actor);
  String get avatar => _get(_get(author, "image", {}), "url", "/packages/hubub/noavatar.png");
  String get authorName => _getd(author, "displayName", () => _get(author, "preferredUsername", ""));
  
  String get title     => object["displayName"];
  String get authorUrl => author["url"];
  String get body      => object["content"];

  String get objectUrl => _get(object, "url", "");
    
  String get time {
    var time = DateTime.parse(object["published"]);
    var format = new DateFormat.yMMMMEEEEd().add_Hms(); 
    return format.format(time);
  }
    
    _procRecipients(String list) {
      print("_procRecipients this is $this");
      var l = _get(raw, list, []);
      for(var v in l) {
        if(v["id"] == "http://activityschema.org/collection/public") {
          v["displayName"] = "Public";
        }
      }
      return l;
    }
    
    List get to => _procRecipients("to");
    List get cc => _procRecipients("cc");
    
    String get image => _get(_getd(object, "fullImage", () => _get(object, "image", {})), "url", null);
}

@CustomTag('hubub-object')
class HububObject extends PolymerElement {
  @published Map activity;
  @published Activity v;
  
  NodeValidator _validator;
  DivElement get _body => $['body'];
  
  HububObject.created() 
      : super.created() 
  {
    v = new Activity(this);
    
    _validator = new NodeValidatorBuilder()
      ..allowHtml5(uriPolicy: new _PermissivePolicy());
    
    new PathObserver(this, "activity").open(_updateBody);
  }
  
  void attached() {
    super.attached();
    _updateBody();
  }
  
  void _updateBody() {
    if(v.body is String) {
      var frag = new DocumentFragment.html(v.body, validator: _validator);
      _body.nodes
        ..clear()
        ..add(frag);
    } else {
      _body.nodes.clear();      
    }
  }
  
}

