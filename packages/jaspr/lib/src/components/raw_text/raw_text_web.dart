import 'dart:html' as html;

import '../../../browser.dart';

/// Renders its input as raw HTML.
///
/// **WARNING**: This component does not escape any
/// user input and is vulnerable to [cross-site scripting (XSS) attacks](https://owasp.org/www-community/attacks/xss/).
/// Make sure to sanitize any user input when using this component.
class RawText extends StatelessComponent {
  const RawText(this.text, {super.key});

  final String text;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var fragment = html.document.createDocumentFragment()..setInnerHtml(text, validator: AllowAll());
    for (var node in fragment.childNodes) {
      yield RawNode.withKey(node);
    }
  }
}

class RawNode extends Component {
  RawNode(this.node, {super.key});

  factory RawNode.withKey(html.Node node) {
    return RawNode(
      node,
      key: switch (node) {
        html.Text() => ValueKey('text'),
        html.Element(:var tagName) => ValueKey('element:$tagName'),
        _ => null,
      },
    );
  }

  final html.Node node;

  @override
  Element createElement() => RawNodeElement(this);
}

class RawNodeElement extends BuildableRenderObjectElement {
  RawNodeElement(RawNode super.component);

  @override
  RawNode get component => super.component as RawNode;

  @override
  Iterable<Component> build() sync* {
    for (var node in component.node.childNodes) {
      yield RawNode.withKey(node);
    }
  }

  @override
  void updateRenderObject() {
    var next = component.node;
    if (next is html.Text) {
      renderObject.updateText(next.text ?? '');
    } else if (next is html.Element) {
      renderObject.updateElement(next.tagName.toLowerCase(), next.id, next.className, null, next.attributes, null);
    } else {
      var curr = (renderObject as DomRenderObject).node;
      if (curr != null) {
        curr.replaceWith(next);
      }
      (renderObject as DomRenderObject).node = next;
    }
  }
}

class AllowAll implements html.NodeValidator {
  @override
  bool allowsAttribute(html.Element element, String attributeName, String value) {
    return true;
  }

  @override
  bool allowsElement(html.Element element) {
    return true;
  }
}
