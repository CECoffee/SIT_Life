import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/design/adaptive/editor.dart';
import 'package:sit/init.dart';
import 'package:sit/login/aggregated.dart';
import 'package:sit/login/utils.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/settings/widgets/navigation.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class DeveloperOptionsPage extends StatefulWidget {
  const DeveloperOptionsPage({
    super.key,
  });

  @override
  State<DeveloperOptionsPage> createState() => _DeveloperOptionsPageState();
}

class _DeveloperOptionsPageState extends State<DeveloperOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              title: i18n.dev.title.text(style: context.textTheme.headlineSmall),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              buildDevModeToggle(),
              PageNavigationTile(
                title: i18n.dev.localStorage.text(),
                subtitle: i18n.dev.localStorageDesc.text(),
                icon: const Icon(Icons.storage),
                path: "/settings/developer/local-storage",
              ),
              buildReload(),
              const SwitchAccountTile(),
              const DebugGoRouteTile(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildDevModeToggle() {
    return StatefulBuilder(
      builder: (ctx, setState) => ListTile(
        title: i18n.dev.devMode.text(),
        leading: const Icon(Icons.developer_mode_outlined),
        trailing: Switch.adaptive(
          value: Settings.isDeveloperMode,
          onChanged: (newV) {
            setState(() {
              Settings.isDeveloperMode = newV;
            });
          },
        ),
      ),
    );
  }

  Widget buildReload() {
    return ListTile(
      title: i18n.dev.reload.text(),
      subtitle: i18n.dev.reloadDesc.text(),
      leading: const Icon(Icons.refresh_rounded),
      onTap: () async {
        await Init.initNetwork();
        await Init.initModules();
        final engine = WidgetsFlutterBinding.ensureInitialized();
        engine.performReassemble();
        if (!mounted) return;
        context.navigator.pop();
      },
    );
  }
}

class DebugGoRouteTile extends StatefulWidget {
  const DebugGoRouteTile({super.key});

  @override
  State<DebugGoRouteTile> createState() => _DebugGoRouteTileState();
}

class _DebugGoRouteTileState extends State<DebugGoRouteTile> {
  final $route = TextEditingController();

  @override
  void dispose() {
    $route.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: i18n
    return ListTile(
      isThreeLine: true,
      leading: const Icon(Icons.route_outlined),
      title: "Go route".text(),
      subtitle: TextField(
        controller: $route,
        decoration: const InputDecoration(
          hintText: "/anywhere",
        ),
      ),
      trailing: [
        $route >>
            (ctx, route) => IconButton(
                onPressed: route.text.isEmpty
                    ? null
                    : () {
                        context.push(route.text);
                      },
                icon: const Icon(Icons.arrow_forward))
      ].row(mas: MainAxisSize.min),
    );
  }
}

class SwitchAccountTile extends StatefulWidget {
  const SwitchAccountTile({super.key});

  @override
  State<SwitchAccountTile> createState() => _SwitchAccountTileState();
}

class _SwitchAccountTileState extends State<SwitchAccountTile> {
  bool isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: "Switch account".text(),
      subtitle: "Without logging out".text(),
      leading: const Icon(Icons.swap_horiz),
      trailing: Padding(
        padding: const EdgeInsets.all(8),
        child: isLoggingIn ? const CircularProgressIndicator.adaptive() : null,
      ),
      onTap: () async {
        final credentials = await await Editor.showAnyEditor(
          context,
          Credentials(account: "", password: ""),
        );
        if (credentials == null) return;
        setState(() => isLoggingIn = true);
        try {
          await Init.cookieJar.deleteAll();
          await LoginAggregated.login(credentials);
          if (!mounted) return;
          setState(() => isLoggingIn = false);
          context.go("/");
        } on Exception catch (error, stackTrace) {
          if (!mounted) return;
          setState(() => isLoggingIn = false);
          await handleLoginException(context: context, error: error, stackTrace: stackTrace);
        }
      },
    );
  }
}
