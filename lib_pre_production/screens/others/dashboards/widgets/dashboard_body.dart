import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';

class DashboardBody extends ConsumerWidget {
  const DashboardBody({
    super.key,
    required this.pages,
    required this.bucket,
    required this.onWillPop,
  });

  final List<Widget> pages;
  final PageStorageBucket bucket;
  final Future<bool> Function() onWillPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(tabIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await onWillPop();
      },
      child: PageStorage(
        bucket: bucket,
        child: _LazyIndexedStack(index: tabIndex, children: pages),
      ),
    );
  }
}

/// Behaves like IndexedStack (keeps visited pages alive so state/scroll
/// position persists across tab switches) but avoids laying out pages
/// that haven't been visited yet.
///
/// Plain IndexedStack calls layout() on every child on every rebuild,
/// even the ones that aren't visible — so every tab tap was paying the
/// full layout cost of all 5 dashboard pages, not just the one being
/// switched to. This only lays out a page the first time its tab is
/// opened; after that it's kept mounted like a normal IndexedStack.
class _LazyIndexedStack extends StatefulWidget {
  const _LazyIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final Set<int> _visited = {widget.index};

  @override
  void didUpdateWidget(_LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _visited.add(widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _visited.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}
