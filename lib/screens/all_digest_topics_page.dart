import 'package:flutter/material.dart';

class AllDigestTopicsPage extends StatefulWidget {
  const AllDigestTopicsPage({super.key});

  @override
  _AllDigestTopicsPageState createState() => _AllDigestTopicsPageState();
}

class _AllDigestTopicsPageState extends State<AllDigestTopicsPage> {
  bool _showOnlySubscriptions = false;

  final List<Map<String, dynamic>> _fakeTopics = List.generate(
    15,
        (index) => {
      "title": "Тема $index",
      "isSubscribed": index % 3 == 0,
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Темы дайджестов')),
      body: Column(
        children: [
          // Кнопка "Только подписки"
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("Только подписки"),
                  selected: _showOnlySubscriptions,
                  onSelected: (bool selected) {
                    setState(() {
                      _showOnlySubscriptions = selected;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _fakeTopics.length,
              itemBuilder: (context, index) {
                final topic = _fakeTopics[index];

                if (_showOnlySubscriptions && !topic["isSubscribed"]) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.category, color: Colors.white),
                  ),
                  title: Text(topic["title"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(topic["isSubscribed"] ? Icons.notifications_active : Icons.notifications_none),
                        onPressed: () {
                          setState(() {
                            topic["isSubscribed"] = !topic["isSubscribed"];
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Добавлен в избранное: ${topic["title"]}")),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}