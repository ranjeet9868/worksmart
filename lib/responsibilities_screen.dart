import 'package:flutter/material.dart';
import 'package:worksmart/break_input_screen.dart';

class ResponsibilitiesScreen extends StatefulWidget {
  final String userName; // fetching username from clock_in_screen
  final List<String> responsibilities;
  final DateTime clockInDateTime; // Clock-In Time passed from Clock-In Screen

  const ResponsibilitiesScreen({
    super.key,
    required this.userName, // Passing it
    required this.responsibilities,
    required this.clockInDateTime, // Clock-In Time is now required
  });

  @override
  ResponsibilitiesScreenState createState() => ResponsibilitiesScreenState();
}

class ResponsibilitiesScreenState extends State<ResponsibilitiesScreen> {
  final Map<String, bool> _completionStatus = {};
  final Map<String, String> _reasons = {};

  @override
  void initState() {
    super.initState();
    // Initialize responsibility statuses and reasons
    for (var responsibility in widget.responsibilities) {
      _completionStatus[responsibility] = false; // Default to "not done"
      _reasons[responsibility] = ''; // Default reason empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsibilities'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Clock-In Time: ${widget.clockInDateTime}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.responsibilities.length,
              itemBuilder: (context, index) {
                final responsibility = widget.responsibilities[index];
                return Card(
                  child: ListTile(
                    title: Text(responsibility),
                    trailing: Switch(
                      value: _completionStatus[responsibility]!,
                      onChanged: (value) {
                        setState(() {
                          _completionStatus[responsibility] = value;
                        });
                        if (!value) {
                          _showReasonDialog(context, responsibility);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitResponsibilities,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showReasonDialog(BuildContext context, String responsibility) {
    String tempReason = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reason for not completing "$responsibility"?'),
          content: TextField(
            onChanged: (value) => tempReason = value,
            decoration: const InputDecoration(hintText: 'Enter reason here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _reasons[responsibility] = tempReason;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _submitResponsibilities() async {
  for (var responsibility in widget.responsibilities) {
    if (!_completionStatus[responsibility]!) {
      // If a responsibility is incomplete and no reason is provided
      if (_reasons[responsibility]?.isEmpty ?? true) {
        // Show the reason dialog and wait for user input
        await _showReasonDialogAndWait(context, responsibility);
      }
    }
  }

  // Check again after user input
  bool allReasonsProvided = widget.responsibilities.every((responsibility) {
    return _completionStatus[responsibility]! || (_reasons[responsibility]?.isNotEmpty ?? false);
  });

  if (!allReasonsProvided) {
    // Show a Snackbar if any reason is still missing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please provide reasons for all incomplete responsibilities.')),
    );
    return; // Stop submission
  }

  // If all responsibilities are valid, proceed to the next screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BreakInputScreen(
      userName: widget.userName,
      clockInDateTime: widget.clockInDateTime, // Pass the clock-in time
      responsibilities: _completionStatus, // Pass the responsibilities map
      reasons: _reasons, // Pass the reasons map
    ),
  ),
);

}

Future<void> _showReasonDialogAndWait(BuildContext context, String responsibility) async {
  String tempReason = '';
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Reason for not completing "$responsibility"?'),
        content: TextField(
          onChanged: (value) {
            tempReason = value;
          },
          decoration: const InputDecoration(hintText: 'Enter reason here'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (tempReason.isNotEmpty) {
                setState(() {
                  _reasons[responsibility] = tempReason; // Save the reason
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason before saving.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

    }


  

