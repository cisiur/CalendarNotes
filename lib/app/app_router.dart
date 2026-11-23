import 'package:calendar_notes/app/app_shell.dart';
import 'package:calendar_notes/features/calendar/calendar_page.dart';
import 'package:calendar_notes/features/entries/entries_page.dart';
import 'package:calendar_notes/features/settings/settings_page.dart';
import 'package:calendar_notes/features/templates/templates_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/calendar',
  routes: <RouteBase>[
    GoRoute(
      path: '/calendar',
      builder: (BuildContext context, GoRouterState state) => const AppShell(
        currentIndex: 0,
        child: CalendarPage(),
      ),
    ),
    GoRoute(
      path: '/entries',
      builder: (BuildContext context, GoRouterState state) => const AppShell(
        currentIndex: 1,
        child: EntriesPage(),
      ),
    ),
    GoRoute(
      path: '/templates',
      builder: (BuildContext context, GoRouterState state) => const AppShell(
        currentIndex: 2,
        child: TemplatesPage(),
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => const AppShell(
        currentIndex: 3,
        child: SettingsPage(),
      ),
    ),
  ],
);
