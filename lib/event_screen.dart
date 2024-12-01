import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final bool isAdminOrStaff; // Tambahkan parameter

  const EventScreen({Key? key, required this.isAdminOrStaff}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseHelper _databaseHelper =
      DatabaseHelper(); // Inisialisasi DatabaseHelper
  List<Event> _eventsList = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _addHutanMenyalaEvent(); // Tambahkan method ini
  }

  Future<void> _addHutanMenyalaEvent() async {
    await _databaseHelper.insertEvent(
        'Hutan Menyala',
        'Acara spektakuler dengan pertunjukan cahaya di hutan',
        'lib/assets/tahura9.png',
        DateTime(2024, 12, 12));

    // Reload events setelah menambahkan
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events =
          await _databaseHelper.getEventsByDate(_selectedDay ?? DateTime.now());

      setState(() {
        _eventsList = events
            .map((e) => Event(
                title: e['title'],
                description: e['description'],
                imageUrl: e['image_url'],
                date: DateTime.parse(e['date'])))
            .toList();
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    // Gunakan StatefulBuilder untuk memperbarui state dalam dialog
    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedDate; // Deklarasikan di luar StatefulBuilder

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Konfirmasi Tambah Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Judul Event'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Deskripsi Event'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Pilih Tanggal:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      selectedDate != null
                          ? DateFormat('d MMMM yyyy').format(selectedDate!)
                          : 'Belum dipilih',
                      style: GoogleFonts.poppins(),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          // Gunakan setState lokal untuk memperbarui tanggal
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text('Pilih Tanggal'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    String title = titleController.text;
                    String description = descriptionController.text;

                    if (title.isNotEmpty &&
                        description.isNotEmpty &&
                        selectedDate != null) {
                      // Konfirmasi sebelum menyimpan
                      bool? confirmSave = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Konfirmasi Tambah Event'),
                          content: Text(
                              'Apakah Anda yakin ingin menambahkan event ini?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Tambah'),
                            ),
                          ],
                        ),
                      );

                      if (confirmSave == true) {
                        // Simpan event ke database
                        await _databaseHelper.insertEvent(
                          title,
                          description,
                          '', // image_url bisa diisi jika ada
                          selectedDate!,
                        );

                        // Reload events
                        await _loadEvents();

                        // Tutup dialog
                        Navigator.of(context).pop();

                        // Tampilkan snackbar sukses
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Event berhasil ditambahkan')),
                        );
                      }
                    } else {
                      // Tampilkan pesan jika ada field yang kosong
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Mohon lengkapi semua field dan pilih tanggal')),
                      );
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Contoh events (bisa diganti dengan data dari database/API)

  List<Event> _getEventsForDay(DateTime day) {
    return _eventsList.where((event) {
      // Karena event.date sudah bertipe DateTime, gunakan langsung
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tahura Events',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.isAdminOrStaff)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _showAddEventDialog();
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCalendar(),
              _buildEventList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,

        // Event Loader untuk menampilkan marker
        eventLoader: _getEventsForDay,

        // Pilih hari
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },

        // Aksi saat hari dipilih
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          // Reload events untuk tanggal yang dipilih
          _loadEvents();
        },

        // Ubah format kalender
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },

        // Style Kalender
        calendarStyle: CalendarStyle(
          // Dekorasi hari ini
          todayDecoration: BoxDecoration(
            color: Colors.green.withOpacity(0.5),
            shape: BoxShape.circle,
          ),

          // Dekorasi hari yang dipilih
          selectedDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),

          // Marker (dot) untuk event
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,

          // Text Style
          defaultTextStyle: GoogleFonts.poppins(color: Colors.black),
          weekendTextStyle: GoogleFonts.poppins(color: Colors.black87),
          outsideTextStyle: GoogleFonts.poppins(color: Colors.black38),
        ),

        // Header Style
        headerStyle: HeaderStyle(
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
          formatButtonTextStyle: GoogleFonts.poppins(color: Colors.black),
          formatButtonVisible: false, // Sembunyikan tombol format
        ),

        // Konfigurasi Format Kalender
        availableCalendarFormats: {
          CalendarFormat.month: 'Month',
          CalendarFormat.twoWeeks: 'Two Weeks',
          CalendarFormat.week: 'Week',
        },
      ),
    );
  }

  void _showFullImageDialog(String imageUrl) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: animation,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  Widget _buildEventList() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: selectedEvents.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada event pada hari ini',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: selectedEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          // Gambar dengan ukuran lebih besar
                          selectedEvents[index].imageUrl != null &&
                                  selectedEvents[index].imageUrl!.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _showFullImageDialog(
                                      selectedEvents[index].imageUrl!),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(15),
                                    ),
                                    child: Image.asset(
                                      selectedEvents[index].imageUrl!,
                                      width: 120, // Lebih besar
                                      height: 120, // Seimbang
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey.withOpacity(0.3),
                                  child: Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),

                          // Informasi Event
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedEvents[index].title,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    selectedEvents[index].description,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
