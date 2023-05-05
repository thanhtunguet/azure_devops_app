part of work_item_detail;

class _HtmlWidget extends StatelessWidget {
  const _HtmlWidget({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return Html(
      data: data,
      style: {
        'div': Style.fromTextStyle(context.textTheme.labelSmall!),
        'p': Style.fromTextStyle(context.textTheme.labelSmall!),
      },
      onLinkTap: (str, _, __, ___) async {
        final url = str.toString();
        if (await canLaunchUrlString(url)) await launchUrlString(url);
      },
      customRenders: {
        (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
          widget: (ctx, child) {
            final image = CachedNetworkImage(
              imageUrl: ctx.tree.attributes['src']!,
              httpHeaders: apiService.headers,
              fit: BoxFit.contain,
              height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
              width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
              placeholder: (_, __) => Center(child: const CircularProgressIndicator()),
            );

            late OverlayEntry entry;

            void exitFullScreen() {
              entry.remove();
            }

            void goFullScreen() {
              entry = OverlayEntry(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    actions: [
                      CloseButton(
                        onPressed: exitFullScreen,
                      ),
                    ],
                  ),
                  body: InteractiveViewer(
                    child: SizedBox(
                      height: context.height,
                      width: context.width,
                      child: image,
                    ),
                  ),
                ),
              );

              Overlay.of(context).insert(entry);
            }

            return GestureDetector(
              onTap: goFullScreen,
              child: image,
            );
          },
        ),
        (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
          widget: (ctx, child) => const Text('\n'),
        ),
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.updates});

  final List<WorkItemUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final updatesToShow = updates.where((u) => u.hasSUpportedChanges);
    return Column(
      children: updatesToShow.map(
        (update) {
          final isFirst = update.rev == 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(userDescriptor: update.revisedBy.descriptor, radius: 15),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(update.revisedBy.displayName),
                  const Spacer(),
                  if (update.fields.systemChangedDate?.newValue != null)
                    Text(DateTime.tryParse(update.fields.systemChangedDate!.newValue!)!.minutesAgo),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              DefaultTextStyle(
                style: context.textTheme.labelSmall!.copyWith(
                  fontFamily: AppTheme.defaultFont,
                  fontWeight: FontWeight.w200,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirst)
                      Text(
                        'Created work item',
                      ),
                    if (update.fields.systemWorkItemType?.newValue != null)
                      Text(
                        update.fields.systemWorkItemType?.oldValue == null
                            ? 'Set type to ${update.fields.systemWorkItemType?.newValue}'
                            : 'Changed type to ${update.fields.systemWorkItemType?.newValue}',
                      ),
                    if (!isFirst && update.fields.systemState?.newValue != null)
                      Text(
                        update.fields.systemState?.oldValue == null
                            ? 'Set state to ${update.fields.systemState?.newValue}'
                            : 'Changed state to ${update.fields.systemState?.newValue}',
                      ),
                    if (update.fields.systemAssignedTo?.newValue?.displayName != null)
                      Text(
                        update.fields.systemAssignedTo?.oldValue?.displayName == null
                            ? 'Set assignee to ${update.fields.systemAssignedTo?.newValue?.displayName}'
                            : 'Changed assignee: ${update.fields.systemAssignedTo?.newValue?.displayName}',
                      ),
                    if (update.fields.microsoftVstsSchedulingEffort != null)
                      Text(
                        update.fields.microsoftVstsSchedulingEffort?.oldValue == null
                            ? 'Set effort to ${update.fields.microsoftVstsSchedulingEffort?.newValue}'
                            : 'Changed effort from ${update.fields.microsoftVstsSchedulingEffort?.oldValue} to ${update.fields.microsoftVstsSchedulingEffort?.newValue}',
                      ),
                    if (update.fields.systemHistory != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                              child: ColoredBox(
                                color: context.colorScheme.surface,
                                child: _HtmlWidget(
                                  data: update.fields.systemHistory!.newValue!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (update != updatesToShow.last) const Divider(height: 30),
            ],
          );
        },
      ).toList(),
    );
  }
}
