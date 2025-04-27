import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'digest_detail_page.dart';

class DigestSearchResultsPage extends StatefulWidget {
  const DigestSearchResultsPage({super.key});

  @override
  _DigestSearchResultsPageState createState() => _DigestSearchResultsPageState();
}

class _DigestSearchResultsPageState extends State<DigestSearchResultsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      final provider = Provider.of<DigestProvider>(context, listen: false);
      provider.loadDigests();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<DigestProvider>(context, listen: false);
    if (_shouldLoadMore(provider)) {
      provider.loadMoreDigests();
    }
  }

  bool _shouldLoadMore(DigestProvider provider) {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore &&
        !provider.isLoading;
  }

  Widget _buildDigestList(DigestProvider provider) {
    if (provider.isLoading && provider.digests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.digests.isEmpty) {
      return const Center(child: Text("Ничего не найдено"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.digests.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.digests.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildDigestCard(provider.digests[index]);
      },
    );
  }

  Widget _buildDigestCard(Digest digest) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              digest.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              digest.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(digest.date, style: const TextStyle(fontSize: 14)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DigestDetailPage(digest: digest),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Подробнее',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DigestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты поиска'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildDigestList(provider),
    );
  }
}
