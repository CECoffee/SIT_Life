import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/widgets/html.dart';
import 'package:rettulf/rettulf.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../entity/details.dart';
import '../init.dart';
import '../i18n.dart';
import '../utils.dart';
import '../widgets/activity.dart';

String _getActivityUrl(int activityId) {
  return 'http://sc.sit.edu.cn/public/activity/activityDetail.action?activityId=$activityId';
}

class Class2ndActivityDetailsPage extends StatefulWidget {
  final int activityId;
  final String? title;
  final DateTime? time;
  final bool enableApply;

  const Class2ndActivityDetailsPage({
    super.key,
    required this.activityId,
    this.title,
    this.time,
    this.enableApply = false,
  });

  @override
  State<StatefulWidget> createState() => _Class2ndActivityDetailsPageState();
}

class _Tab {
  static const length = 2;
  static const info = 0;
  static const description = 1;
}

class _Class2ndActivityDetailsPageState extends State<Class2ndActivityDetailsPage> {
  int get activityId => widget.activityId;
  late Class2ndActivityDetails? details = Class2ndInit.activityDetailsStorage.getActivityDetails(activityId);
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    if (details != null) return;
    setState(() {
      isFetching = true;
    });
    final data = await Class2ndInit.activityDetailsService.getActivityDetails(activityId);
    Class2ndInit.activityDetailsStorage.setActivityDetails(activityId, data);
    setState(() {
      details = data;
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: _Tab.length,
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  floating: true,
                  title: i18n.info.activityOf(activityId).text(),
                  actions: [
                    if (widget.enableApply)
                      PlatformTextButton(
                        child: i18n.apply.btn.text(),
                        onPressed: () async {
                          await showApplyRequest();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      onPressed: () {
                        launchUrlString(
                          _getActivityUrl(activityId),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    )
                  ],
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(child: i18n.infoTab.text()),
                      Tab(child: i18n.descriptionTab.text()),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ActivityDetailsInfoTabView(activityTitle: widget.title, activityTime: widget.time, details: details),
              ActivityDetailsDocumentTabView(details: details),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isFetching
          ? const PreferredSize(
              preferredSize: Size.fromHeight(4),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }

  Future<void> showApplyRequest() async {
    final confirm = await context.showRequest(
        title: i18n.apply.applyRequest,
        desc: i18n.apply.applyRequestDesc,
        yes: i18n.confirm,
        no: i18n.notNow,
        highlight: true);
    if (confirm == true) {
      try {
        final response = await Class2ndInit.attendActivityService.join(activityId);
        if (!mounted) return;
        await context.showTip(title: i18n.apply.replyTip, desc: response, ok: i18n.ok);
      } catch (e) {
        if (!mounted) return;
        await context.showTip(
          title: i18n.error,
          desc: e.toString(),
          ok: i18n.ok,
          serious: true,
        );
        rethrow;
      }
    }
  }

  Future<void> sendForceRequest(BuildContext context) async {
    try {
      final response = await Class2ndInit.attendActivityService.join(activityId, force: true);
      if (!mounted) return;
      context.showSnackBar(content: Text(response));
    } catch (e) {
      context.showSnackBar(content: Text('错误: ${e.runtimeType}'), duration: const Duration(seconds: 3));
      rethrow;
    }
  }
}

class ActivityDetailsInfoTabView extends StatefulWidget {
  final String? activityTitle;
  final DateTime? activityTime;
  final Class2ndActivityDetails? details;

  const ActivityDetailsInfoTabView({
    super.key,
    this.activityTitle,
    this.activityTime,
    this.details,
  });

  @override
  State<ActivityDetailsInfoTabView> createState() => _ActivityDetailsInfoTabViewState();
}

class _ActivityDetailsInfoTabViewState extends State<ActivityDetailsInfoTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final details = widget.details;
    final (:title, :tags) = separateTagsFromTitle(widget.activityTitle ?? details?.title ?? "");
    final time = details?.startTime ?? widget.activityTime;
    return SelectionArea(
      child: CustomScrollView(
        slivers: [
          SliverList.list(children: [
            ListTile(
              title: i18n.info.name.text(),
              subtitle: title.text(),
              visualDensity: VisualDensity.compact,
            ),
            if (time != null)
              ListTile(
                title: i18n.info.startTime.text(),
                subtitle: context.formatYmdhmNum(time).text(),
                visualDensity: VisualDensity.compact,
              ),
            if (details != null) ...[
              if (details.place != null)
                ListTile(
                  title: i18n.info.location.text(),
                  subtitle: details.place!.text(),
                  visualDensity: VisualDensity.compact,
                ),
              if (details.principal != null)
                ListTile(
                  title: i18n.info.principal.text(),
                  subtitle: details.principal!.text(),
                  visualDensity: VisualDensity.compact,
                ),
              if (details.organizer != null)
                ListTile(
                  title: i18n.info.organizer.text(),
                  subtitle: details.organizer!.text(),
                  visualDensity: VisualDensity.compact,
                ),
              if (details.undertaker != null)
                ListTile(
                  title: i18n.info.undertaker.text(),
                  subtitle: details.undertaker!.text(),
                  visualDensity: VisualDensity.compact,
                ),
              if (details.contactInfo != null)
                ListTile(
                  title: i18n.info.contactInfo.text(),
                  subtitle: details.contactInfo!.text(),
                  visualDensity: VisualDensity.compact,
                ),
              if (tags.isNotEmpty)
                ListTile(
                  isThreeLine: true,
                  title: i18n.info.tags.text(),
                  subtitle: ActivityTagsGroup(tags),
                  visualDensity: VisualDensity.compact,
                ),
              ListTile(
                title: i18n.info.signInTime.text(),
                subtitle: context.formatYmdhmNum(details.signStartTime).text(),
                visualDensity: VisualDensity.compact,
              ),
              ListTile(
                title: i18n.info.signOutTime.text(),
                subtitle: context.formatYmdhmNum(details.signEndTime).text(),
                visualDensity: VisualDensity.compact,
              ),
              if (details.duration != null)
                ListTile(
                  title: i18n.info.duration.text(),
                  subtitle: details.duration!.text(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ]),
        ],
      ),
    );
  }
}

class ActivityDetailsDocumentTabView extends StatefulWidget {
  final Class2ndActivityDetails? details;

  const ActivityDetailsDocumentTabView({
    super.key,
    this.details,
  });

  @override
  State<ActivityDetailsDocumentTabView> createState() => _ActivityDetailsDocumentTabViewState();
}

class _ActivityDetailsDocumentTabViewState extends State<ActivityDetailsDocumentTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final description = widget.details?.description;
    return SelectionArea(
      child: CustomScrollView(
        slivers: [
          if (description == null)
            SliverToBoxAdapter(child: i18n.noDetails.text(style: context.textTheme.titleLarge))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: RestyledHtmlWidget(description, renderMode: RenderMode.sliverList),
            )
        ],
      ),
    );
  }
}