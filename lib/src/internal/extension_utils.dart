import 'package:kdbx/src/kdbx_xml.dart';
import 'package:xml/xml.dart' as xml;

extension XmlElementExt on xml.XmlElement {
  xml.XmlElement singleElement(String nodeName,
      {xml.XmlElement Function() orElse}) {
    final elements = findElements(nodeName);
    if (elements.isEmpty) {
      if (orElse != null) {
        final ret = orElse();
        children.add(ret);
        return ret;
      } else {
        return null;
      }
    }
    return elements.single;
  }

  String singleTextNode(String nodeName) {
    return findElements(nodeName).single.text;
  }

  /// If an element child with the given name already exists,
  /// it will be removed and the given element will be added.
  /// otherwise it will be only added.
  void replaceSingle(xml.XmlElement element) {
    XmlUtils.removeChildrenByName(this, element.name.local);
    children.add(element);
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}
