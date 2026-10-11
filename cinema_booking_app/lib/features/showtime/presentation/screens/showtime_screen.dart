import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/ui/cinema_theme.dart';
import '../../../../core/ui/cinema_widgets.dart';
import '../../domain/entities/showtime.dart';
import '../view_models/showtime_view_model.dart';

class ShowtimeSelectionScreen extends StatefulWidget {
  const ShowtimeSelectionScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.movieDuration,
    this.ageRating,
  });

  final String movieId;
  final String movieTitle;
  final int? movieDuration;
  final String? ageRating;

  @override
  State<ShowtimeSelectionScreen> createState() =>
      _ShowtimeSelectionScreenState();
}

class _ShowtimeSelectionScreenState extends State<ShowtimeSelectionScreen> {
  late DateTime _selectedDate;
  String? _selectedShowtimeId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadShowtimes();
    });
  }

  void _loadShowtimes() {
    context.read<ShowtimeViewModel>().load(widget.movieId, _selectedDate);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = DateUtils.dateOnly(date);
      _selectedShowtimeId = null;
    });
    _loadShowtimes();
  }

  String _formatTime(String value) {
    final parts = value.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : value;
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShowtimeViewModel>().state;
    final duration =
        widget.movieDuration ??
        (state.showtimes.isEmpty ? null : state.showtimes.first.movieDuration);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHỌN SUẤT CHIẾU',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF332929)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MovieHeader(
                title: widget.movieTitle,
                duration: duration,
                ageRating: widget.ageRating,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Chọn ngày chiếu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 82,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final date = DateUtils.dateOnly(
                      DateTime.now().add(Duration(days: index)),
                    );
                    return _ShowtimeDateCard(
                      date: date,
                      selected: DateUtils.isSameDay(date, _selectedDate),
                      onTap: () => _selectDate(date),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Suất chiếu ngày ${_formatDate(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.errorMessage != null
                    ? AsyncStateView(
                        icon: Icons.error_outline,
                        message: state.errorMessage!,
                        retry: _loadShowtimes,
                      )
                    : state.showtimes.isEmpty
                    ? const AsyncStateView(
                        icon: Icons.event_busy_outlined,
                        message: 'Chưa có suất chiếu trong ngày này.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 92,
                            ),
                        itemCount: state.showtimes.length,
                        itemBuilder: (context, index) {
                          final showtime = state.showtimes[index];
                          return _ShowtimeCard(
                            showtime: showtime,
                            startTime: _formatTime(showtime.startTime),
                            selected:
                                _selectedShowtimeId == showtime.showtimeId,
                            onTap: () {
                              setState(() {
                                _selectedShowtimeId = showtime.showtimeId;
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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

class _MovieHeader extends StatelessWidget {
  const _MovieHeader({
    required this.title,
    required this.duration,
    required this.ageRating,
  });

  final String title;
  final int? duration;
  final String? ageRating;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFF332929))),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.movie_outlined, color: CinemaColors.red, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    if (duration != null) '$duration phút',
                    if (ageRating != null && ageRating!.isNotEmpty) ageRating!,
                  ].join(' '),
                  style: const TextStyle(
                    color: CinemaColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              foregroundColor: CinemaColors.warning,
              disabledForegroundColor: CinemaColors.warning,
              side: const BorderSide(color: CinemaColors.warning),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ShowtimeDateCard extends StatelessWidget {
  const _ShowtimeDateCard({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? CinemaColors.red : CinemaColors.surface,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? CinemaColors.red : const Color(0xFF4A3D3D),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weekdays[date.weekday - 1], style: const TextStyle(fontSize: 10)),
            Text(
              date.day.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text('${date.month}/${date.year}', style: const TextStyle(fontSize: 9)),
          ],
        ),
      ),
    ),
  );
}

class _ShowtimeCard extends StatelessWidget {
  const _ShowtimeCard({
    required this.showtime,
    required this.startTime,
    required this.selected,
    required this.onTap,
  });

  final Showtime showtime;
  final String startTime;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: CinemaColors.surface,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? CinemaColors.red : const Color(0xFF4A3D3D),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              startTime,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              showtime.roomType ?? showtime.roomId ?? 'Phòng chiếu',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CinemaColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
