import 'package:flutter/widgets.dart';

class PaginatedListView extends StatelessWidget {
  const PaginatedListView({
    super.key,
    required this.extraItemsCount,
    required this.extraItemBuilder,
    required this.child,
  });

  final int extraItemsCount;
  final IndexedWidgetBuilder extraItemBuilder;
  final ListView child;

  @override
  Widget build(BuildContext context) {
    if (child.childrenDelegate is! SliverChildBuilderDelegate) {
      throw Exception(
        'Paginated works only with builder-based ListViews (e.g. '
        'ListView.builder). Use a builder constructor or switch to a '
        'SliverList with a SliverChildBuilderDelegate.',
      );
    }

    final delegate = child.childrenDelegate as SliverChildBuilderDelegate;

    if (delegate.estimatedChildCount == 0) {
      return child;
    }

    final itemCount = delegate.estimatedChildCount ?? 0;
    final childCount = itemCount + extraItemsCount;

    return ListView.custom(
      key: child.key,
      scrollDirection: child.scrollDirection,
      reverse: child.reverse,
      controller: child.controller,
      primary: child.primary,
      physics: child.physics,
      shrinkWrap: child.shrinkWrap,
      padding: child.padding,
      itemExtent: child.itemExtent,
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
