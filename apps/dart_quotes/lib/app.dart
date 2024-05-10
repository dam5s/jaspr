import 'package:dart_quotes/pages/home_page.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/quote_page.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'main', [
      Router(
        routes: [
          Route(path: '/', title: 'Home', builder: (context, state) => HomePage()),
          Route(
            path: '/quote/:quoteId',
            title: 'Quote',
            builder: (context, state) => QuotePage(id: state.params['quoteId']!),
          ),
        ],
      ),
    ]);
    yield a(classes: "github-badge", href: "https://github.com/schultek/jaspr", [
      img(src: '/images/github-badge.svg'),
    ]);
  }

  static get styles => [
        css('.main') //
            .box(
          minHeight: 100.vh,
          maxWidth: 500.px,
          margin: EdgeInsets.all(Unit.auto),
          padding: EdgeInsets.symmetric(horizontal: 2.em),
        ),
        css('.github-badge').box(position: Position.absolute(top: 0.px, right: 0.px))
      ];
}
