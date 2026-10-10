import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/cinema_theme.dart';
import '../../domain/entities/booking_summary.dart';

/// Intermediate screen after a booking is stored and before demo payment.
class BookingCreatedScreen extends StatelessWidget {
  const BookingCreatedScreen({super.key, required this.booking});

  final CreatedBooking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt vé thành công')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: CinemaColors.warning,
                child: Icon(Icons.check_rounded, size: 48, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Text(
                'Đơn của bạn đã được tạo',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy thanh toán để hoàn tất và phát hành vé.',
                style: TextStyle(color: CinemaColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Mã đơn', value: booking.bookingId),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Tổng cần thanh toán',
                        value: _vnd(booking.totalAmount),
                        emphasis: true,
                      ),
                      const Divider(height: 24),
                      const _InfoRow(
                        label: 'Trạng thái',
                        value: 'Chờ thanh toán',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Thanh toán demo'),
                    content: const Text(
                      'Chức năng thanh toán demo sẽ được triển khai ở bước tiếp theo. '
                      'Đơn đã được lưu với trạng thái chờ thanh toán.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Đã hiểu'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.payment_outlined),
                label: const Text('Thanh toán demo'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/account'),
                child: const Text('Về tài khoản'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _vnd(int amount) =>
      '${NumberFormat.decimalPattern('vi_VN').format(amount)} đ';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: CinemaColors.muted)),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}
