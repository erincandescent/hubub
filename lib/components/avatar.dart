library hubub.components.avatar;
import 'package:polymer/polymer.dart';

@CustomTag('hubub-avatar')
class HububAvatar extends PolymerElement {
  @observable String src  = "";
  @observable String href = "";

  HububAvatar.created() : super.created() {
  }
}

