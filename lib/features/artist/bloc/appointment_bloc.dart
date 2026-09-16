import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/shared/data/appointment_repository.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_event.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentBloc({AppointmentRepository? repository})
      : _repository = repository ?? AppointmentRepository(),
        super(const AppointmentInitial()) {
    on<LoadAppointments>(_onLoad);
    on<UpdateAppointmentStatus>(_onUpdateStatus);
    on<AddAppointment>(_onAddAppointment);

    add(const LoadAppointments());
  }

  Future<void> _onLoad(
    LoadAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final pending = await _repository.getPendingRequests();
      final upcoming = await _repository.getUpcomingAppointments();
      final all = await _repository.getArtistAppointments();
      final totalEarnings = await _repository.getTotalEarnings();
      final monthlyEarnings = await _repository.getMonthlyEarnings();
      final weeklyEarnings = await _repository.getWeeklyEarnings();

      emit(AppointmentLoaded(
        pending: pending,
        upcoming: upcoming,
        all: all,
        totalEarnings: totalEarnings,
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: weeklyEarnings,
      ));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateAppointmentStatus event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _repository.updateStatus(event.appointmentId, event.status);
      add(const LoadAppointments());
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _repository.addAppointment(event.appointment);
      add(const LoadAppointments());
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}