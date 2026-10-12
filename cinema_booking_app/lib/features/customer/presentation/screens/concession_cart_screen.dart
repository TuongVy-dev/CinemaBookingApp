import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui/cinema_widgets.dart';
import '../view_models/concession_view_model.dart';

class ConcessionCartScreen extends StatelessWidget {
  const ConcessionCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConcessionsViewModel>();
    final selected = vm.catalog
        .where((item) => vm.cart.containsKey(item.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SectionHeading('Bắp & nước'),
          if (selected.isEmpty)
            const AsyncStateView(message: 'Giỏ bắp nước trống')
          else
            ...selected.map((item) {
              final quantity = vm.cart[item.id]!;

              return Card(
                child: ListTile(
                  leading: CinemaPoster(item.image, width: 52, height: 52),
                  title: Text(item.name),
                  subtitle: Text('${formatVnd(item.price)} × $quantity'),
                  trailing: SizedBox(
                    width: 124,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Giảm ${item.name}',
                          onPressed: () =>
                              vm.setQuantity(item.id, quantity - 1),
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Text('$quantity'),
                        IconButton(
                          tooltip: 'Tăng ${item.name}',
                          onPressed: quantity >= 10
                              ? null
                              : () => vm.setQuantity(item.id, quantity + 1),
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          TextButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/concessions');
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm món'),
          ),
          const SectionHeading('Tạm tính'),
          PriceLine('Bắp & nước', vm.foodSubtotal),
          const Text('Backend sẽ xác nhận giá và tổng tiền khi tạo đơn.'),
        ],
      ),
    );
  }
}
