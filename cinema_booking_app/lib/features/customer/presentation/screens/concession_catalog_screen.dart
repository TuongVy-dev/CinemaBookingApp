import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/concession_view_model.dart';
import '../../../../core/ui/cinema_theme.dart';
import '../../../../core/ui/cinema_widgets.dart';
import '../../domain/entities/cinema_models.dart';

class ConcessionCatalogScreen extends StatelessWidget {
  const ConcessionCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConcessionsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BẮP & NƯỚC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng nhập',
            onPressed: () => context.push('/login'),
            icon: const Icon(Icons.login),
          ),
          IconButton(
            onPressed: () => context.push('/cart'),
            icon: Badge(
              label: Text('${vm.count}'),
              isLabelVisible: vm.count > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF332929)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: vm.busy && vm.catalog.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.error != null && vm.catalog.isEmpty
              ? AsyncStateView(
                  message: vm.error!,
                  retry: vm.load,
                  icon: Icons.error_outline,
                )
              : vm.catalog.isEmpty
              ? const AsyncStateView(message: 'Không có món phù hợp.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.catalog.length,
                  itemBuilder: (context, index) =>
                      _ConcessionTile(vm.catalog[index]),
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/cart'),
                  child: const Text('Bỏ qua'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/cart'),
                  child: Text('Xem giỏ (${vm.count})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcessionTile extends StatelessWidget {
  const _ConcessionTile(this.item);
  final CinemaConcession item;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConcessionsViewModel>();
    final quantity = vm.cart[item.id] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CinemaPoster(item.image, width: 86, height: 86),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CinemaColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    formatVnd(item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (quantity > 0)
                        IconButton(
                          tooltip: 'Giảm ${item.name}',
                          onPressed: () =>
                              vm.setQuantity(item.id, quantity - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      if (quantity > 0) Text('$quantity'),
                      IconButton(
                        tooltip: 'Thêm ${item.name}',
                        onPressed: quantity >= 10
                            ? null
                            : () => vm.setQuantity(item.id, quantity + 1),
                        icon: const Icon(
                          Icons.add_circle,
                          color: CinemaColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
