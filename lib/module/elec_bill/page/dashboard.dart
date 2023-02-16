import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/account.dart';
import '../init.dart';
import '../widgets/card.dart';
import '../using.dart';

class Dashboard extends StatefulWidget {
  final String selectedRoom;

  const Dashboard({super.key, required this.selectedRoom});

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with AutomaticKeepAliveClientMixin {
  final service = ElectricityBillInit.electricityService;
  final updateTimeFormatter = DateFormat('MM/dd HH:mm');
  Balance? _balance;
  final _scrollController = ScrollController();
  final _portraitRefreshController = RefreshController();
  final _landscapeRefreshController = RefreshController();

  RefreshController getCurrentRefreshController(BuildContext ctx) =>
      ctx.isPortrait ? _portraitRefreshController : _landscapeRefreshController;

  Future<List> getRoomList() async {
    String jsonData = await rootBundle.loadString("assets/roomlist.json");
    List list = await jsonDecode(jsonData);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _portraitRefreshController.dispose();
    _landscapeRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return context.isPortrait ? buildPortrait(context) : buildLandscape(context);
  }

  Widget buildPortrait(BuildContext context) {
    return SmartRefresher(
      controller: _portraitRefreshController,
      scrollDirection: Axis.vertical,
      onRefresh: _onRefresh,
      header: const ClassicHeader(),
      scrollController: _scrollController,
      child: buildBodyPortrait(context),
    );
  }

  Widget buildLandscape(BuildContext context) {
    return SmartRefresher(
      controller: _landscapeRefreshController,
      scrollDirection: Axis.vertical,
      onRefresh: _onRefresh,
      header: const ClassicHeader(),
      scrollController: _scrollController,
      child: buildBodyLandscape(context),
    ).padAll(10);
  }

  Future<void> _onRefresh() async {
    final selectedRoom = widget.selectedRoom;
    setState(() {
      _balance = null;
    });
    final newBalance = await service.getBalance(selectedRoom);
    setState(() {
      _balance = newBalance;
    });
    if (!mounted) return;
    getCurrentRefreshController(context).refreshCompleted();
  }

  Widget buildBodyPortrait(BuildContext ctx) {
    return [
      const SizedBox(height: 5),
      buildBalanceCard(ctx),
      const SizedBox(height: 5),
    ].column().scrolled().padSymmetric(v: 8, h: 20);
  }

  Widget buildBodyLandscape(BuildContext ctx) {
    return [
      [
        i18n.title(widget.selectedRoom).text(style: ctx.textTheme.displayLarge).padFromLTRB(10, 0, 10, 40),
        const SizedBox(height: 5),
        buildBalanceCard(ctx),
      ].column().align(at: Alignment.topCenter).expanded(),
      SizedBox(width: 10.w),
    ].row().scrolled();
  }

  Widget buildBalanceCard(BuildContext ctx) {
    return buildCard(i18n.balance, _buildBalanceCardContent(ctx));
  }

  Widget _buildBalanceCardContent(BuildContext ctx) {
    final balance = _balance;

    return [
      _buildBalanceInfoRow(Icons.offline_bolt, i18n.remainingPower, balance.powerText),
      _buildBalanceInfoRow(Icons.savings, i18n.balance, balance.balanceText, color: balance.balanceColor),
    ].column().padH(30);
  }

  Widget _buildBalanceInfoRow(IconData icon, String title, String? content, {Color? color}) {
    final style = TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color);
    return [
      [
        Icon(
          icon,
          color: context.fgColor,
        ),
        const SizedBox(width: 10),
        Text(title, style: style, overflow: TextOverflow.fade),
      ].row(),
      [
        if (content == null)
          LimitedBox(maxWidth: 10, maxHeight: 10, child: Placeholders.loading())
        else
          content.text(style: style, overflow: TextOverflow.fade),
      ].column(caa: CrossAxisAlignment.end),
    ].row(maa: MainAxisAlignment.spaceBetween);
  }

  Widget buildUpdateTime(BuildContext ctx, DateTime? time) {
    final outOfDateColor = time != null && time.difference(DateTime.now()).inDays > 1 ? Colors.redAccent : null;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.update),
              const SizedBox(width: 10),
              Text(i18n.updateTime, style: TextStyle(color: outOfDateColor), overflow: TextOverflow.ellipsis),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(time != null ? updateTimeFormatter.format(time.toLocal()) : "...", overflow: TextOverflow.ellipsis),
            ]),
          ],
        )).center();
  }

  @override
  bool get wantKeepAlive => true;
}

extension BalanceEx on Balance? {
  String? get powerText {
    final self = this;
    return self == null ? null : i18n.unit.powerKwh(self.balance.toStringAsFixed(2));
  }

  String? get balanceText {
    final self = this;
    return self == null ? null : i18n.unit.rmb(self.balance.toStringAsFixed(2));
  }

  Color? get balanceColor {
    final self = this;
    if (self == null) {
      return null;
    } else {
      return self.balance < 10 ? Colors.red : null;
    }
  }
}