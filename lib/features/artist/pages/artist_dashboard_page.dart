import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_event.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_state.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_state.dart';
import 'package:tattoo_zona/features/shared/models/appointment_model.dart';

class ArtistDashboardPage extends StatelessWidget {
  const ArtistDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentBloc>().add(const LoadAppointments());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<ArtistBloc, ArtistState>(
            builder: (context, state) {
              final name = state is ArtistLoaded ? state.artist.displayName : '';
              return Text(
                name.isNotEmpty ? 'Dashboard: $name' : 'Dashboard',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              );
            },
          ),

          const SizedBox(height: 12),

          BlocBuilder<ArtistBloc, ArtistState>(
            builder: (context, artistState) {
              if (artistState is! ArtistLoaded) return const SizedBox();
              final artist = artistState.artist;
              return _StatCard(
                icon: Icons.star,
                iconColor: Colors.amber,
                label: 'Rating',
                value: '${artist.rating.toStringAsFixed(1)} (${artist.reviewCount} reviews)',
              );
            },
          ),

          const SizedBox(height: 20),

          BlocBuilder<AppointmentBloc, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AppointmentError) {
                return Center(child: Text(state.message));
              }
              if (state is! AppointmentLoaded) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- New Requests ---
                  _SectionHeader(title: 'New Requests', count: state.pending.length),
                  const SizedBox(height: 8),
                  state.pending.isEmpty
                      ? const _EmptyCard(text: 'No new requests')
                      : Column(
                          children: state.pending
                              .map((a) => _AppointmentCard(
                                    appointment: a,
                                    showActions: true,
                                  ))
                              .toList(),
                        ),

                  const SizedBox(height: 24),

                  // --- Upcoming ---
                  _SectionHeader(title: 'Upcoming', count: state.upcoming.length),
                  const SizedBox(height: 8),
                  state.upcoming.isEmpty
                      ? const _EmptyCard(text: 'No upcoming appointments')
                      : Column(
                          children: state.upcoming
                              .map((a) => _AppointmentCard(
                                    appointment: a,
                                    showActions: false,
                                  ))
                              .toList(),
                        ),

                  const SizedBox(height: 24),

                  // --- Earnings ---
                  const Text(
                    'Earnings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _EarningsCard(
                          label: 'Weekly',
                          value: state.weeklyEarnings,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _EarningsCard(
                          label: 'Monthly',
                          value: state.monthlyEarnings,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _EarningsCard(
                          label: 'Total',
                          value: state.totalEarnings,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool showActions;
  const _AppointmentCard({
    required this.appointment,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, dd MMM • HH:mm').format(appointment.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: appointment.clientImageUrl.isNotEmpty
                    ? NetworkImage(appointment.clientImageUrl)
                    : null,
                child: appointment.clientImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '€${appointment.price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (appointment.style.isNotEmpty || appointment.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [
                if (appointment.style.isNotEmpty) appointment.style,
                if (appointment.description.isNotEmpty) appointment.description,
              ].join(' — '),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<AppointmentBloc>().add(
                          UpdateAppointmentStatus(
                            appointmentId: appointment.id,
                            status: 'cancelled',
                          ),
                        ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<AppointmentBloc>().add(
                          UpdateAppointmentStatus(
                            appointmentId: appointment.id,
                            status: 'confirmed',
                          ),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String label;
  final double value;
  const _EarningsCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '€${value.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}