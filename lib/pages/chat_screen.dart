import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '/edit_faq_screen.dart';
import '../models/message.dart';
import '../utils/size.dart';
import 'package:myapp/database_helper.dart';

class ChatScreen extends StatefulWidget {
  final bool isAdminOrStaff; // Tambahkan parameter ini

  const ChatScreen({Key? key, required this.isAdminOrStaff}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userMessage = TextEditingController();
  bool isLoading = false;
  bool isFAQMode = true;

  static const apiKey = "AIzaSyC77cRt4Wvl9MFe98AsQqzKpiJkMCkxscA";
  final List<Message> _messages = [];
  late GenerativeModel model;

  // List FAQ dengan desain yang lebih informatif
List<Map<String, dynamic>> faqList = [
  {
    'question': 'Apa itu Tahura Bandung?',
    'answer':
        'Tahura Bandung (Taman Hutan Raya) adalah kawasan hutan lindung yang terletak di Bandung, Jawa Barat. Merupakan area konservasi dengan keanekaragaman hayati yang tinggi.'
  },
  {
    'question': 'Destinasi apa saja yang ada di Tahura?',
    'answer':
        'Beberapa destinasi di Tahura Bandung meliputi: Kebun Raya Bandung, Jalur Pendakian, Area Perkemahan, Hutan Pinus, dan Spot Fotografi Alam.'
  },
  {
    'question': 'Cara membuat akun di aplikasi?',
    'answer':
        'Anda dapat membuat akun melalui menu Register di aplikasi. Isi nama lengkap, email, dan password, lalu klik tombol Register.'
  },
  {
    'question': 'Bagaimana cara melihat cuaca di Tahura?',
    'answer':
        'Gunakan fitur Weather di aplikasi. Anda akan melihat informasi suhu, kelembapan, dan kondisi cuaca terkini di kawasan Tahura Bandung.'
  },
  {
    'question': 'Apa yang harus dilakukan untuk melihat event yang akan datang?',
    'answer':
        'Anda dapat mengunjungi fitur Event di aplikasi untuk melihat daftar event yang akan datang. Anda juga bisa menambah event baru melalui tombol tambah di halaman event.'
  },
  {
    'question': 'Bagaimana cara menggunakan fitur chat dengan AI?',
    'answer':
        'Fitur Chat AI dapat diakses melalui tombol chat di halaman utama. Anda dapat mengajukan pertanyaan dan mendapatkan jawaban secara real-time.'
  },
  {
    'question': 'Apakah saya bisa mengubah foto profil saya?',
    'answer':
        'Ya, Anda dapat mengubah foto profil Anda melalui halaman Profil. Cukup ketuk foto profil Anda dan pilih gambar dari galeri Anda.'
  },
  {
    'question': 'Bagaimana cara mengakses peta lokasi POI?',
    'answer':
        'Anda dapat mengakses peta lokasi POI (Point of Interest) melalui menu Peta di aplikasi. Di sana, Anda akan melihat berbagai lokasi menarik di sekitar Tahura.'
  },
  {
    'question': 'Apa yang harus dilakukan jika saya mengalami masalah saat menggunakan aplikasi?',
    'answer':
        'Jika Anda mengalami masalah, silakan coba untuk menutup dan membuka kembali aplikasi. Jika masalah berlanjut, hubungi customer service melalui menu Kontak.'
  }
];
  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _loadFAQs();
  }

  void _loadFAQs() async {
    final faqs = await DatabaseHelper().getAllFAQs();
    setState(() {
      // Gabungkan FAQ yang sudah ada dengan yang baru dari database
      faqList = [
        ...faqList, // Menambahkan FAQ yang sudah ada
        ...faqs
            .map((faq) => {
                  'id': faq['id'].toString(),
                  'question': faq['question'],
                  'answer': faq['answer']
                })
            .toList(),
      ];
    });
  }

  void sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      isLoading = true;
    });

    final context = '''
    Kamu adalah asisten AI untuk Aplikasi Tahura Bandung. 
    Fokus pada informasi seputar:
    - Lokasi Tahura
    - Destinasi di Tahura
    - Kondisi alam
    - Aktivitas di kawasan
    ''';

    final content = [Content.text('$context\n\nPertanyaan: $message')];

    try {
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Maaf, saya tidak mengerti.",
          date: DateTime.now(),
        ));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "Terjadi kesalahan. Coba lagi.",
          date: DateTime.now(),
        ));
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isFAQMode ? 'FAQ Tahura' : 'Chat AI Tahura',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          IconButton(
            icon:
                Icon(isFAQMode ? Icons.chat : Icons.list, color: Colors.white),
            onPressed: () {
              setState(() {
                isFAQMode = !isFAQMode;
              });
            },
          ),
          if (isFAQMode &&
              widget.isAdminOrStaff) // Hanya tampilkan jika admin atau staff
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _addFAQ,
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
              Expanded(
                child: isFAQMode ? _buildFAQList() : _buildChatInterface(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQList() {
    return ListView.builder(
      itemCount: faqList.length,
      itemBuilder: (context, index) {
        final faq = faqList[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question']!,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.green[800]),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['answer']!,
                      style: GoogleFonts.roboto(color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    if (widget
                        .isAdminOrStaff) // Tampilkan tombol hanya untuk admin/staff
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _editFAQ(index); // Panggil fungsi edit
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _deleteFAQ(int.parse(
                                  faq['id']!)); // Panggil fungsi hapus
                            },
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.green[700]!.withOpacity(0.8)
              : Colors.grey[800]!.withOpacity(0.8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft:
                message.isUser ? Radius.circular(15) : Radius.circular(0),
            bottomRight:
                message.isUser ? Radius.circular(0) : Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Text(
          message.message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: medium, vertical: small),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _userMessage,
              decoration: InputDecoration(
                hintText: 'Tanya seputar Tahura...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(xlarge),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: IconButton(
              icon: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Icon(Icons.send, color: Colors.white),
              onPressed:
                  isLoading || _userMessage.text.isEmpty ? null : sendMessage,
            ),
          )
        ],
      ),
    );
  }

  void _addFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFAQScreen(
          onUpdate: (String question, String answer) async {
            await DatabaseHelper()
                .insertFAQ(question, answer); // Simpan ke database
            _loadFAQs(); // Muat ulang FAQ setelah ditambahkan
          },
        ),
      ),
    );
  }

  void _editFAQ(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFAQScreen(
          question: faqList[index]['question'],
          answer: faqList[index]['answer'],
          onUpdate: (String question, String answer) async {
            await DatabaseHelper().deleteFAQ(
                int.parse(faqList[index]['id']!)); // Hapus FAQ yang lama
            await DatabaseHelper()
                .insertFAQ(question, answer); // Simpan yang baru
            _loadFAQs(); // Muat ulang FAQ setelah diedit
          },
        ),
      ),
    );
  }

  void _deleteFAQ(int id) async {
    await DatabaseHelper().deleteFAQ(id);
    _loadFAQs(); // Muat ulang FAQ setelah dihapus
  }
}
