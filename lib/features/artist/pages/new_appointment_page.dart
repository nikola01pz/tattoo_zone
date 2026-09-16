import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/appointment_event.dart';
import 'package:tattoo_zona/features/shared/models/appointment_model.dart';

class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key});

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final _clientNameController = TextEditingController();
  final _styleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _dateTime;
  String _duration = '30';
  String _status = 'confirmed';

  @override
  void dispose() {
    _clientNameController.dispose();
    _styleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime ?? DateTime.now()),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date & time')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final priceText = _priceController.text.trim();
    double price;

    try {
      price = double.parse(priceText.isEmpty ? '0' : priceText);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price value')),
      );
      return;
    }

    final newAppt = AppointmentModel(
      id: '',
      artistId: uid,
      clientId: '',
      clientName: _clientNameController.text.trim(),
      clientImageUrl: '',
      date: _dateTime!,
      durationMinutes: int.parse(_duration),
      style: _styleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      status: _status,
      createdAt: DateTime.now(),
    );

    context.read<AppointmentBloc>().add(AddAppointment(newAppt));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateTime == null
        ? 'Select date & time'
        : DateFormat('yyyy-MM-dd HH:mm').format(_dateTime!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                  labelText: 'Client name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _styleController,
                decoration: const InputDecoration(
                  labelText: 'Style (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickDateTime,
                child: Text(dateLabel),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _duration,
                items: const [
                  DropdownMenuItem(value: '30', child: Text('30 min')),
                  DropdownMenuItem(value: '60', child: Text('1 h')),
                  DropdownMenuItem(value: '120', child: Text('2 h')),
                  DropdownMenuItem(value: '180', child: Text('3 h')),
                  DropdownMenuItem(value: '240', child: Text('4 h')),
                  DropdownMenuItem(value: '480', child: Text('Whole day')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _duration = v);
                },
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}