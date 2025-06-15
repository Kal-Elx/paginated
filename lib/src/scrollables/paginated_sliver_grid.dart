import 'package:flutter/widgets.dart';

class PaginatedSliverGrid extends StatelessWidget {
  const PaginatedSliverGrid({
    super.key,
    required this.extraItemsCount,
    required this.extraItemBuilder,
    required this.child,
  });

  final int extraItemsCount;
  final IndexedWidgetBuilder extraItemBuilder;
  final SliverGrid child;

  @override
  Widget build(BuildContext context) {
    if (child.delegate is! SliverChildBuilderDelegate) {
      throw Exception(
        'Paginated works only with a SliverChildBuilderDelegate.',
      );
    }

    final delegate = child.delegate as SliverChildBuilderDelegate;

    if (delegate.estimatedChildCount == 0) {
      return child;
    }

    final itemCount = delegate.estimatedChildCount ?? 0;
    final childCount = itemCount + extraItemsCount;

    return SliverGrid(
      key: child.key,
      delegate: SliverChildBuilderDelegate(
        (context, index) => index < itemCount
            ? delegate.builder(context, index)
            : extraItemBuilder(context, index - itemCount),
        findChildIndexCallback: delegate.findChildIndexCallback,
        childCount: childCount,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        semanticIndexOffset: delegate.semanticIndexOffset,
        semanticIndexCallback: delegate.semanticIndexCallback,
      ),
      gridDelegate: child.gridDelegate,
    );
  }
}
