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
        child: IndexedStack(index: tabIndex, children: pages),
      ),
    );
  }
}
