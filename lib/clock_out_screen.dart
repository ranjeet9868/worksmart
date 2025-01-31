import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ClockOutScreen extends StatefulWidget {
  final String userName;
  final DateTime clockInDateTime;
  final Map<String, bool> responsibilities;
  final Map<String, String> reasons;
  final List<Map<String, dynamic>> breaks;

  const ClockOutScreen({
    super.key,
    required this.userName,
    required this.clockInDateTime,
    required this.responsibilities,
    required this.reasons,
    required this.breaks,
  });

  @override
  State<ClockOutScreen> createState() => _ClockOutScreenState();
}

class _ClockOutScreenState extends State<ClockOutScreen> {
  final TextEditingController _timeController = TextEditingController();
  String _amPm = 'AM';

  Future<void> _submitClockOutTime() async {
    try {
      // Normalize time format to HH:MM
      final normalizedTime = _timeController.text.replaceAll(RegExp(r'[^0-9]'), ':');
      final timeParts = normalizedTime.split(':');
      final enteredHour = int.parse(timeParts[0]);
      final enteredMinute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      // Validate input
      if (enteredHour < 1 || enteredHour > 12 || enteredMinute < 0 || enteredMinute >= 60) {
        throw FormatException("Invalid time format");
      }

      // Convert clock-out time to a DateTime object
      final isPm = _amPm == 'PM';
      var clockOutDateTime = DateTime.now().copyWith(
        hour: (enteredHour % 12) + (isPm ? 12 : 0),
        minute: enteredMinute,
      );

      final clockInDateTime = widget.clockInDateTime;

      // Handle midnight crossing
      if (clockOutDateTime.isBefore(clockInDateTime)) {
        clockOutDateTime = clockOutDateTime.add(const Duration(days: 1));
      }

      // Calculate shift duration
      final shiftDuration = clockOutDateTime.difference(clockInDateTime).inMinutes / 60;

      // Check if shift exceeds 8 hours
      if (shiftDuration > 8) {
        final overtimeConfirmed = await _confirmOvertime(context, shiftDuration);
        if (!overtimeConfirmed) return;
      }

      // Save data to Firestore
      await _saveToFirestore(clockInDateTime, clockOutDateTime, shiftDuration);

      // Close the app after submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift data submitted successfully!')),
      );
      await Future.delayed(const Duration(seconds: 2));
      SystemNavigator.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<bool> _confirmOvertime(BuildContext context, double shiftDuration) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Overtime Confirmation"),
          content: Text("Your shift duration is ${shiftDuration.toStringAsFixed(2)} hours. Is this correct?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToFirestore(DateTime clockIn, DateTime clockOut, double duration) async {
    final shiftData = {
      'userName': widget.userName,
      'clockIn': clockIn.toIso8601String(),
      'clockOut': clockOut.toIso8601String(),
      'duration': duration,
      'timestamp': FieldValue.serverTimestamp(),
      'responsibilities': widget.responsibilities.map((key, value) => MapEntry(key, {
            'done': value,
            'reason': widget.reasons[key] ?? '',
          })),
      'breaks': widget.breaks,
    };

    await FirebaseFirestore.instance.collection('shifts').add(shiftData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clock-Out Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Clock-Out Time (e.g., 6:30, 6.30, 6/30, 6@30)',
                hintText: 'Enter time in any format',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Select AM/PM: '),
                DropdownButton<String>(
                  value: _amPm,
                  items: ['AM', 'PM']
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _amPm = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitClockOutTime,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
