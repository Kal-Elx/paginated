import 'package:flutter/material.dart';
import 'package:paginated/paginated.dart';

void main() {
  runApp(const PaginatedExampleApp());
}

class PaginatedExampleApp extends StatelessWidget {
  const PaginatedExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paginated Example',
      home: const PaginatedExample(),
    );
  }
}

class PaginatedExample extends StatefulWidget {
  const PaginatedExample({super.key});

  @override
  State<PaginatedExample> createState() => _PaginatedExampleState();
}

class _PaginatedExampleState extends State<PaginatedExample> {
  final List<String> _items = [];
  bool _canFetchNextPage = true;
  bool _hasError = false;
  bool _isFetchingNextPage = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final newItems = await MockApiService.fetchItems(_currentPage);
    setState(() {
      _items.addAll(newItems);
      _currentPage++;
    });
  }

  Future<void> _fetchNextPage() async {
    if (_isFetchingNextPage) return;

    try {
      setState(() {
        _hasError = false;
        _isFetchingNextPage = true;
      });

      final newItems = await MockApiService.fetchItems(_currentPage);

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _canFetchNextPage = newItems.isNotEmpty;
        _isFetchingNextPage = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isFetchingNextPage = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
    });
    _fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Paginated(
        onFetchNextPage: _fetchNextPage,
        canFetchNextPage: _canFetchNextPage,
        hasError: _hasError,
        loadingBuilder: (context, index) => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              const Text('Failed to load more items'),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _retry, child: const Text('Retry')),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_items[index]),
              subtitle: Text('Item ${index + 1}'),
            );
          },
        ),
      ),
    );
  }
}

class MockApiService {
  static const int _itemsPerPage = 20;
  static const int _maxPages = 5;

  static Future<List<String>> fetchItems(int page) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate occasional errors (10% chance)
    if (page > 0 && DateTime.now().millisecond % 10 == 0) {
      throw Exception('Network error');
    }

    // Return empty list after max pages to simulate end of data
    if (page >= _maxPages) {
      return [];
    }

    // Generate mock items for this page
    return List.generate(_itemsPerPage, (index) {
      final itemNumber = page * _itemsPerPage + index + 1;
      return 'Item $itemNumber from page ${page + 1}';
    });
  }
}
