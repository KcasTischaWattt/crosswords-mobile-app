import '../models/article.dart';

List<Article> fakeArticles = [
  Article(
    id: "1",
    title: "Оборот разработчиков ПО в ноябре вырос на 28,9% г/г - Росстат",
    source: "Интерфакс",
    summary: "Оборот организаций, занимающихся разработкой ПО, консультационными и другими услугами в этой сфере, в ноябре 2024 года увеличился на 28,9% по сравнению с ноябрем 2023 года",
    text: "Оборот организаций, занимающихся разработкой программного обеспечения (ПО), консультационными и другими сопутствующими услугами в этой сфере, в ноябре 2024 года увеличился на 28,9% по сравнению с ноябрем 2023 года",
    tags: ["IT", "Экономика", "Зарплаты"],
    date: "25/03/2024",
    favorite: false,
    language: "RU",
    url: "https://www.interfax.ru/business/1001194",
  ),
  Article(
    id: "2",
    title: "Рынок технологий искусственного интеллекта достиг рекордных масштабов",
    source: "РБК",
    summary: "Искусственный интеллект продолжает активно развиваться в различных сферах бизнеса.",
    text: "Рынок технологий ИИ достиг рекордных масштабов благодаря внедрению в медицину, финансы и производство.",
    tags: ["AI", "Технологии", "Бизнес"],
    date: "20/02/2024",
    favorite: false,
    language: "RU",
    url: "https://www.rbc.ru/tech/ai/2024",
  ),
  Article(
    id: "3",
    title: "Российские банки внедряют биометрические системы идентификации клиентов",
    source: "ТАСС",
    summary: "Крупнейшие банки России начали массово внедрять системы биометрической идентификации клиентов, что повысит безопасность финансовых операций.",
    text: "Банки в России активно внедряют технологии биометрической идентификации, что позволяет клиентам проходить аутентификацию с помощью отпечатков пальцев или распознавания лица.",
    tags: ["Банки", "Технологии", "Безопасность"],
    date: "10/01/2024",
    favorite: false,
    language: "RU",
    url: "https://tass.ru/finansy/biometria",
  ),

  Article(
    id: "4",
    title: "Криптовалюты продолжают падение на фоне мировых экономических опасений",
    source: "Ведомости",
    summary: "Курс биткойна и других основных криптовалют снизился на фоне растущей нестабильности на мировых финансовых рынках.",
    text: "Криптовалютный рынок переживает снижение цен, связанное с опасениями инвесторов из-за возможной рецессии в крупных экономиках мира.",
    tags: ["Криптовалюты", "Финансы", "Рынки"],
    date: "15/01/2024",
    favorite: false,
    language: "RU",
    url: "https://www.vedomosti.ru/finance/crypto-fall",
  ),

  Article(
    id: "5",
    title: "Россия планирует увеличить экспорт продукции IT-сектора в страны Азии",
    source: "Интерфакс",
    summary: "Российские компании IT-сектора намерены нарастить экспортные поставки программного обеспечения и технологий в азиатские страны.",
    text: "В условиях меняющегося внешнеэкономического климата российские IT-компании ищут новые рынки сбыта в странах Азии, чтобы компенсировать ограничения на Западе.",
    tags: ["Экспорт", "IT", "Азия"],
    date: "05/02/2024",
    favorite: false,
    language: "RU",
    url: "https://www.interfax.ru/business/it-export-asia",
  ),
];
