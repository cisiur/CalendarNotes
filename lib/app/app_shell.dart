import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final Widget child;

  static const List<_Destination> _destinations = <_Destination>[
    _Destination('Kalendarz', Icons.calendar_month_outlined, '/calendar'),
    _Destination('Wpisy', Icons.subject_outlined, '/entries'),
    _Destination('Szablony', Icons.article_outlined, '/templates'),
    _Destination('Ustawienia', Icons.settings_outlined, '/settings'),
  ];

  void _go(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final bool useNavigationRail = MediaQuery.sizeOf(context).width >= 700;
    final Widget content = Scaffold(
      appBar: AppBar(title: const Text('CalendarNotes')),
      body: SafeArea(child: child),
      bottomNavigationBar: useNavigationRail
          ? null
          : NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (int index) => _go(context, index),
              destinations: _destinations
                  .map(
                    (_Destination destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                  )
                  .toList(),
            ),
    );

    if (!useNavigationRail) {
      return content;
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: currentIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (int index) => _go(context, index),
              destinations: _destinations
                  .map(
                    (_Destination destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
