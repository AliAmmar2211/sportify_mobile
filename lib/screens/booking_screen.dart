import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/providers/stadium_provider.dart';
import 'package:sportify_mobile/providers/auth_provider.dart';
import 'package:sportify_mobile/models/stadium.dart';
import 'package:sportify_mobile/models/booking.dart';
import 'package:sportify_mobile/widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  final Stadium stadium;

  const BookingScreen({super.key, required this.stadium});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    '09:00 - 11:00',
    '11:00 - 13:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
    '17:00 - 19:00',
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<StadiumProvider>(context, listen: false)
        .loadBookings(widget.stadium.id!);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = Provider.of<StadiumProvider>(context).bookings;

    return Scaffold(
      appBar: AppBar(title: Text(widget.stadium.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book ${widget.stadium.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickDate,
                        child: Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTimeSlot,
                        hint: const Text('Select Time Slot'),
                        items: _timeSlots
                            .map((slot) => DropdownMenuItem(
                                  value: slot,
                                  child: Text(slot),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTimeSlot = value;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _bookStadium,
                  child: const Text('Confirm Booking'),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Existing Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return BookingCard(booking: bookings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _bookStadium() {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill all fields'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final booking = Booking(
      stadiumId: widget.stadium.id!,
      userId: user?.id,
      date: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
      timeSlot: _selectedTimeSlot!,
      userName: _nameController.text,
    );

    Provider.of<StadiumProvider>(context, listen: false).bookStadium(booking);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking successful!')),
    );
    
    setState(() {
      _nameController.clear();
      _selectedDate = null;
      _selectedTimeSlot = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}