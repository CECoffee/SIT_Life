import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/editor.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/network/checker.dart';
import 'package:sit/qrcode/page/view.dart';
import 'package:sit/qrcode/protocol.dart';
import 'package:sit/settings/settings.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class ProxySettingsPage extends StatefulWidget {
  const ProxySettingsPage({
    super.key,
  });

  @override
  State<ProxySettingsPage> createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              title: i18n.proxy.title.text(style: context.textTheme.headlineSmall),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              buildEnableProxyToggle(),
              buildGlobalModeSwitcher(),
              buildProxyTypeTile(
                ProxyType.http,
                icon: const Icon(Icons.http),
              ),
              buildProxyTypeTile(
                ProxyType.https,
                icon: const Icon(Icons.https),
              ),
              buildProxyTypeTile(
                ProxyType.all,
                icon: const Icon(Icons.public),
              ),
              const Divider(),
              const TestConnectionTile(),
              const ProxyShareQrCodeTile(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildProxyTypeTile(ProxyType type, {
    required Widget icon,
  }) {
    return ListTile(
      leading: icon,
      title: type.l10n().text(),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        final profile = await context.show$Sheet$<ProxyProfileRecords>((ctx) => ProxyProfileEditorPage(type: type));
        if (profile != null) {
          Settings.proxy.setProfile(type, profile);
        }
      },
    );
  }

  Widget buildEnableProxyToggle() {
    return Settings.proxy.listenAnyEnabled() >>
            (ctx) =>
            _EnableProxyToggleTile(
              enabled: Settings.proxy.anyEnabled,
              onChanged: (newV) {
                setState(() {
                  Settings.proxy.anyEnabled = newV;
                });
              },
            );
  }

  Widget buildGlobalModeSwitcher() {
    return Settings.proxy.listenGlobalMode() >> (ctx) =>
        _GlobalModeSwitcherTile(
          globalMode: Settings.proxy.anyGlobalMode,
          onChanged: (value) {
            setState(() {
              Settings.proxy.anyGlobalMode = true;
            });
          },
        );
  }
}

class ProxyShareQrCodeTile extends StatelessWidget {
  final String? http;
  final String? https;
  final String? all;

  const ProxyShareQrCodeTile({
    super.key,
    this.http,
    this.https,
    this.all,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.qr_code),
      title: i18n.proxy.shareQrCode.text(),
      subtitle: i18n.proxy.shareQrCodeDesc.text(),
      trailing: IconButton(
        icon: const Icon(Icons.share),
        onPressed: () async {
          final qrCodeData = const ProxyDeepLink().encode(
            http: http,
            https: https,
            all: all,
          );
          context.show$Sheet$(
                (context) =>
                QrCodePage(
                  title: i18n.proxy.title.text(),
                  data: qrCodeData.toString(),
                ),
          );
        },
      ),
    );
  }
}

Future<void> onProxyFromQrCode({
  required BuildContext context,
  required Uri? http,
  required Uri? https,
  required Uri? all,
}) async {
  if (http != null) {
    Settings.proxy
        .resolve(ProxyType.http)
        .address = http.toString();
  }
  if (https != null) {
    Settings.proxy
        .resolve(ProxyType.https)
        .address = https.toString();
  }
  if (http != null) {
    Settings.proxy
        .resolve(ProxyType.all)
        .address = all.toString();
  }
  await HapticFeedback.mediumImpact();
  if (!context.mounted) return;
  context.showSnackBar(content: i18n.proxy.proxyChangedTip.text());
  context.push("/settings/proxy");
}

class ProxyProfileEditorPage extends StatefulWidget {
  final ProxyType type;

  const ProxyProfileEditorPage({
    super.key,
    required this.type,
  });

  @override
  State<ProxyProfileEditorPage> createState() => _ProxyProfileEditorPageState();
}

class _ProxyProfileEditorPageState extends State<ProxyProfileEditorPage> {
  late final profile = Settings.proxy.resolve(widget.type);
  late var address = (profile.address == null ? null : Uri.tryParse(profile.address!)) ?? buildDefaultUri();
  late var enabled = profile.enabled;
  late var globalMode = profile.globalMode;

  ProxyType get type => widget.type;

  @override
  void initState() {
    super.initState();
  }

  Uri buildDefaultUri() {
    return Uri(scheme: type.defaultProtocol, host: type.defaultHost, port: type.defaultPort);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: widget.type.l10n().text(),
            actions: [
              buildSaveAction(),
            ],
          ),
          SliverList.list(children: [
            buildEnableProxyToggle(),
            buildProxyModeSwitcher(),
            buildProxyFullTile(),
            const Divider(),
            buildProxyProtocolTile(),
            buildProxyHostTile(),
            buildProxyPortTile(),
            buildProxyAuthTile(),
          ]),
        ],
      ),
    );
  }

  Widget buildSaveAction() {
    return PlatformTextButton(
      child: i18n.save.text(),
      onPressed: () {
        context.pop((address: address.toString(), enabled: enabled, globalMode: globalMode));
      },
    );
  }

  Widget buildProxyFullTile() {
    final address = this.address;
    return ListTile(
      leading: const Icon(Icons.link),
      title: i18n.proxy.title.text(),
      subtitle: address.toString().text(),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: address.toString()));
        if (!mounted) return;
        context.showSnackBar(content: i18n.copyTipOf(i18n.proxy.title).text());
      },
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final newFullProxy = await Editor.showStringEditor(
            context,
            desc: i18n.proxy.title,
            initial: address.toString(),
          );
          if (newFullProxy == null) return;
          final newUri = Uri.tryParse(newFullProxy.trim());
          if (newUri == null || !newUri.isAbsolute || !type.supportedProtocols.contains(newUri.scheme)) {
            if (!mounted) return;
            context.showTip(
              title: i18n.error,
              desc: i18n.proxy.invalidProxyFormatTip,
              ok: i18n.close,
            );
            return;
          }
          if (newUri != address) {
            setState(() {
              this.address = newUri;
            });
          }
        },
      ),
    );
  }

  Widget buildProxyProtocolTile() {
    final scheme = address.scheme;
    return ListTile(
      isThreeLine: true,
      leading: const Icon(Icons.https),
      title: i18n.proxy.protocol.text(),
      subtitle: type.supportedProtocols
          .map((protocol) =>
          ChoiceChip(
            label: protocol.toUpperCase().text(),
            selected: protocol == scheme,
            onSelected: (value) {
              setState(() {
                address = address.replace(
                  scheme: protocol,
                );
              });
            },
          ))
          .toList()
          .wrap(spacing: 4),
    );
  }

  Widget buildProxyHostTile() {
    final host = address.host;
    return ListTile(
      leading: const Icon(Icons.link),
      title: i18n.proxy.hostname.text(),
      subtitle: host.text(),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: host));
        if (!mounted) return;
        context.showSnackBar(content: i18n.copyTipOf(i18n.proxy.hostname).text());
      },
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final newHostRaw = await Editor.showStringEditor(
            context,
            desc: i18n.proxy.hostname,
            initial: host,
          );
          if (newHostRaw == null) return;
          final newHost = newHostRaw.trim();
          if (newHost != host) {
            setState(() {
              address = address.replace(
                host: newHost,
              );
            });
          }
        },
      ),
    );
  }

  Widget buildProxyPortTile() {
    int port = address.port;
    return ListTile(
      leading: const Icon(Icons.settings_input_component_outlined),
      title: i18n.proxy.port.text(),
      subtitle: port.toString().text(),
      onLongPress: () async {
        await Clipboard.setData(ClipboardData(text: port.toString()));
        if (!mounted) return;
        context.showSnackBar(content: i18n.copyTipOf(i18n.proxy.port).text());
      },
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final newPort = await Editor.showIntEditor(
            context,
            desc: i18n.proxy.port,
            initial: port,
          );
          if (newPort == null) return;
          if (newPort != port) {
            address = address.replace(
              port: newPort,
            );
          }
        },
      ),
    );
  }

  Widget buildProxyAuthTile() {
    final userInfoParts = address.userInfo.split(":");
    final auth = userInfoParts.length == 2 ? (username: userInfoParts[0], password: userInfoParts[1]) : null;
    final text = auth != null ? "${auth.username}:${auth.password}" : null;
    return ListTile(
      leading: const Icon(Icons.key),
      title: i18n.proxy.authentication.text(),
      subtitle: text?.text(),
      trailing: [
        if (auth != null)
          IconButton(
            onPressed: () {
              setState(() {
                address = address.replace(userInfo: "");
              });
            },
            icon: const Icon(Icons.delete),
          ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final newAuth = await showAdaptiveDialog<({String username, String password})>(
              context: context,
              builder: (_) =>
                  StringsEditor(
                    fields: [
                      (name: "username", initial: auth?.username ?? ""),
                      (name: "password", initial: auth?.password ?? ""),
                    ],
                    title: i18n.proxy.authentication,
                    ctor: (values) => (username: values[0].trim(), password: values[1].trim()),
                  ),
            );
            if (newAuth != null && newAuth != auth) {
              setState(() {
                address = address.replace(
                    userInfo:
                    newAuth.password.isNotEmpty ? "${newAuth.username}:${newAuth.password}" : newAuth.username);
              });
            }
          },
        ),
      ].wrap(),
    );
  }

  Widget buildEnableProxyToggle() {
    return _EnableProxyToggleTile(
      enabled: enabled,
      onChanged: (newV) {
        setState(() {
          enabled = newV;
        });
      },
    );
  }

  Widget buildProxyModeSwitcher() {
    return _GlobalModeSwitcherTile(
      globalMode: globalMode,
      onChanged: (value) {
        setState(() {
          globalMode = value;
        });
      },
    );
  }
}

class _EnableProxyToggleTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _EnableProxyToggleTile({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: i18n.proxy.enableProxy.text(),
      subtitle: i18n.proxy.enableProxyDesc.text(),
      leading: const Icon(Icons.vpn_key),
      trailing: Switch.adaptive(
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _GlobalModeSwitcherTile extends StatelessWidget {
  final bool? globalMode;
  final ValueChanged<bool> onChanged;

  const _GlobalModeSwitcherTile({
    super.key,
    required this.globalMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: const Icon(Icons.public),
      title: i18n.proxy.proxyMode.text(),
      subtitle: [
        ChoiceChip(
          label: i18n.proxy.proxyModeGlobal.text(),
          selected: globalMode == true,
          onSelected: (value) {
            onChanged(true);
          },
        ),
        ChoiceChip(
          label: i18n.proxy.proxyModeSchool.text(),
          selected: globalMode == false,
          onSelected: (value) {
            onChanged(false);
          },
        ),
      ].wrap(spacing: 4),
      trailing: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        message: buildTooltip(),
        child: const Icon(Icons.info_outline),
      ).padAll(8),
    );
  }

  String buildTooltip() {
    return switch(globalMode){
      true => i18n.proxy.proxyModeGlobalTip,
      false => i18n.proxy.proxyModeSchoolTip,
      null => "?"
    };
  }
}
