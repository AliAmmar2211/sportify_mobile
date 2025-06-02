import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify_mobile/providers/stadium_provider.dart';
import 'package:sportify_mobile/providers/auth_provider.dart';
import 'package:sportify_mobile/models/stadium.dart';
import 'package:sportify_mobile/models/booking.dart';
import 'package:sportify_mobile/widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  final Stadium stadium;
  
  const BookingScreen({Key? key, required this.stadium}) : super(key: key);
  
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
    // Load bookings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StadiumProvider>(context, listen: false)
          .loadBookings(widget.stadium.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StadiumProvider>(
      builder: (context, provider, child) {
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
                  itemCount: provider.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.bookings[index];
                    return BookingCard(booking: booking);
                  },
                ),
              ),
            ],
          ),
        );
      },
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

  void _bookStadium() async{
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
    }
       final existingBookings = Provider.of<StadiumProvider>(context, listen: false).bookings;
      final hasConflict = existingBookings.any((booking) => 
        booking.date == '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' &&
        booking.timeSlot == _selectedTimeSlot
      );

       if (hasConflict) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Time Slot Not Available'),
           content: const Text('This time slot is already booked. Please select another time.'),
            actions: [
             TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ]
          ),
        );
      
      return;
    }
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final booking = Booking(
      stadiumId: widget.stadium.id!,
      userId: user?.id,
      date: '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
      timeSlot: _selectedTimeSlot!,
      userName: _nameController.text,
    );

    await Provider.of<StadiumProvider>(context, listen: false).bookStadium(booking);
    await Provider.of<StadiumProvider>(context, listen: false)
        .loadBookings(widget.stadium.id!);

     if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking successful!')),
    );
    
    setState(() {
      _nameController.clear();
      _selectedDate = null;
      _selectedTimeSlot = null;
    });
  }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}