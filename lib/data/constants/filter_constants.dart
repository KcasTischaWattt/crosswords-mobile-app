import 'dart:collection';

final List<String> _sources = [
  'Коммерсант',
  'Интерфакс',
  'ЦБ РФ',
  'ЦБ Узбекистан',
  'ЦБ Таджикистан',
  'ЦБ Кыргызстан',
  'ЦБ Азербайджан',
];

final List<String> _tags = [
  'Политика',
  'Экономика',
  'Технологии',
  'Спорт',
  'Кредит',
  'IT',
  'Зарплаты',
  'Кибербезопасность',
  'Футбол',
  'СБП',
];

final UnmodifiableListView<String> defaultSources = UnmodifiableListView(_sources);
final UnmodifiableListView<String> defaultTags = UnmodifiableListView(_tags);