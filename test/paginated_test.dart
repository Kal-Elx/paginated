import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paginated/paginated.dart';

class TestFetcher {
  int calls = 0;
  Future<void> fetch() async {
    calls += 1;
    await Future<void>.delayed(Duration.zero);
  }
}

Widget _loader(BuildContext _, int i) => SizedBox(
  key: Key('loader$i'),
  height: 40,
  child: Center(child: Text('Loading$i')),
);

Widget _error(BuildContext _) =>
    const Center(key: Key('error'), child: Text('Error'));

Future<void> _pumpPaginated(
  WidgetTester tester, {
  required TestFetcher fetcher,
  required Widget child,
  bool hasError = false,
  int loaders = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Paginated(
          onFetchNextPage: fetcher.fetch,
          canFetchNextPage: true,
          hasError: hasError,
          loadersCount: loaders,
          loadingBuilder: _loader,
          errorBuilder: hasError ? _error : null,
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollUntil(
  WidgetTester tester, {
  required Finder scrollable,
  required Finder target,
}) async {
  for (var i = 0; i < 30 && !tester.any(target); i++) {
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
  }
  expect(target, findsOneWidget);
}

void main() {
  late TestFetcher fetcher;

  setUp(() => fetcher = TestFetcher());

  group('Paginated', () {
    testWidgets('pagination once for ListView', (tester) async {
      await _pumpPaginated(
        tester,
        fetcher: fetcher,
        child: ListView.builder(
          itemCount: 50,
          itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
        ),
      );

      await _scrollUntil(
        tester,
        scrollable: find.byType(ListView),
        target: find.byKey(const Key('loader0')),
      );
      expect(fetcher.calls, 1);
    });

    testWidgets('pagination once for GridView', (tester) async {
      await _pumpPaginated(
        tester,
        fetcher: fetcher,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: 60,
          itemBuilder: (_, i) => Center(child: Text('Tile $i')),
        ),
      );

      await _scrollUntil(
        tester,
        scrollable: find.byType(GridView),
        target: find.byKey(const Key('loader0')),
      );
      expect(fetcher.calls, 1);
    });

    testWidgets('pagination once for SliverList', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                Paginated(
                  onFetchNextPage: fetcher.fetch,
                  canFetchNextPage: true,
                  hasError: false,
                  loadersCount: 1,
                  loadingBuilder: _loader,
                  errorBuilder: null,
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ListTile(title: Text('Row $i')),
                      childCount: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollUntil(
        tester,
        scrollable: find.byType(CustomScrollView),
        target: find.byKey(const Key('loader0')),
      );
      expect(fetcher.calls, 1);
    });

    testWidgets('pagination once for SliverGrid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                Paginated(
                  onFetchNextPage: fetcher.fetch,
                  canFetchNextPage: true,
                  hasError: false,
                  loadersCount: 1,
                  loadingBuilder: _loader,
                  errorBuilder: null,
                  child: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Center(child: Text('Cell $i')),
                      childCount: 75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollUntil(
        tester,
        scrollable: find.byType(CustomScrollView),
        target: find.byKey(const Key('loader0')),
      );
      expect(fetcher.calls, 1);
    });

    testWidgets('shows errorBuilder', (tester) async {
      await _pumpPaginated(
        tester,
        fetcher: fetcher,
        hasError: true,
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
        ),
      );

      expect(find.byKey(const Key('error')), findsOneWidget);
      expect(find.byKey(const Key('loader0')), findsNothing);
      expect(fetcher.calls, 0);
    });

    testWidgets('renders multiple loaders', (tester) async {
      const loaders = 3;
      await _pumpPaginated(
        tester,
        fetcher: fetcher,
        loaders: loaders,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: loaders,
          ),
          itemCount: 9,
          itemBuilder: (_, i) => Center(child: Text('Grid $i')),
        ),
      );

      await _scrollUntil(
        tester,
        scrollable: find.byType(GridView),
        target: find.byKey(Key('loader${loaders - 1}')),
      );

      for (var i = 0; i < loaders; i++) {
        expect(find.byKey(Key('loader$i')), findsOneWidget);
      }
      expect(fetcher.calls, 1);
    });
  });
}
