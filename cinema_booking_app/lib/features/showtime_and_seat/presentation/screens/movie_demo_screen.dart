import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/cinema_theme.dart';
import '../../../../core/ui/cinema_widgets.dart';

class MoviesDemoScreen extends StatelessWidget {
  const MoviesDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phim đang chiếu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                context.push('/showtimes/MV000002', extra: 'Phim demo'),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 96,
                      decoration: BoxDecoration(
                        color: CinemaColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        color: CinemaColors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phim demo',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chạm để xem lịch chiếu',
                            style: TextStyle(color: CinemaColors.muted),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mã phim: MV000002',
                            style: TextStyle(
                              color: CinemaColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CinemaBottomNavigation(
        selectedIndex: 0,
        onItemSelected: (index) {
          if (index == 0) context.go('/movies');
          if (index == 1) context.go('/tickets');
          if (index == 2) context.go('/account');
        },
      ),
    );
  }
}
