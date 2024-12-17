import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventEntry extends StatefulWidget {
  @override
  _EventEntryState createState() => _EventEntryState();
}

class _EventEntryState extends State<EventEntry> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedEventTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedEventTime == null
                          ? 'No Event Time Chosen'
                          : 'Event Time: ${DateFormat.yMMMd().add_jm().format(_selectedEventTime!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectEventTime(context),
                    child: Text('Choose Event Time'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedEventTime != null) {
                      _saveDataToFirebase();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please choose an event time.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectEventTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedEventTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  void _saveDataToFirebase() {
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    events
        .add({
      'name': _nameController.text,
      'event_name': _eventNameController.text,
      'location': _locationController.text,
      'event_time': _selectedEventTime!.toIso8601String(),
    })
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data Saved Successfully'),
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedEventTime = null;
      });
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save data: $error'),
        ),
      );
    });
  }
}
