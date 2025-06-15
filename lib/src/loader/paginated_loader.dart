import 'dart:async';

import 'package:flutter/widgets.dart';

class PaginatedLoader extends StatefulWidget {
  const PaginatedLoader({
    super.key,
    required this.onFetchNextPage,
    required this.child,
  });

  final FutureOr<void> Function() onFetchNextPage;
  final Widget child;

  @override
  State<PaginatedLoader> createState() => _PaginatedLoaderState();
}

class _PaginatedLoaderState extends State<PaginatedLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onFetchNextPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
