import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../features/account/presentation/view_models/account_view_model.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AccountViewModel>(
        create: (_) => AccountViewModel()..checkSession(),
      ),
    ],
    child: child,
  );
}
