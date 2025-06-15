import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paginated/src/loader/paginated_loader.dart';
import 'package:paginated/src/scrollables/paginated_list_view.dart';
import 'package:paginated/src/scrollables/paginated_grid_view.dart';
import 'package:paginated/src/scrollables/paginated_sliver_list.dart';
import 'package:paginated/src/scrollables/paginated_sliver_grid.dart';

/// A widget that adds automatic pagination functionality to scrollable
/// widgets.
///
/// The [Paginated] widget wraps [ListView], [GridView], [SliverList], or
/// [SliverGrid] and automatically appends loading indicators at the end of the
/// scrollable content. When the loading indicators become visible on screen,
/// the [onFetchNextPage] callback is triggered to load additional data.
///
/// The widget preserves all original properties of the wrapped scrollable
/// and only adds the pagination behavior when [canFetchNextPage] or [hasError]
/// is true.
///
/// When the wrapped list is initially empty (itemCount == 0), the [Paginated]
/// widget returns the child unchanged without any loading indicators. This is
/// intended behavior - the package will not auto-trigger an initial load when
/// a list has no items. Applications are expected to fetch the first page of
/// data manually and handle the initial empty state with their own loading UI.
///
/// ## Example Usage:
/// ```dart
/// Paginated(
///   onFetchNextPage: () async {
///     // Fetch more data from your data source.
///   },
///   canFetchNextPage: hasMoreItems,
///   loadingBuilder: (context, index) => CircularProgressIndicator(),
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) => ListTile(title: Text(items[index])),
///   ),
/// )
/// ```
class Paginated extends StatelessWidget {
  const Paginated({
    super.key,
    required this.onFetchNextPage,
    required this.canFetchNextPage,
    this.hasError = false,
    this.loadersCount = 1,
    required this.loadingBuilder,
    this.errorBuilder,
    required this.child,
  }) : assert(
         child is ListView ||
             child is GridView ||
             child is SliverList ||
             child is SliverGrid,
         'Paginated can only wrap ListView, GridView, SliverList, or SliverGrid',
       ),
       assert(
         !hasError || errorBuilder != null,
         'errorBuilder must be provided when hasError is true',
       ),
       assert(loadersCount > 0, 'loadersCount must be greater than zero');

  /// Callback function invoked when additional data should be loaded.
  ///
  /// This function is called automatically when the first loading indicator
  /// widget becomes visible on screen. It should handle the logic for fetching
  /// additional items from your data source and updating the widget's state.
  ///
  /// Example:
  /// ```dart
  /// onFetchNextPage: () async {
  ///   final newItems = await apiService.fetchNextPage();
  ///   setState(() {
  ///     items.addAll(newItems);
  ///     canFetchNextPage = newItems.isNotEmpty;
  ///   });
  /// }
  /// ```
  final FutureOr<void> Function() onFetchNextPage;

  /// Determines whether pagination is active and more data can be loaded.
  ///
  /// When `true`, loading indicators are appended to the scrollable widget
  /// and pagination functionality is enabled. When `false`, the original
  /// widget is returned unchanged without any pagination behavior.
  ///
  /// This should typically be set to `false` when all available data has been
  /// loaded.
  final bool canFetchNextPage;

  /// Indicates whether an error occurred during the last pagination attempt.
  ///
  /// When `true`, the [errorBuilder] widget is displayed instead of loading
  /// indicators. This allows users to see that an error occurred and potentially
  /// retry the operation.
  ///
  /// When this is `true`, [errorBuilder] must not be null, otherwise an
  /// assertion error will be thrown.
  final bool hasError;

  /// The number of loading indicator widgets to display.
  ///
  /// Defaults to 1. Setting this to a higher value can be useful in e.g. grids
  /// where you want as many loading indicators as the number of columns.
  ///
  /// Must be greater than 0.
  final int loadersCount;

  /// Builder function that creates the loading indicator widgets.
  ///
  /// This function is called once for each loading indicator (determined by
  /// [loadersCount]). The [index] parameter starts from 0 and increments
  /// for each additional loader.
  ///
  /// The returned widget should provide visual feedback that data is being
  /// loaded. Common examples include [CircularProgressIndicator],
  /// [LinearProgressIndicator], or custom loading animations.
  ///
  /// Example:
  /// ```dart
  /// loadingBuilder: (context, index) => Padding(
  ///   padding: EdgeInsets.all(16.0),
  ///   child: Center(child: CircularProgressIndicator()),
  /// )
  /// ```
  final IndexedWidgetBuilder loadingBuilder;

  /// Optional builder function that creates the error indicator widget.
  ///
  /// This function is called when [hasError] is `true` to display an error
  /// state to the user. The returned widget should inform the user that
  /// an error occurred and optionally provide a way to retry the operation.
  ///
  /// This parameter is required when [hasError] is `true`, otherwise an
  /// assertion error will be thrown.
  ///
  /// Example:
  /// ```dart
  /// errorBuilder: (context) => Padding(
  ///   padding: EdgeInsets.all(16.0),
  ///   child: Column(
  ///     children: [
  ///       Icon(Icons.error, color: Colors.red),
  ///       Text('Failed to load more items'),
  ///       ElevatedButton(
  ///         onPressed: retryLoading,
  ///         child: Text('Retry'),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  final WidgetBuilder? errorBuilder;

  /// The scrollable widget to enhance with pagination functionality.
  ///
  /// Must be one of the supported scrollable widgets:
  /// - [ListView] (including ListView.builder, ListView.separated, etc.)
  /// - [GridView] (including GridView.builder, GridView.count, etc.)
  /// - [SliverList] (for use within CustomScrollView)
  /// - [SliverGrid] (for use within CustomScrollView)
  ///
  /// All original properties and behavior of the wrapped widget are preserved.
  /// The pagination functionality is added transparently by appending additional
  /// items to the widget's item count.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (child) {
      ListView listView => PaginatedListView(
        extraItemsCount: _extraItemsCount,
        extraItemBuilder: _extraItemBuilder,
        child: listView,
      ),
      GridView gridView => PaginatedGridView(
        extraItemsCount: _extraItemsCount,
        extraItemBuilder: _extraItemBuilder,
        child: gridView,
      ),
      SliverList sliverList => PaginatedSliverList(
        extraItemsCount: _extraItemsCount,
        extraItemBuilder: _extraItemBuilder,
        child: sliverList,
      ),
      SliverGrid sliverGrid => PaginatedSliverGrid(
        extraItemsCount: _extraItemsCount,
        extraItemBuilder: _extraItemBuilder,
        child: sliverGrid,
      ),
      _ => child,
    };
  }

  int get _extraItemsCount {
    if (hasError) {
      return 1;
    } else if (!canFetchNextPage) {
      return 0;
    } else if (loadersCount == 1) {
      return 1;
    } else {
      return loadersCount;
    }
  }

  Widget _extraItemBuilder(BuildContext context, int index) {
    if (hasError) {
      return errorBuilder!(context);
    } else if (index == 0) {
      return PaginatedLoader(
        onFetchNextPage: onFetchNextPage,
        child: loadingBuilder(context, index),
      );
    } else {
      return loadingBuilder(context, index);
    }
  }
}
