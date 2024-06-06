import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/widgets/app.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/utils/async_event.dart';
import 'package:rettulf/rettulf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_context_menu/super_context_menu.dart';

import '../event.dart';
import 'aggregated.dart';
import 'entity/balance.dart';
import 'i18n.dart';
import 'init.dart';
import 'widget/card.dart';
import 'widget/search.dart';

class ElectricityBalanceAppCard extends ConsumerStatefulWidget {
  const ElectricityBalanceAppCard({super.key});

  @override
  ConsumerState<ElectricityBalanceAppCard> createState() => _ElectricityBalanceAppCardState();
}

class _ElectricityBalanceAppCardState extends ConsumerState<ElectricityBalanceAppCard> {
  late final EventSubscription $refreshEvent;

  @override
  initState() {
    super.initState();
    $refreshEvent = lifeEventBus.addListener(() async {
      await refresh(active: true);
    });
    if (Settings.life.electricity.autoRefresh) {
      refresh(active: false);
    }
  }

  @override
  dispose() {
    $refreshEvent.cancel();
    super.dispose();
  }

  /// The electricity balance is refreshed approximately every 15 minutes.
  Future<void> refresh({required bool active}) async {
    final selectedRoom = Settings.life.electricity.selectedRoom;
    if (selectedRoom == null) return;
    try {
      await ElectricityAggregated.refresh(
        selectedRoom: selectedRoom,
      );
    } catch (error) {
      if (active) {
        if (!mounted) return;
        context.showSnackBar(content: i18n.refreshFailedTip.text());
      }
      return;
    }
    if (active) {
      if (!mounted) return;
      context.showSnackBar(content: i18n.refreshSuccessTip.text());
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ElectricityBalanceInit.storage;
    final lastBalance = ref.watch(storage.$lastBalance);
    final selectedRoom = ref.watch(Settings.life.electricity.$selectedRoom);
    final lastUpdateTime = ref.watch(storage.$lastUpdateTime);
    final balance = lastBalance?.roomNumber == selectedRoom ? lastBalance : null;
    final roomNumber = balance != null
        ? "#${balance.roomNumber}"
        : selectedRoom != null
            ? "#$selectedRoom"
            : null;
    return AppCard(
      view: selectedRoom != null && balance != null
          ? buildBalanceCard(
              balance: balance,
              selectedRoom: selectedRoom,
            )
          : const SizedBox.shrink(),
      title: (roomNumber == null ? i18n.title : "${i18n.title} $roomNumber").text(),
      subtitle: lastUpdateTime != null ? i18n.lastUpdateTime(context.formatMdhmNum(lastUpdateTime)).text() : null,
      leftActions: [
        FilledButton.icon(
          onPressed: () async {
            final $searchHistory = ValueNotifier(ElectricityBalanceInit.storage.searchHistory ?? const <String>[]);
            $searchHistory.addListener(() {
              ElectricityBalanceInit.storage.searchHistory = $searchHistory.value;
            });
            final room = await searchRoom(
              ctx: context,
              $searchHistory: $searchHistory,
              roomList: ElectricityBalanceInit.service.getRoomNumberCandidates(),
            );
            $searchHistory.dispose();
            if (room == null) return;
            if (Settings.life.electricity.selectedRoom != room) {
              ElectricityAggregated.selectNewRoom(room);
              await refresh(active: true);
            }
          },
          label: i18n.searchRoom.text(),
          icon: Icon(context.icons.search),
        ),
      ],
      rightActions: [
        if (balance != null && selectedRoom != null && !supportContextMenu)
          PlatformIconButton(
            material: (ctx, p) {
              return MaterialIconButtonData(
                tooltip: i18n.share,
              );
            },
            onPressed: () async {
              await shareBalance(balance: balance, selectedRoom: selectedRoom, context: context);
            },
            icon: Icon(context.icons.share),
          ),
      ],
    );
  }

  Widget buildBalanceCard({
    required ElectricityBalance balance,
    required String selectedRoom,
  }) {
    if (!supportContextMenu) {
      return Dismissible(
        direction: DismissDirection.endToStart,
        key: const ValueKey("Balance"),
        onDismissed: (dir) async {
          await HapticFeedback.heavyImpact();
          ElectricityAggregated.clearSelectedRoom();
        },
        child: buildCard(balance),
      );
    }
    return Builder(
      builder: (ctx) => ContextMenuWidget(
        menuProvider: (MenuRequest request) {
          return Menu(
            children: [
              MenuAction(
                image: MenuImage.icon(context.icons.share),
                title: i18n.share,
                callback: () async {
                  await shareBalance(balance: balance, selectedRoom: selectedRoom, context: ctx);
                },
              ),
              MenuAction(
                image: MenuImage.icon(context.icons.delete),
                title: i18n.delete,
                attributes: const MenuActionAttributes(destructive: true),
                activator: const SingleActivator(LogicalKeyboardKey.delete),
                callback: () async {
                  await HapticFeedback.heavyImpact();
                  Settings.life.electricity.selectedRoom = null;
                },
              ),
            ],
          );
        },
        child: buildCard(balance),
      ),
    );
  }

  Widget buildCard(ElectricityBalance balance) {
    return ElectricityBalanceCard(
      balance: balance,
    ).sized(h: 120);
  }
}

Future<void> shareBalance({
  required ElectricityBalance balance,
  required String selectedRoom,
  required BuildContext context,
}) async {
  final text =
      "#$selectedRoom: ${i18n.unit.rmb(balance.balance.toStringAsFixed(2))}, ${i18n.unit.powerKwh(balance.remainingPower.toStringAsFixed(2))}";
  await Share.share(
    text,
    sharePositionOrigin: context.getSharePositionOrigin(),
  );
}
