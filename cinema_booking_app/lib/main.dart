import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_providers.dart';
import 'core/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.getInstance();
  runApp(const AppProviders(child: CinemaApp()));
}
