import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milieryforce/screns/entrydata.dart';

class EventDisplayScreen extends StatefulWidget {
  @override
  _EventDisplayScreenState createState() => _EventDisplayScreenState();
}

class _EventDisplayScreenState extends State<EventDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<EventItem> eventItems = snapshot.data!.docs.map((doc) {
            return EventItem(
              eventId: doc.id,
              name: doc['name'],
              eventName: doc['event_name'],
              location: doc['location'],
              eventTime: DateTime.parse(doc['event_time']),
            );
          }).toList();

          return ListView(
            children: eventItems,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventEntry()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final String eventId;
  final String name;
  final String eventName;
  final String location;
  final DateTime eventTime;

  EventItem({
    required this.eventId,
    required this.name,
    required this.eventName,
    required this.location,
    required this.eventTime,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(eventName),
      subtitle: Text('By: $name | Location: $location | Time: ${DateFormat.yMMMd().add_jm().format(eventTime)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventUpdateScreen(eventId: eventId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteEvent(context, eventId);
            },
          ),
        ],
      ),
    );
  }

  void _deleteEvent(BuildContext context, String eventId) {
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    events.doc(eventId).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $error')));
    });
  }
}

class EventUpdateScreen extends StatefulWidget {
  final String eventId;

  EventUpdateScreen({required this.eventId});

  @override
  _EventUpdateScreenState createState() => _EventUpdateScreenState();
}

class _EventUpdateScreenState extends State<EventUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedEventTime;

  @override
  void initState() {
    super.initState();
    _fetchEventData();
  }

  void _fetchEventData() {
    FirebaseFirestore.instance.collection('events').doc(widget.eventId).get().then((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'];
          _eventNameController.text = data['event_name'];
          _locationController.text = data['location'];
          _selectedEventTime = DateTime.parse(data['event_time']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Event'),
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
                      _updateDataToFirebase();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please choose an event time.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Update'),
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
      initialDate: _selectedEventTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedEventTime ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedEventTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  void _updateDataToFirebase() {
    CollectionReference events = FirebaseFirestore.instance.collection('events');
    events.doc(widget.eventId).update({
      'name': _nameController.text,
      'event_name': _eventNameController.text,
      'location': _locationController.text,
      'event_time': _selectedEventTime!.toIso8601String(),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data Updated Successfully'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update data: $error'),
        ),
      );
    });
  }
}
