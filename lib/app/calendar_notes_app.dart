import 'package:calendar_notes/app/app_router.dart';
import 'package:flutter/material.dart';

class CalendarNotesApp extends StatelessWidget {
  const CalendarNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CalendarNotes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
