import 'package:flutter/material.dart';

import '../core/ui/cinema_theme.dart';
import 'app_router.dart';

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Cinema',
    debugShowCheckedModeBanner: false,
    theme: CinemaTheme.dark,
    routerConfig: cinemaRouter,
  );
}
