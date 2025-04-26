import 'dart:collection';
import 'package:crosswords/data/constants/tag_icons.dart';

final List<String> _sources = [
  'Коммерсант',
  'Интерфакс',
  'ЦБ РФ',
  'ЦБ Узбекистан',
  'ЦБ Таджикистан',
  'ЦБ Кыргызстан',
  'ЦБ Азербайджан',
];

final List<String> _tags = (tagIcons.keys.toList()..sort());

final UnmodifiableListView<String> defaultSources =
    UnmodifiableListView(_sources);
final UnmodifiableListView<String> defaultTags = UnmodifiableListView(_tags);
