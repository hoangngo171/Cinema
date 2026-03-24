import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../movie.dart';

class BookingPage extends StatefulWidget {
  final Movie movie;
  const BookingPage({super.key, required this.movie});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  String selectedTime = '18:00';
  List<String> selectedSeats = [];

  final times = ['14:00', '16:00', '18:00', '20:00', '22:00'];
  final seats = List.generate(24, (i) => 'A${i + 1}');
  final int pricePerSeat = 50000;

  Map<String, Set<String>> bookedSeatsMap = {};

  String get bookingKey =>
      '${widget.movie.id}_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}_$selectedTime';

  Set<String> get bookedSeats => bookedSeatsMap[bookingKey] ?? <String>{};

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
  }

  Future<void> _loadBookedSeats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bookedSeatsMap');
    if (raw != null) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      bookedSeatsMap =
          decoded.map((k, v) => MapEntry(k, Set<String>.from(v)));
    }
    setState(() {});
  }

  Future<void> _saveBookedSeats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'bookedSeatsMap',
      json.encode(bookedSeatsMap.map((k, v) => MapEntry(k, v.toList()))),
    );
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final tickets = prefs.getStringList('tickets') ?? [];
    
    final currentUser = prefs.getString('currentUser') ?? 'unknown';
    
    final bookingId = DateTime.now().millisecondsSinceEpoch.toString();

    for (final seat in selectedSeats) {
      tickets.add(
        '$bookingId|${widget.movie.title}|'
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}|'
        '$selectedTime|$seat|$pricePerSeat'
        '|$currentUser', 
      );
    }
    await prefs.setStringList('tickets', tickets);
  }

  Future<void> _handleBooking() async {
    final current = bookedSeatsMap[bookingKey] ?? <String>{};

    current.addAll(selectedSeats);
    bookedSeatsMap[bookingKey] = current;

    await _saveBookedSeats();
    await _saveTickets();

    setState(() {
      selectedSeats.clear(); 
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Đặt vé thành công'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Ngày chiếu'),
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  _sectionTitle('Suất chiếu'),
                  _buildTimeSelector(),
                  const SizedBox(height: 32),

                  Center(
                    child: Container(
                      height: 5,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withAlpha(128),
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'MÀN HÌNH',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSeatSelector(),
                  const SizedBox(height: 20),
                  _buildLegend(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );

  Widget _buildDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final date = DateTime.now().add(Duration(days: i));
          final isSelected = date.day == selectedDate.day;

          return GestureDetector(
            onTap: () => setState(() {
              selectedDate = date;
              selectedSeats.clear();
            }),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? Colors.indigo : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Thg ${date.month}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 10,
      children: times.map((t) {
        final isSelected = selectedTime == t;
        return ChoiceChip(
          label: Text(t),
          selected: isSelected,
          selectedColor: Colors.indigo,
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black),
          onSelected: (_) => setState(() {
            selectedTime = t;
            selectedSeats.clear();
          }),
        );
      }).toList(),
    );
  }

  Widget _buildSeatSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: seats.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final seat = seats[i];
        final isBooked = bookedSeats.contains(seat);
        final isSelected = selectedSeats.contains(seat);

        return GestureDetector(
          onTap: isBooked
              ? null
              : () => setState(() {
                    isSelected
                        ? selectedSeats.remove(seat)
                        : selectedSeats.add(seat);
                  }),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.red 
                  : isSelected
                      ? Colors.indigo
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBooked
                    ? Colors.red
                    : isSelected
                        ? Colors.indigo
                        : Colors.grey.shade400,
              ),
            ),
            child: Text(
              seat,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBooked
                    ? Colors.white
                    : isSelected
                        ? Colors.white
                        : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.red, 'Đã đặt'),
        const SizedBox(width: 16),
        _legendItem(Colors.indigo, 'Đang chọn'),
        const SizedBox(width: 16),
        _legendItem(Colors.white, 'Còn trống', border: true),
      ],
    );
  }

  Widget _legendItem(Color color, String text, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: Colors.grey) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomBar() {
    final total = selectedSeats.length * pricePerSeat;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tổng cộng',
                  style: TextStyle(color: Colors.grey)),
              Text(
                '$total đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed:
                selectedSeats.isEmpty ? null : _handleBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'ĐẶT VÉ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}