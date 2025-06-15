import 'package:flutter/widgets.dart';

class PaginatedGridView extends StatelessWidget {
  const PaginatedGridView({
    super.key,
    required this.extraItemsCount,
    required this.extraItemBuilder,
    required this.child,
  });

  final int extraItemsCount;
  final IndexedWidgetBuilder extraItemBuilder;
  final GridView child;

  @override
  Widget build(BuildContext context) {
    if (child.childrenDelegate is! SliverChildBuilderDelegate) {
      throw Exception(
        'Paginated works only with builder-based GridViews (e.g. '
        'GridView.builder). Use a builder constructor or switch to a '
        'SliverGrid with a SliverChildBuilderDelegate.',
      );
    }

    final delegate = child.childrenDelegate as SliverChildBuilderDelegate;

    if (delegate.estimatedChildCount == 0) {
      return child;
    }

    final itemCount = delegate.estimatedChildCount ?? 0;
    final childCount = itemCount + extraItemsCount;

    return GridView.custom(
      key: child.key,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      controller: child.controller,
      primary: child.primary,
      physics: child.physics,
      shrinkWrap: child.shrinkWrap,
      padding: child.padding,
      gridDelegate: child.gridDelegate,
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => index < itemCount
            ? delegate.builder(context, index)
            : extraItemBuilder(context, index - itemCount),
        childCount: childCount,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        findChildIndexCallback: delegate.findChildIndexCallback,
        semanticIndexOffset: delegate.semanticIndexOffset,
        semanticIndexCallback: delegate.semanticIndexCallback,
      ),
      cacheExtent: child.cacheExtent,
      semanticChildCount: child.semanticChildCount,
      dragStartBehavior: child.dragStartBehavior,
      keyboardDismissBehavior: child.keyboardDismissBehavior,
      restorationId: child.restorationId,
      clipBehavior: child.clipBehavior,
      hitTestBehavior: child.hitTestBehavior,
    );
  }
}
