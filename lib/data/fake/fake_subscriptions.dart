import '../models/subscription.dart';
import '../models/subscribe_options.dart';

List<Subscription> fakeSubscriptions = [
  Subscription(
    id: 1,
    title: 'Главное о спорте',
    description: "самое важно о мире спорта",
    sources: ['Интерфакс', 'Коммерсантъ'],
    tags: ['Спорт', 'Футбол'],
    subscribeOptions: SubscribeOptions(
      subscribed: true,
      sendToMail: true,
      mobileNotifications: false,
    ),
    creationDate: '01/02/2025',
    public: true,
    owner: "abc@example.com",
    isOwner: false,
  ),
  Subscription(
    id: 2,
    title: 'Из мира еды',
    description: "самое вкусное",
    sources: ['Интерфакс', 'Коммерсантъ'],
    tags: ['IT', 'Экономика'],
    subscribeOptions: SubscribeOptions(
      subscribed: true,
      sendToMail: true,
      mobileNotifications: false,
    ),
    creationDate: '01/02/2025',
    public: false,
    owner: "someone@example.com",
    isOwner: true,
  ),
  Subscription(
    id: 3,
    title: 'Политика',
    description:
    "Another critical feature of the Smart Media Text Corpus is its annotation capability, allowing users to mark sections of articles, add notes, and categorize information.",
    sources: ['Интерфакс', 'Коммерсантъ'],
    tags: ['IT', 'Экономика'],
    subscribeOptions: SubscribeOptions(
      subscribed: true,
      sendToMail: true,
      mobileNotifications: false,
    ),
    creationDate: '01/02/2025',
    public: false,
    owner: "someone@example.com",
    isOwner: true,
  ),
  Subscription(
    id: 4,
    title: 'Экономика России',
    description: "Анализ экономической ситуации в стране",
    sources: ['РБК', 'Коммерсантъ', 'ЦБ РФ'],
    tags: ['Экономика', 'Финансы', 'Бизнес'],
    subscribeOptions: SubscribeOptions(
      subscribed: true,
      sendToMail: true,
      mobileNotifications: true,
    ),
    creationDate: '01/02/2025',
    public: true,
    owner: "economist@example.com",
    isOwner: false,
  ),
];