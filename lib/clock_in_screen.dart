import 'package:flutter/material.dart';
import 'package:worksmart/responsibilities_screen.dart';

// Define responsibilities for each shift
final Map<String, List<String>> shiftResponsibilities = {
  "Early Morning": ["Sanitize: Countertops, POS, Food display, Condiments bar, Hot water machine", "Organize: Under cash register", 
  "Wipe: Sitting area, Arrange chairs", "Wrap: Pastries as needed", "Set up: Sushi, Salads, Sandwitches, Fruit cups"],
  "Morning": ["Restock: Chipotle mayo, gravy", "Wipe: Sitting area, Arrange chairs", "Sanitize: Countertops, POS, Food display, Condiment bar, Pop dispenser (Zios)",
  "Clean: Pop fridge"],
  "Mid-shift": ["Restock: Pop, Condiments bar, Chilli sauce", "Sanitize: Food display & Organize", "Wipe: Sitting area, Arrange chairs","Organise: Under cash register"],
  "Evening": ["Restock: Condiments bar (top and under)", "Restock: Pop fridge", "Wipe: Sitting Area", "Arrange Chairs","Restock: Water cups, Pop cups, Coffee cups",
  "Restock: Dip sauce, Jam and Peanut butter"],
  "Night-shift": ["Closing tasks", "Keep everything organised", "Final checks"]
};

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  ClockInScreenState createState() => ClockInScreenState();
}

class ClockInScreenState extends State<ClockInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String _amPm = 'AM'; // Default value for AM/PM toggle

  void _submitClockInTime() {
  try {
    // Validate the user's name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    // Parse the entered time using a regular expression
    final regex = RegExp(r'^(\d+)[^0-9]*(\d*)$');
    final match = regex.firstMatch(_timeController.text);
    if (match == null) {
      throw FormatException("Invalid time format");
    }

    final enteredHour = int.parse(match.group(1)!);
    final enteredMinute = match.group(2)?.isNotEmpty == true
        ? int.parse(match.group(2)!)
        : 0;

    // Validate input
    if (enteredHour < 1 || enteredHour > 12 || enteredMinute < 0 || enteredMinute >= 60) {
      throw FormatException("Invalid time format");
    }

    // Convert to a DateTime object
    final now = DateTime.now();
    final isPm = _amPm == 'PM';
    final clockInDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      (enteredHour % 12) + (isPm ? 12 : 0),
      enteredMinute,
    );

    // Determine shift
    String shift = '';
    final totalMinutes = clockInDateTime.hour * 60 + clockInDateTime.minute;
    if (totalMinutes >= 360 && totalMinutes < 540) {
      shift = "Early Morning"; // 6:00 AM - 8:59 AM
    } else if (totalMinutes >= 540 && totalMinutes < 720) {
      shift = "Morning"; // 9:00 AM - 11:59 AM
    } else if (totalMinutes >= 720 && totalMinutes < 780) {
      shift = "Mid-shift"; // 12:00 PM - 12:59 PM
    } else if (totalMinutes >= 780 && totalMinutes < 960) {
      shift = "Mid-shift"; // 1:00 PM - 3:59 PM
    } else if (totalMinutes >= 960 && totalMinutes < 1110) {
      shift = "Evening"; // 4:00 PM - 6:29 PM
    } else if (totalMinutes >= 1110 && totalMinutes <= 1350) {
      shift = "Night-shift"; // 6:30 PM - 10:30 PM
    }

    if (shift.isEmpty) {
      throw FormatException("Invalid shift");
    }

    // Navigate to ResponsibilitiesScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponsibilitiesScreen(
          userName: _nameController.text.trim(), // Pass user name
          responsibilities: shiftResponsibilities[shift] ?? [],
          clockInDateTime: clockInDateTime, // Pass DateTime here
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid clock-in time: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clock In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Clock-In Time (e.g., 6:30)',
                hintText: 'Enter time in HH or HH:MM format',
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
              onPressed: _submitClockInTime,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
