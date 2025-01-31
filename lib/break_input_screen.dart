import 'package:flutter/material.dart';
import 'clock_out_screen.dart'; // Import ClockOutScreen

class BreakInputScreen extends StatefulWidget {
  final String userName; // passing on username from responsibilities screen
  final DateTime clockInDateTime; // Add clock-in DateTime
  final Map<String, bool> responsibilities; // Add responsibilities map
  final Map<String, String> reasons; // Add reasons map

  const BreakInputScreen({
    super.key,
    required this.userName,
    required this.clockInDateTime,
    required this.responsibilities,
    required this.reasons,
  });

  @override
  State<BreakInputScreen> createState() => _BreakInputScreenState();
}

class _BreakInputScreenState extends State<BreakInputScreen> {
  final TextEditingController _break1StartController = TextEditingController();
  final TextEditingController _break1EndController = TextEditingController();
  final TextEditingController _break2StartController = TextEditingController();
  final TextEditingController _break2EndController = TextEditingController();
  final TextEditingController _break3StartController = TextEditingController();
  final TextEditingController _break3EndController = TextEditingController();
  final TextEditingController _noBreakReasonController = TextEditingController();

  String _break1StartAmPm = 'AM';
  String _break1EndAmPm = 'AM';
  String _break2StartAmPm = 'AM';
  String _break2EndAmPm = 'AM';
  String _break3StartAmPm = 'AM';
  String _break3EndAmPm = 'AM';

  bool _noBreaksTaken = false;

  void _submitBreakDetails() {
    if (_noBreaksTaken) {
      if (_noBreakReasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a reason for no breaks')),
        );
        return;
      }
    } else {
      bool hasValidBreak = false;

      if (_break1StartController.text.isNotEmpty &&
          _break1EndController.text.isNotEmpty) {
        hasValidBreak = true;
      }

      if (_break2StartController.text.isNotEmpty &&
          _break2EndController.text.isNotEmpty) {
        hasValidBreak = true;
      }

      if (_break3StartController.text.isNotEmpty &&
          _break3EndController.text.isNotEmpty) {
        hasValidBreak = true;
      }

      if (!hasValidBreak) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill out at least one complete break timing'),
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClockOutScreen(
          userName: widget.userName,
          clockInDateTime: widget.clockInDateTime,
          responsibilities: widget.responsibilities,
          reasons: widget.reasons,
          breaks: _noBreaksTaken
              ? [
                  {'reason': _noBreakReasonController.text}
                ]
              : [
                  if (_break1StartController.text.isNotEmpty &&
                      _break1EndController.text.isNotEmpty)
                    {
                      'start': _break1StartController.text,
                      'end': _break1EndController.text,
                      'startAmPm': _break1StartAmPm,
                      'endAmPm': _break1EndAmPm,
                    },
                  if (_break2StartController.text.isNotEmpty &&
                      _break2EndController.text.isNotEmpty)
                    {
                      'start': _break2StartController.text,
                      'end': _break2EndController.text,
                      'startAmPm': _break2StartAmPm,
                      'endAmPm': _break2EndAmPm,
                    },
                  if (_break3StartController.text.isNotEmpty &&
                      _break3EndController.text.isNotEmpty)
                    {
                      'start': _break3StartController.text,
                      'end': _break3EndController.text,
                      'startAmPm': _break3StartAmPm,
                      'endAmPm': _break3EndAmPm,
                    },
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Break Input')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: const Text('No breaks taken'),
                value: _noBreaksTaken,
                onChanged: (value) {
                  setState(() {
                    _noBreaksTaken = value!;
                  });
                },
              ),
              if (!_noBreaksTaken) ...[
                const SizedBox(height: 16),
                _buildBreakInput(
                  breakNumber: 1,
                  startController: _break1StartController,
                  endController: _break1EndController,
                  startAmPm: _break1StartAmPm,
                  endAmPm: _break1EndAmPm,
                  onStartAmPmChanged: (value) => setState(() {
                    _break1StartAmPm = value!;
                  }),
                  onEndAmPmChanged: (value) => setState(() {
                    _break1EndAmPm = value!;
                  }),
                ),
                const SizedBox(height: 16),
                _buildBreakInput(
                  breakNumber: 2,
                  startController: _break2StartController,
                  endController: _break2EndController,
                  startAmPm: _break2StartAmPm,
                  endAmPm: _break2EndAmPm,
                  onStartAmPmChanged: (value) => setState(() {
                    _break2StartAmPm = value!;
                  }),
                  onEndAmPmChanged: (value) => setState(() {
                    _break2EndAmPm = value!;
                  }),
                ),
                const SizedBox(height: 16),
                _buildBreakInput(
                  breakNumber: 3,
                  startController: _break3StartController,
                  endController: _break3EndController,
                  startAmPm: _break3StartAmPm,
                  endAmPm: _break3EndAmPm,
                  onStartAmPmChanged: (value) => setState(() {
                    _break3StartAmPm = value!;
                  }),
                  onEndAmPmChanged: (value) => setState(() {
                    _break3EndAmPm = value!;
                  }),
                ),
              ],
              if (_noBreaksTaken) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _noBreakReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for no breaks',
                    hintText: 'Provide reason here',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitBreakDetails,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakInput({
    required int breakNumber,
    required TextEditingController startController,
    required TextEditingController endController,
    required String startAmPm,
    required String endAmPm,
    required ValueChanged<String?> onStartAmPmChanged,
    required ValueChanged<String?> onEndAmPmChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Break $breakNumber Start Time'),
        TextField(
          controller: startController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Start Time (e.g., 1:30)',
            hintText: 'Enter start time',
          ),
        ),
        DropdownButton<String>(
          value: startAmPm,
          items: ['AM', 'PM']
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: onStartAmPmChanged,
        ),
        const SizedBox(height: 8),
        Text('Break $breakNumber End Time'),
        TextField(
          controller: endController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'End Time (e.g., 2:30)',
            hintText: 'Enter end time',
          ),
        ),
        DropdownButton<String>(
          value: endAmPm,
          items: ['AM', 'PM']
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: onEndAmPmChanged,
        ),
      ],
    );
  }
}
