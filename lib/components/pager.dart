library hubub.components.pager;
import 'dart:math';
import 'dart:html';
import 'package:polymer/polymer.dart';

class Page {
  final int number;
  final bool selected, first, last;
  
  Page(this.number, this.selected, this.first, this.last);
}

@CustomTag('hubub-pager')
class HububPager extends PolymerElement {
  @observable int page = 1;
  @observable List<Page> pages;
  
  HububPager.created() : super.created() {
    print("HububPager created $this");
    new PathObserver(this, "page").open((v) => _updatePages());
  }
  
  void attached() {
    super.attached();
    
    _updatePages();
  }
  
  _updatePages() {
    var first = max(page - 2, 1);
    var last = first + 4;
    
    pages = new List.generate(5, (n) {
      n += first;
      return new Page(n, n == page, n == first, n == last);
    }, growable: false);
  }
  
  clickPage(Event e, var detail, Element target) {
    page = int.parse(target.getAttribute("number"));
  }
}

