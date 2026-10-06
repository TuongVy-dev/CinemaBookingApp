import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'cinema_theme.dart';

String formatVnd(int amount) {
  final digits = amount.toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.insert(0, digits.substring((end - 3).clamp(0, end).toInt(), end));
  }
  return '${groups.join('.')} ₫';
}

class CinemaPoster extends StatelessWidget {
  const CinemaPoster(
    this.asset, {
    super.key,
    this.width = 96,
    this.height = 128,
  });

  final String asset;
  final double width;
  final double height;

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: CinemaColors.surface,
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: CinemaColors.muted,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final source = asset.trim();
    final uri = Uri.tryParse(source);
    final isNetwork = uri?.scheme == 'http' || uri?.scheme == 'https';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: source.isEmpty
          ? _placeholder()
          : isNetwork
          ? Image.network(
              source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            )
          : Image.asset(
              source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 12),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.message,
    this.retry,
    this.icon = Icons.inbox_outlined,
  });
  final String message;
  final VoidCallback? retry;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CinemaColors.muted, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (retry != null)
            TextButton(onPressed: retry, child: const Text('Thử lại')),
        ],
      ),
    ),
  );
}

class PriceLine extends StatelessWidget {
  const PriceLine(this.label, this.value, {super.key, this.total = false});
  final String label;
  final int value;
  final bool total;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: total ? CinemaColors.text : CinemaColors.muted,
            fontWeight: total ? FontWeight.bold : null,
          ),
        ),
        Text(
          formatVnd(value),
          style: TextStyle(
            color: total ? CinemaColors.red : CinemaColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

void showCinemaMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class CinemaBottomNavigation extends StatelessWidget {
  const CinemaBottomNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xFF171111),
      border: Border(top: BorderSide(color: Color(0xFF332929))),
    ),
    child: NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 66,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 21,
            color: states.contains(WidgetState.selected)
                ? CinemaColors.red
                : CinemaColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? CinemaColors.red
                : CinemaColors.muted,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Phim',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_num_outlined),
            selectedIcon: Icon(Icons.confirmation_num),
            label: 'Đơn của tôi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        onDestinationSelected: (index) =>
            context.go(['/movies', '/bookings', '/account'][index]),
      ),
    ),
  );
}
