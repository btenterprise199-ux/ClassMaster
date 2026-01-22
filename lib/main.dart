import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Internet Package

void main() {
  runApp(const MyApp());
}

// Global List
List<Map<String, dynamic>> globalStudents = [];

// ==============================================
// ✅ AAPKA DATABASE LINK (Pre-filled)
// ==============================================
const String databaseUrl = "https://classmaster-94e24-default-rtdb.firebaseio.com/students.json"; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassMaster Online',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= ONLINE MANAGER (GOOGLE SERVER) =================
class DataManager {
  
  // 1. SAVE DATA TO GOOGLE
  static Future<void> saveData() async {
    try {
      final response = await http.put(
        Uri.parse(databaseUrl),
        body: jsonEncode(globalStudents),
      );
      print("Saved to Cloud: ${response.statusCode}");
    } catch (e) {
      print("Error saving: $e");
    }
  }

  // 2. LOAD DATA FROM GOOGLE
  static Future<void> loadData() async {
    try {
      final response = await http.get(Uri.parse(databaseUrl));
      
      if (response.statusCode == 200 && response.body != "null") {
        List<dynamic> decoded = jsonDecode(response.body);
        globalStudents = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("Error loading: $e");
    }
  }
}

// ================= 1. SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() async {
    // App start hote hi data download karo
    await DataManager.loadData();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00695C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_sync, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('Connecting to Google Cloud...', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ================= 2. LOGIN SCREEN =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();

  void _login() {
    String name = nameController.text.trim();
    if (name.isNotEmpty) {
      if (name.toLowerCase() == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(teacherName: name)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 60, color: Color(0xFF00695C)),
            const SizedBox(height: 20),
            const Text('ClassMaster Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Data is Live on Google Server', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Enter Name (or "admin")', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Login Online', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 3. TEACHER DASHBOARD =================
class DashboardScreen extends StatefulWidget {
  final String teacherName;
  const DashboardScreen({super.key, required this.teacherName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
  
  void _refreshData() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing with Cloud...')));
    await DataManager.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = Center(child: Text("Welcome ${widget.teacherName}\n(Go to Students Tab to Add Data)"));
    if (_selectedIndex == 1) currentScreen = StudentListScreen(onUpdate: () => setState((){}));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClassMaster Cloud'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: _logout)
        ],
      ),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00695C),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
        ],
      ),
    );
  }
}

// ================= 4. STUDENT LIST (SAVES TO CLOUD) =================
class StudentListScreen extends StatefulWidget {
  final VoidCallback onUpdate; 
  const StudentListScreen({super.key, required this.onUpdate});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _nameCtrl = TextEditingController();

  void _addStudent() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Student'),
        content: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isNotEmpty) {
                // 1. List update karo
                setState(() {
                  globalStudents.add({'name': _nameCtrl.text, 'status': 'Pending', 'color': Colors.red.value});
                });
                
                // 2. Google par bhejo
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving to Google...')));
                await DataManager.saveData(); // <--- SERVER CALL
                
                _nameCtrl.clear();
                widget.onUpdate();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save Online'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: globalStudents.isEmpty
          ? const Center(child: Text('Cloud Storage Empty.\nAdd a student to test!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalStudents.length,
              itemBuilder: (context, index) {
                final student = globalStudents[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student['name'][0])),
                    title: Text(student['name']),
                    subtitle: const Text('Synced with Server', style: TextStyle(fontSize: 10, color: Colors.green)),
                    trailing: const Icon(Icons.cloud_done, color: Colors.green),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        backgroundColor: const Color(0xFF00695C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================= 5. REAL ADMIN PANEL =================
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() async {
    await DataManager.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Master Control'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllData),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black87,
            width: double.infinity,
            child: Column(
              children: [
                const Text("Total Students on Server", style: TextStyle(color: Colors.white70)),
                Text("${globalStudents.length}", style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: globalStudents.length,
              itemBuilder: (context, index) {
                 final student = globalStudents[index];
                 return ListTile(
                   title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: const Text("Status: Active"),
                   leading: const Icon(Icons.person),
                 );
              },
            ),
          ),
        ],
      ),
    );
  }
}
