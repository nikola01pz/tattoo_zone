import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:tattoo_zona/features/artist/bloc/appointment_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_state.dart';
import 'package:tattoo_zona/features/shared/models/appointment_model.dart';
import 'package:tattoo_zona/features/artist/pages/new_appointment_page.dart';

class ArtistCalendarPage extends StatefulWidget {
  const ArtistCalendarPage({super.key});

  @override
  State<ArtistCalendarPage> createState() => _ArtistCalendarPageState();
}

class _ArtistCalendarPageState extends State<ArtistCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<AppointmentModel> _getAppointmentsForDay(
    DateTime day,
    List<AppointmentModel> all,
  ) {
    return all
        .where(
          (a) =>
              isSameDay(a.date, day) &&
              a.status != 'cancelled', // ne prikazuj otkazane na kalendaru
        )
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        buildWhen: (prev, curr) {
          if (prev is AppointmentLoading && curr is AppointmentLoaded) {
            return true;
          }
          if (prev is AppointmentLoaded && curr is AppointmentLoaded) {
            return !listEquals(prev.all, curr.all);
          }
          return false;
        },
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! AppointmentLoaded) {
            return const SizedBox();
          }

          final all = state.all;
          final selectedAppointments = _selectedDay != null
              ? _getAppointmentsForDay(_selectedDay!, all)
              : _getAppointmentsForDay(_focusedDay, all);

          return Column(
            children: [
              // --- Kalendar ---
              TableCalendar<AppointmentModel>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2027, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getAppointmentsForDay(day, all),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (mounted) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  if (mounted) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  }
                },
              ),
              const Divider(),

              // --- Lista appointmenta za odabrani dan ---
              Expanded(
                child: selectedAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments for this day.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: selectedAppointments.length,
                        itemBuilder: (context, index) {
                          final a = selectedAppointments[index];
                          final timeStr = DateFormat('HH:mm').format(a.date);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Vrijeme
                                Column(
                                  children: [
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${a.durationMinutes}min',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                const VerticalDivider(width: 1),
                                const SizedBox(width: 14),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.clientName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (a.style.isNotEmpty)
                                        Text(
                                          a.style,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      if (a.description.isNotEmpty)
                                        Text(
                                          a.description,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                // Status + cijena
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '€${a.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(a.status)
                                            .withAlpha(15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        a.status,
                                        style: TextStyle(
                                          color: _statusColor(a.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NewAppointmentPage(),
            ),
          );
        },
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}