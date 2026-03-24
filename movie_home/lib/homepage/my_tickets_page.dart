import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});
  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final Map<String, _BookingGroup> bookings = {};

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final tickets = prefs.getStringList('tickets') ?? [];
    
    final currentUser = prefs.getString('currentUser') ?? '';

    bookings.clear();
    for (final t in tickets) {
      final p = t.split('|');
      
      if (p.length < 7) continue; 

      final ticketOwner = p[6]; 
      
      if (ticketOwner != currentUser) continue;

      final bookingId = p[0];
      final movie = p[1];
      final date = p[2];
      final time = p[3];
      final seat = p[4];
      final price = int.parse(p[5]);

      bookings.putIfAbsent(
        bookingId,
        () => _BookingGroup(movie: movie, date: date, time: time),
      );
      bookings[bookingId]!.seats.add(seat);
      bookings[bookingId]!.total += price;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Vé của tôi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: bookings.values.map(_buildTicketCard).toList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Chưa có vé nào',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(_BookingGroup b) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: _box(),
      child: Column(
        children: [
          _header(b.movie),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('NGÀY', b.date, Icons.calendar_today, 'GIỜ', b.time,
                    Icons.access_time),
                const Divider(height: 24),
                _row('GHẾ', b.seats.join(', '), Icons.event_seat, 'TỔNG',
                    '${b.total} VND', Icons.payments,
                    rightBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String title) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            const Icon(Icons.movie, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ],
        ),
      );

  Widget _row(String l1, String v1, IconData i1, String l2, String v2,
          IconData i2,
          {bool rightBold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _info(l1, v1, i1),
          _info(l2, v2, i2, bold: rightBold),
        ],
      );

  Widget _info(String label, String value, IconData icon, {bool bold = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.indigo),
              const SizedBox(width: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
            ],
          ),
        ],
      );

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      );
}

class _BookingGroup {
  final String movie;
  final String date;
  final String time;
  final List<String> seats = [];
  int total = 0;
  _BookingGroup(
      {required this.movie, required this.date, required this.time});
}
