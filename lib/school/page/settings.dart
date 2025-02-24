import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/settings/settings.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class SchoolSettingsPage extends ConsumerStatefulWidget {
  const SchoolSettingsPage({
    super.key,
  });

  @override
  ConsumerState<SchoolSettingsPage> createState() => _SchoolSettingsPageState();
}

class _SchoolSettingsPageState extends ConsumerState<SchoolSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: i18n.navigation.text(),
          ),
          SliverList.list(
            children: [
              buildClass2ndAutoRefreshToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildClass2ndAutoRefreshToggle() {
    return StatefulBuilder(
      builder: (ctx, setState) => SwitchListTile.adaptive(
        secondary: Icon(context.icons.refresh),
        title: i18n.settings.class2nd.autoRefresh.text(),
        subtitle: i18n.settings.class2nd.autoRefreshDesc.text(),
        value: Settings.school.class2nd.autoRefresh,
        onChanged: (newV) {
          setState(() {
            Settings.school.class2nd.autoRefresh = newV;
          });
        },
      ),
    );
  }
}
