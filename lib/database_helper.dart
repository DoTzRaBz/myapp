import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/POI.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'tahura_users.db');
    return await openDatabase(
      path,
      version: 4, // Naikkan versi
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

// Dalam DatabaseHelper
  Future<List<Map<String, dynamic>>> getEventsByDate(DateTime date) async {
    final Database db = await database;
    return await db.query(
      'events',
      where: 'date LIKE ?',
      whereArgs: ['${date.toIso8601String().split('T')[0]}%'],
    );
  }

  Future<int> deleteEvent(String title, String description) async {
    final Database db = await database;
    return await db.delete(
      'events',
      where: 'title = ? AND description = ?',
      whereArgs: [title, description],
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      payment_method TEXT,
      amount REAL,
      transaction_date TEXT,
      product_name TEXT,
      discount REAL,
      user_name TEXT 
    )
  ''');

    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT UNIQUE,
      password TEXT,
      profile_image TEXT,
      role TEXT DEFAULT 'user'
    )
  ''');

    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      image_url TEXT,
      date TEXT
    )
  ''');

    // Tambahkan akun admin dan staff
    await db.insert('users', {
      'name': 'Admin',
      'email': 'admin',
      'password': 'admin',
      'role': 'admin',
    });

    await db.insert('users', {
      'name': 'Customer Service',
      'email': 'cs',
      'password': 'cs',
      'role': 'cs', // Gunakan role berbeda untuk CS
    });

    // Tabel untuk FAQ
    await db.execute('''
    CREATE TABLE faq (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT,
      answer TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE poi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      latitude REAL,
      longitude REAL,
      imageUrl TEXT
    )
  ''');
    await _insertInitialPOIs(db);

    await db.execute('''
    CREATE TABLE ticket_prices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      adult_price REAL,
      child_price REAL,
      updated_at TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE ticket_packages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      price REAL,
      description TEXT,
      created_at TEXT
    )
  ''');

    // Masukkan harga default
    await db.insert('ticket_prices', {
      'adult_price': 50000,
      'child_price': 25000,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final userBatch = [
      {
        'name': 'John Doe',
        'email': 'john.doe@gmail.com',
        'password': 'password123',
        'role': 'user',
        'profile_image': ''
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@gmail.com',
        'password': 'password456',
        'role': 'user',
        'profile_image': ''
      },
      {
        'name': 'Mike Johnson',
        'email': 'mike.johnson@gmail.com',
        'password': 'password789',
        'role': 'user',
        'profile_image': ''
      },
      {
        'name': 'Sarah Williams',
        'email': 'sarah.williams@gmail.com',
        'password': 'password101',
        'role': 'user',
        'profile_image': ''
      },
      {
        'name': 'David Brown',
        'email': 'david.brown@gmail.com',
        'password': 'password202',
        'role': 'user',
        'profile_image': ''
      },
      {
        'name': 'Emily Davis',
        'email': 'emily.davis@gmail.com',
        'password': 'password303',
        'role': 'user',
        'profile_image': ''
      }
    ];

    // Batch insert untuk users
    Batch batch = db.batch();
    for (var user in userBatch) {
      batch.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);

    // Batch insert untuk transaksi
    final dummyTransactions = [
      {
        'payment_method': 'debit',
        'amount': 150000.0,
        'transaction_date': '2023-12-15T10:30:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 1)',
        'user_name': 'john.doe@gmail.com'
      },
      // Januari 2024
      {
        'payment_method': 'e-wallet',
        'amount': 200000.0,
        'transaction_date': '2024-01-20T14:45:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 3, Anak: 2)',
        'user_name': 'jane.smith@gmail.com'
      },
      // Februari 2024
      {
        'payment_method': 'debit',
        'amount': 100000.0,
        'transaction_date': '2024-02-10T09:15:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 1, Anak: 1)',
        'user_name': 'mike.johnson@gmail.com'
      },
      // Maret 2024
      {
        'payment_method': 'e-wallet',
        'amount': 180000.0,
        'transaction_date': '2024-03-05T16:20:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 2)',
        'user_name': 'sarah.williams@gmail.com'
      },
      // April 2024
      {
        'payment_method': 'debit',
        'amount': 220000.0,
        'transaction_date': '2024-04-18T11:40:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 4, Anak: 1)',
        'user_name': 'david.brown@gmail.com'
      },
      // Mei 2024
      {
        'payment_method': 'e-wallet',
        'amount': 130000.0,
        'transaction_date': '2024-05-22T13:55:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 1, Anak: 2)',
        'user_name': 'emily.davis@gmail.com'
      },
      // Juni 2024
      {
        'payment_method': 'debit',
        'amount': 170000.0,
        'transaction_date': '2024-06-07T15:10:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 1)',
        'user_name': 'john.doe@gmail.com'
      },
      // Juli 2024
      {
        'payment_method': 'e-wallet',
        'amount': 190000.0,
        'transaction_date': '2024-07-12T17:25:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 3, Anak: 1)',
        'user_name': 'jane.smith@gmail.com'
      },
      // Agustus 2024
      {
        'payment_method': 'debit',
        'amount': 140000.0,
        'transaction_date': '2024-08-03T08:45:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 1, Anak: 2)',
        'user_name': 'mike.johnson@gmail.com'
      },
      // September 2024
      {
        'payment_method': 'e-wallet',
        'amount': 210000.0,
        'transaction_date': '2024-09-16T12:30:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 3)',
        'user_name': 'sarah.williams@gmail.com'
      },
      // Oktober 2024
      {
        'payment_method': 'debit',
        'amount': 160000.0,
        'transaction_date': '2024-10-25T14:15:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 2, Anak: 1)',
        'user_name': 'david.brown@gmail.com'
      },
      // November 2024
      {
        'payment_method': 'e-wallet',
        'amount': 185000.0,
        'transaction_date': '2024-11-08T16:50:00.000Z',
        'product_name': 'Tiket Perjalanan (Dewasa: 3, Anak: 1)',
        'user_name': 'emily.davis@gmail.com'
      }
    ];

    Batch transactionBatch = db.batch();
    for (var transaction in dummyTransactions) {
      transactionBatch.insert('transactions', transaction);
    }
    await transactionBatch.commit(noResult: true);
  }

  Future<void> _insertInitialPOIs(Database db) async {
    List<PointOfInterest> initialPOIs = [
      PointOfInterest(
        id: 1,
        name: 'Tahura',
        description:
            'Selamat datang di Taman Hutan Raya Bandung! Tempat yang sempurna untuk menikmati keindahan alam, trekking, dan melihat berbagai flora dan fauna. Jangan lewatkan juga berbagai spot foto yang menarik!',
        latitude: -6.858110,
        longitude: 107.630884,
        imageUrl: 'lib/assets/tahura1.png',
      ),
      PointOfInterest(
        id: 2,
        name: 'Goa Jepang',
        description:
            'Goa Jepang adalah situs bersejarah yang dibangun selama Perang Dunia II. Anda bisa menjelajahi lorong-lorong goa dan belajar tentang sejarah yang menyertainya.',
        latitude: -6.856650,
        longitude: 107.632461,
        imageUrl: 'lib/assets/tahura8.png',
      ),
      PointOfInterest(
        id: 3,
        name: 'Penangkaran Rusa',
        description:
            'Penangkaran Rusa di Tahura Bandung adalah tempat yang ideal untuk melihat rusa-rusa yang dilindungi. Anda dapat memberikan makan dan berinteraksi dengan hewan-hewan yang lucu ini.',
        latitude: -6.843673,
        longitude: 107.648136,
        imageUrl: 'lib/assets/tahura6.png',
      ),
      PointOfInterest(
        id: 4,
        name: 'Goa Belanda',
        description:
            'Goa Belanda adalah salah satu goa yang menarik untuk dikunjungi. Dikenal karena sejarahnya yang kaya dan formasi batuan yang unik, goa ini menawarkan pengalaman petualangan yang tak terlupakan.',
        latitude: -6.8542543,
        longitude: 107.6377157,
        imageUrl: 'lib/assets/tahura7.png',
      ),
      PointOfInterest(
        id: 5,
        name: 'Curug Omas',
        description:
            'Curug Omas adalah air terjun yang indah dan menawan. Suara gemuruh air dan pemandangan alam sekitarnya menjadikannya tempat yang sempurna untuk bersantai dan menikmati keindahan alam.',
        latitude: -6.834373,
        longitude: 107.658130,
        imageUrl: 'lib/assets/tahura5.png',
      ),
    ];

    for (var poi in initialPOIs) {
      await db.insert(
        'poi',
        poi.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final Database db = await database;

    try {
      // Tambahkan logging untuk debugging
      final transactions =
          await db.query('transactions', orderBy: 'transaction_date DESC');

      print('Jumlah transaksi: ${transactions.length}');
      print('Detail transaksi: $transactions');

      return transactions;
    } catch (e) {
      print('Error mengambil transaksi: $e');
      return [];
    }
  }

// Method untuk mengambil total pendapatan
  Future<double> getTotalRevenue() async {
    final Database db = await database;
    var result =
        await db.rawQuery('SELECT SUM(amount) as total FROM transactions');
    return result.first['total'] as double? ?? 0.0;
  }

  // Tambahkan method onUpgrade untuk migrasi database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');
    }
  }

  // Tambahkan method untuk update profile image
  Future<int> updateProfileImage(String email, String imagePath) async {
    final Database db = await database;
    return await db.update(
      'users',
      {'profile_image': imagePath},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> insertUser(String name, String email, String password) async {
    final Database db = await database;
    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user', // Tambahkan role default
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final Database db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> loginUser(String email, String password) async {
    final db = await database;

    // Tambahkan logging yang lebih detail
    print('Login Attempt:');
    print('Email: $email');
    print('Password: $password');

    // Cetak semua users untuk debugging
    final allUsers = await db.query('users');
    print('All Users in Database:');
    allUsers.forEach((user) {
      print(
          'User: ${user['email']}, Password: ${user['password']}, Role: ${user['role']}');
    });

    // Query untuk mencari user
    final List<Map<String, dynamic>> users = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);

    print('Login Query Result:');
    print('Users Found: ${users.length}');
    if (users.isNotEmpty) {
      print('Matched User Details: ${users.first}');
    }

    // Kembalikan true jika user ditemukan
    return users.isNotEmpty;
  }

  Future<String?> getUserRole(String email) async {
    final db = await database;

    print('Fetching role for email: $email');

    final List<Map<String, dynamic>> users = await db.query('users',
        columns: ['role', 'email', 'password'],
        where: 'email = ?',
        whereArgs: [email]);

    print('Role Query Result:');
    print('Users Found: ${users.length}');
    users.forEach((user) {
      print('User: ${user['email']}, Role: ${user['role']}');
    });

    return users.isNotEmpty ? users.first['role'] : null;
  }

  Future<int> insertTransaction(String paymentMethod, double amount) async {
    final Database db = await database;
    return await db.insert(
      'transactions',
      {
        'payment_method': paymentMethod,
        'amount': amount,
        'transaction_date':
            DateTime.now().toIso8601String(), // Simpan tanggal saat ini
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertDetailedTransaction({
    required String paymentMethod,
    required double amount,
    required String productName,
    String? userName,
    double discount = 0.0,
    int? adultTickets,
    int? childTickets,
  }) async {
    final Database db = await database;

    // Gabungkan informasi tiket ke dalam product_name
    String combinedProductName = productName;
    if (adultTickets != null && childTickets != null) {
      combinedProductName += ' (Dewasa: $adultTickets, Anak: $childTickets)';
    }

    return await db.insert(
      'transactions',
      {
        'payment_method': paymentMethod,
        'amount': amount,
        'product_name': combinedProductName,
        'discount': discount,
        'transaction_date': DateTime.now().toIso8601String(),
        'user_name': userName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertFAQ(String question, String answer) async {
    final Database db = await database;
    return await db.insert(
      'faq',
      {'question': question, 'answer': answer},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllFAQs() async {
    final Database db = await database;
    return await db.query('faq');
  }

  Future<int> deleteFAQ(int id) async {
    final Database db = await database;
    return await db.delete(
      'faq',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePOI(int id, String name, String description,
      double latitude, double longitude) async {
    final Database db = await database;
    print(
        'Updating POI: $id, $name, $description, $latitude, $longitude'); // Logging
    return await db.update(
      'poi',
      {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePOI(int id) async {
    final Database db = await database;
    return await db.delete(
      'poi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PointOfInterest>> getAllPOIs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query('poi');
    return results
        .map((e) => PointOfInterest(
              id: e['id'],
              name: e['name'],
              description: e['description'],
              latitude: e['latitude'],
              longitude: e['longitude'],
              imageUrl: e['imageUrl'], // Gunakan nilai dari database
            ))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final Database db = await database;

    try {
      final List<Map<String, dynamic>> transactions = await db.rawQuery('''
      SELECT * FROM transactions 
      WHERE transaction_date BETWEEN ? AND ?
      ORDER BY transaction_date ASC
    ''', [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);

      return transactions;
    } catch (e) {
      print('Error fetching transactions by date range: $e');
      return [];
    }
  }

  Future<void> insertEvent(
      String title, String description, String imageUrl, DateTime date) async {
    try {
      final db = await database;
      await db.insert(
        'events',
        {
          'title': title,
          'description': description,
          'image_url': imageUrl, // Pastikan ini disimpan
          'date': date.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Event berhasil dimasukkan: $title'); // Tambahkan log
    } catch (e) {
      print('Gagal memasukkan event: $e');
    }
  }

// Tambahkan method untuk menyimpan harga tiket
  Future<int> updateTicketPrices(double adultPrice, double childPrice) async {
    final Database db = await database;
    return await db.insert(
      'ticket_prices',
      {
        'adult_price': adultPrice,
        'child_price': childPrice,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Method untuk mengambil harga tiket terbaru
  Future<Map<String, dynamic>?> getLatestTicketPrices() async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'ticket_prices',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

// Method untuk menyimpan paket tiket baru
  Future<int> insertTicketPackage(
      String name, double price, String description) async {
    final Database db = await database;
    return await db.insert(
      'ticket_packages',
      {
        'name': name,
        'price': price,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Method untuk mengambil semua paket tiket
  Future<List<Map<String, dynamic>>> getAllTicketPackages() async {
    final Database db = await database;
    return await db.query('ticket_packages', orderBy: 'created_at DESC');
  }

  // Tambahkan method ini di DatabaseHelper
  Future<void> printAllEvents() async {
    try {
      final db = await database;
      final events = await db.query('events');
      print('Semua events di database:');
      for (var event in events) {
        print(event);
      }
    } catch (e) {
      print('Gagal mencetak events: $e');
    }
  }
}
