import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/customer/data/services/catalog_session_bridge.dart';
import '../features/customer/presentation/view_models/catalog_session_view_model.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../features/customer/data/repositories/concession_api_repository.dart';
import '../features/customer/data/services/concession_api_service.dart';
import '../features/customer/domain/repositories/concession_repository.dart';
import '../features/customer/presentation/view_models/concession_view_model.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<ApiClient>(
        create: (_) => ApiClient(baseUrl: AppConfig.apiBaseUrl),
        dispose: (_, client) => client.dio.close(force: true),
      ),
      Provider<CatalogSessionBridge>(
        create: (context) => CatalogSessionBridge(context.read<ApiClient>()),
      ),
      Provider<ConcessionRepository>(
        create: (context) => ConcessionApiRepository(
          service: ConcessionApiService(context.read<ApiClient>()),
          backendBaseUrl: Uri.parse(AppConfig.apiBaseUrl),
        ),
      ),
      ChangeNotifierProvider<ConcessionsViewModel>(
        create: (context) =>
            ConcessionsViewModel(context.read<ConcessionRepository>())
              ..error = 'Đăng nhập trước để tải danh mục bắp/nước.',
      ),
      ChangeNotifierProvider<CatalogSessionViewModel>(
        create: (context) => CatalogSessionViewModel(
          authenticate: (username, password) async {
            final catalog = context.read<ConcessionsViewModel>();
            final session = context.read<CatalogSessionBridge>();

            catalog.reset(clearCatalog: true);
            await session.login(username, password);
            await catalog.load();
          },
        ),
      ),
    ],
    child: child,
  );
}
