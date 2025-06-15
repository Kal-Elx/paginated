<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Paginated

<img src="https://raw.githubusercontent.com/Kal-Elx/paginated/main/assets/demo.gif" alt="Paginated Example" />

A simple, unopinionated Flutter package that adds pagination to your existing scrollable widgets. Just wrap your `ListView`, `GridView`, `SliverList`, or `SliverGrid` with `Paginated` and you're done!

## Why Paginated?

- **🎯 Unopinionated**: You manage your own state, data, and API calls
- **🔄 Simple**: Just wrap your existing scrollable widgets
- **🎨 Flexible**: Works with any state management solution
- **⚡ Lightweight**: Minimal overhead, maximum control
- **🛠️ Compatible**: Supports ListView, GridView, SliverList, and SliverGrid

Unlike other pagination packages, `Paginated` doesn't impose any architectural decisions on your app or make you use custom implementations of Lists and Grids.

## Getting Started

Add `paginated` to your `pubspec.yaml`:

```yaml
dependencies:
  paginated: ^1.0.0
```

## Basic Usage

```dart
class MyPaginatedList extends StatefulWidget {
  @override
  _MyPaginatedListState createState() => _MyPaginatedListState();
}

class _MyPaginatedListState extends State<MyPaginatedList> {
  final List<String> _items = [];
  bool _canFetchNextPage = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    try {
      final newItems = await ApiService.fetchItems();
      setState(() {
        _items.addAll(newItems);
        _canFetchNextPage = newItems.isNotEmpty;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Paginated(
      onFetchNextPage: _fetchNextPage,
      canFetchNextPage: _canFetchNextPage,
      hasError: _hasError,
      loadingBuilder: (context, index) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context) => Column(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const Text('Failed to load more items'),
          ElevatedButton(
            onPressed: () => setState(() => _hasError = false),
            child: const Text('Retry'),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_items[index]),
        ),
      ),
    );
  }
}
```

## Initial Empty State Behavior

When your scrollable widget is initially empty (itemCount == 0), the `Paginated` widget returns the child unchanged without any loading indicators. This is intentional behavior - the package will not auto-trigger an initial load when a list has no items.

**You are expected to:**
- Fetch the first page of data manually (typically in `initState` or when the screen loads)
- Handle the initial empty state with your own loading UI

This design keeps the package unopinionated and gives you full control over the initial loading experience.

## Examples for All Scrollable Types

### ListView

```dart
Paginated(
  onFetchNextPage: _fetchNextPage,
  canFetchNextPage: _canFetchNextPage,
  loadingBuilder: (context, index) => const Padding(
    padding: EdgeInsets.all(16.0),
    child: Center(child: CircularProgressIndicator()),
  ),
  child: ListView.builder(
    itemCount: _items.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(_items[index]),
    ),
  ),
)
```

### GridView

```dart
Paginated(
  onFetchNextPage: _fetchNextPage,
  canFetchNextPage: _canFetchNextPage,
  loadersCount: 2, // Show 2 loading indicators to match grid columns
  loadingBuilder: (context, index) => Card(
    child: Center(child: CircularProgressIndicator()),
  ),
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    itemCount: _items.length,
    itemBuilder: (context, index) => Card(
      child: Center(child: Text(_items[index])),
    ),
  ),
)
```

### SliverList (within CustomScrollView)

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('My App')),
    Paginated(
      onFetchNextPage: _fetchNextPage,
      canFetchNextPage: _canFetchNextPage,
      loadingBuilder: (context, index) => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListTile(title: Text(_items[index])),
          childCount: _items.length,
        ),
      ),
    ),
  ],
)
```

### SliverGrid (within CustomScrollView)

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('My App')),
    Paginated(
      onFetchNextPage: _fetchNextPage,
      canFetchNextPage: _canFetchNextPage,
      loadersCount: 3, // Match your grid's cross axis count
      loadingBuilder: (context, index) => SliverToBoxAdapter(
        child: Card(child: Center(child: CircularProgressIndicator())),
      ),
      child: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Card(child: Center(child: Text(_items[index]))),
          childCount: _items.length,
        ),
      ),
    ),
  ],
)
```

## Features

- **Zero Configuration**: No complex setup required
- **State Agnostic**: Works with setState, BLoC, Provider, Riverpod, etc.
- **Error Handling**: Customizable error handling and recovery flows
- **Customizable**: Control loading and error indicators
- **Performance**: Only renders additional items when needed
- **Sliver Support**: Full support for CustomScrollView layouts

## Common Use Cases

Perfect for implementing:

- **Infinite scrolling** in social media feeds
- **Endless loading** for image galleries and photo viewers
- **Auto-pagination** for search results and product catalogs
- **Lazy loading** for large datasets and API responses
- **Progressive loading** for news articles and blog content
- **Continuous scroll** experiences in e-commerce apps

## API Reference

### Paginated Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `child` | `Widget` | Yes | The scrollable widget to paginate (ListView, GridView, SliverList, or SliverGrid) |
| `onFetchNextPage` | `FutureOr<void> Function()` | Yes | Callback invoked to load more data |
| `canFetchNextPage` | `bool` | Yes | Whether more data can be loaded |
| `loadingBuilder` | `IndexedWidgetBuilder` | Yes | Builder for loading indicators |
| `hasError` | `bool` | No | Whether an error occurred (default: false) |
| `errorBuilder` | `WidgetBuilder?` | If `hasError` is `true` | Builder for error state (required if hasError is true) |
| `loadersCount` | `int` | No | Number of loading indicators to show (default: 1) |

## Additional Resources

- **📖 Example Project**: Check the `/example` folder for a complete example
- **🐛 Issues**: Report bugs or request features on [GitHub Issues](https://github.com/Kal-Elx/paginated/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
