import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'common/custom_button.dart';
import 'common/custom_text_field.dart';

class BookingForm extends StatefulWidget {
  final Function(String pickup, String dropoff, String date, String time) onSubmit;
  final bool isLoading;

  const BookingForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        if (context.mounted) {
          _timeController.text = picked.format(context);
        }
      });
    }
  }

  void _submitForm() {
    final pickup = _pickupController.text.trim();
    final dropoff = _dropoffController.text.trim();
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();

    if (pickup.isEmpty || dropoff.isEmpty || date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos.')),
      );
      return;
    }

    widget.onSubmit(pickup, dropoff, date, time);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderVariantColor.withOpacity(0.2),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_calendar_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Book Your Journey',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Pick-up Location input
          CustomTextField(
            label: 'Pick-up Location',
            placeholder: 'Enter starting point',
            controller: _pickupController,
            prefixIcon: Icons.location_on,
          ),
          const SizedBox(height: 16),
          
          // Drop-off Location input
          CustomTextField(
            label: 'Drop-off Location',
            placeholder: 'Where are you going?',
            controller: _dropoffController,
            prefixIcon: Icons.flag,
          ),
          const SizedBox(height: 16),
          
          // Date & Time pickers side-by-side
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Departure Date',
                  placeholder: 'Select date',
                  controller: _dateController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month,
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Pick-up Time',
                  placeholder: 'Select time',
                  controller: _timeController,
                  readOnly: true,
                  prefixIcon: Icons.schedule,
                  onTap: () => _selectTime(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Request Quote Action Button
          PrimaryButton(
            text: 'Request Quote',
            isLoading: widget.isLoading,
            onPressed: _submitForm,
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
