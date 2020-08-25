import 'package:shared/shared.dart';

abstract class I18nParser {
  factory I18nParser(String fileName) {
    final fileExtension = fileName.substring(
      fileName.lastIndexOf('.') + 1,
    );

    switch (fileExtension) {
      default:
        return const YamlParser();
    }
  }

  Map<String, String> parse(String file);
}

class YamlParser implements I18nParser {
  const YamlParser();

  @override
  Map<String, String> parse(String file) {
    final Map<String, String> result = {};
    final lines = file.split('\n');

    bool isNewSection(String line) => RegExp(r'\w+:$').hasMatch(line.trimRight());
    bool isLangPair(String line) => RegExp(r'\w+:\s.+').hasMatch(line.trim());

    int sectionIndentation = 0;
    final List<Pair<String, int>> sections = [];
    for (String line in lines) {
      final indentation = _getTabIndentation(line);
      line = line.trimLeft();

      // Ignore comments.
      if (line.trimLeft().startsWith('#')) {
        continue;
      }

      String getPrefixForIndentation() {
        final List<int> alreadyForIndentation = [];

        return sections
            .copy()
            .reversed
            .filter(
              (s) {
                if (s.second < indentation && !alreadyForIndentation.contains(s.second)) {
                  alreadyForIndentation.add(s.second);
                  return true;
                }

                return false;
              },
            )
            .map((s) => s.first)
            .toList()
            .reversed
            .join('_');
      }

      if (isNewSection(line)) {
        final name = line.substring(0, line.indexOf(':'));
        final Pair<String, int> section = Pair(name, indentation);

        if (indentation > sectionIndentation) {
          sections.add(section);
        } else if (indentation == sectionIndentation) {
          if (sections.isNotEmpty) sections.removeLast();
          sections.add(section);
        } else if (indentation < sectionIndentation) {
          for (var i = 0; i < (sectionIndentation - indentation); i++) {
            if (sections.isNotEmpty) sections.removeLast();
          }

          sections.add(section);
        }

        sections.add(section);
        sectionIndentation = indentation;
      } else if (isLangPair(line)) {
        final key = line.substring(0, line.indexOf(':')).trim();
        String value = line.substring(line.indexOf(':') + 1).trim();

        final prefix = getPrefixForIndentation();
        final jsonKey = prefix.isNotEmpty ? '${prefix}_$key' : key;

        // Remove carriage returns
        value = value.replaceAll('\r', '');
        // Add new line charaters
        value = value.replaceAll('\\n', '\n');
        // Remove the first spacing
        value = value.removePrefix(' ');
        // Remove string ticks
        value = value.removePrefix('\"').removeSuffix('\"');
        value = value.removePrefix("'").removeSuffix("'");

        result[jsonKey] = value;
      }
    }

    return result;
  }

  static int _getTabIndentation(String line) {
    int indentation = 0;
    bool wasBlankBefore = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      final isBlank = char == ' ';
      if (isBlank && wasBlankBefore) {
        wasBlankBefore = false;
        indentation++;
      } else {
        wasBlankBefore = isBlank;
      }
    }

    return indentation;
  }
}
