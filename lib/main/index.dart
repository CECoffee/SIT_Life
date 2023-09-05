import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainStagePage extends StatefulWidget {
  final Widget outlet;

  const MainStagePage({super.key, required this.outlet});

  @override
  State<MainStagePage> createState() => _MainStagePageState();
}

class _MainStagePageState extends State<MainStagePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var currentStage = 0;
  final List<({String route, BottomNavigationBarItem item})> items = [
    (
      route: "/",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        activeIcon: Icon(Icons.calendar_month),
        label: "Timetable",
      )
    ),
    (
      route: "/school",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.school_outlined),
        activeIcon: Icon(Icons.school),
        label: "School",
      )
    ),
    (
      route: "/life",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.house_outlined),
        activeIcon: Icon(Icons.house),
        label: "Life",
      )
    ),
    (
      route: "/me",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: "Me",
      )
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: widget.outlet,
      ),
      bottomNavigationBar: buildButtonNavigationBar(),
    );
  }

  Widget buildButtonNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      currentIndex: getSelectedIndex(),
      onTap: onItemTapped,
      items: items.map((e) => e.item).toList(),
    );
  }

  int getSelectedIndex() {
    final location = GoRouterState.of(context).uri.toString();
    return items.indexWhere((e) => location.startsWith(e.route));
  }

  void onItemTapped(int index) {
    final route = items[index].route;
    context.go(route);
  }
}

abstract class DrawerDelegateProtocol {
  const DrawerDelegateProtocol();

  void openDrawer();

  void closeDrawer();

  void openEndDrawer();

  void closeEndDrawer();
}

class DrawerDelegate extends DrawerDelegateProtocol {
  final GlobalKey<ScaffoldState> key;

  const DrawerDelegate(this.key);

  @override
  void openDrawer() {
    key.currentState?.openDrawer();
  }

  @override
  void closeDrawer() {
    key.currentState?.closeDrawer();
  }

  @override
  void openEndDrawer() {
    key.currentState?.openEndDrawer();
  }

  @override
  void closeEndDrawer() {
    key.currentState?.closeEndDrawer();
  }
}
