import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/concession_view_model.dart';
import '../../../../core/ui/cinema_theme.dart';
import '../../../../core/ui/cinema_widgets.dart';
import '../../domain/entities/cinema_models.dart';
import '../../../showtime_and_seat/domain/entities/seat_hold.dart';
import '../../../showtime_and_seat/presentation/widgets/seat_hold_countdown.dart';

class ConcessionCatalogScreen extends StatelessWidget {
  const ConcessionCatalogScreen({super.key, this.hold});

  final SeatHold? hold;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConcessionsViewModel>();
    final items = vm.filteredCatalog;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BẮP & NƯỚC',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF332929)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            children: [
              if (hold != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SeatHoldCountdown(hold: hold!),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ConcessionFilter.values.map((filter) {
                    final label = switch (filter) {
                      ConcessionFilter.all => 'Tất cả',
                      ConcessionFilter.popcorn => 'Bắp',
                      ConcessionFilter.drink => 'Nước',
                    };

                    return ChoiceChip(
                      label: Text(label),
                      shape: const StadiumBorder(),
                      selected: vm.filter == filter,
                      onSelected: (selected) {
                        if (selected) {
                          vm.setFilter(filter);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: vm.busy && vm.catalog.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null && vm.catalog.isEmpty
                    ? AsyncStateView(
                        message: vm.error!,
                        retry: vm.load,
                        icon: Icons.error_outline,
                      )
                    : vm.catalog.isEmpty
                    ? const AsyncStateView(message: 'Chưa có bắp/nước.')
                    : items.isEmpty
                    ? const AsyncStateView(
                        message: 'Không có món thuộc loại đã chọn.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _ConcessionTile(items[index]),
                      ),
              ),
            ],
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
                  onPressed: () => context.push('/cart', extra: hold),
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
