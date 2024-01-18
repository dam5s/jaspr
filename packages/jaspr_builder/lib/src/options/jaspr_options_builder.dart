import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

import '../client/client_module_builder.dart';

/// Builds part files and web entrypoints for components annotated with @app
class JasprOptionsBuilder implements Builder {
  JasprOptionsBuilder(BuilderOptions options);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    try {
      await generateOptionsOutput(buildStep);
    } catch (e, st) {
      print('An unexpected error occurred.\n'
          'This is probably a bug in jaspr_builder.\n'
          'Please report this here: '
          'https://github.com/schultek/jaspr/issues\n\n'
          'The error was:\n$e\n\n$st');
      rethrow;
    }
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        r'lib/$lib$': ['lib/jaspr_options.dart'],
      };

  String get generationHeader => "// GENERATED FILE, DO NOT MODIFY\n"
      "// Generated with jaspr_builder\n";

  Future<void> generateOptionsOutput(BuildStep buildStep) async {
    var clients = await buildStep
        .findAssets(Glob('lib/**.client.json'))
        .asyncMap((id) => buildStep.readAsString(id))
        .map((c) => ClientModule.deserialize(jsonDecode(c)))
        .toList();

    var clientImports = clients.mapIndexed((i, c) => "import '${path.url.relative(c.id.path, from: 'lib')}' as c$i;");

    var clientEntries = clients.mapIndexed((i, c) => '''
      c$i.${c.name}: ComponentEntry.client(
        '${path.url.relative(path.url.withoutExtension(c.id.path), from: 'lib')}'
        ${c.params.isNotEmpty ? ', params: {${c.params.map((p) => "'${p.name}': self.${p.name}").join(', ')}},' : ''}
      ),
    ''').join("\n");

    var optionsId = AssetId(buildStep.inputId.package, 'lib/jaspr_options.dart');
    var optionsSource = DartFormatter(pageWidth: 120).format('''
      $generationHeader
      
      import 'package:jaspr/jaspr.dart';
      
      ${clientImports.join("\n")}
      
      const defaultJasprOptions = JasprOptions(
        clientComponents: {
          $clientEntries
        },
      );
    ''');

    await buildStep.writeAsString(optionsId, optionsSource);
  }
}
