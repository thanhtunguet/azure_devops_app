part of pull_request_detail;

class _PullRequestDetailScreen extends StatelessWidget {
  const _PullRequestDetailScreen(this.ctrl, this.parameters);

  final _PullRequestDetailController ctrl;
  final _PullRequestDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (ctx) => AppPage<PullRequestWithDetails?>(
          init: ctrl.init,
          dispose: ctrl.dispose,
          title: 'Pull request',
          notifier: ctrl.prDetail,
          header: () => TabBar(
            onTap: (i) => ctrl.selectPage(i, DefaultTabController.of(ctx)),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Changed files'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: ctrl.sharePr,
              icon: Icon(DevOpsIcons.share),
            ),
          ],
          builder: (prWithDetails) => ValueListenableBuilder(
            valueListenable: ctrl.visiblePage,
            builder: (context, visiblePage, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _PageTabs(
                  ctrl: ctrl,
                  visiblePage: visiblePage,
                  prWithDetails: prWithDetails!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
