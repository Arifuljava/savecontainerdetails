



import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class saveinformation extends StatefulWidget {
  const saveinformation({super.key});

  @override
  State<saveinformation> createState() => _saveinformationState();
}

class _saveinformationState extends State<saveinformation> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBHelper dbHelper = DBHelper();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    getUsersFromDatabase();
  }

  Future<void> getUsersFromDatabase() async {
    List<User> userList = await dbHelper.getUsers();
    setState(() {
      users = userList;
    });
  }

  Future<void> addUserToDatabase() async {
    User newUser = User(id: 1, name: 'John Doe', age: 25);
    await dbHelper.insertUser(newUser);
    getUsersFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          User user = users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('Age: ${user.age}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUserToDatabase,
        child: Icon(Icons.add),
      ),
    );
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();
  factory DBHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  DBHelper.internal();

  Future<Database> initDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mydatabase.db');

    // Create and open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create your tables here
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (index) {
      return User.fromMap(maps[index]);
    });
  }
}

class User {
  int id;
  String name;
  int age;

  User({
    required this.id,
    required this.name,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      age: map['age'],
    );
  }
}
