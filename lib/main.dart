import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Internet Package

void main() {
  runApp(const MyApp());
}

// Global List
List<Map<String, dynamic>> globalStudents = [];

// ==============================================
// ✅ AAPKA PERSONAL DATABASE LINK
// ==============================================
const String databaseUrl = "https://classmaster-94e24-default-rtdb.firebaseio.com/students.json"; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassMaster Pro',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        primaryColor: const Color(0xFF00796B), // Teal Green
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= ONLINE MANAGER (API LOGIC) =================
class DataManager {
  // Data Save (Internet par)
  static Future<void> saveData() async {
    try {
      await http.put(Uri.parse(databaseUrl), body: jsonEncode(globalStudents));
    } catch (e) {
      print("Error saving: $e");
    }
  }

  // Data Load (Internet se)
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
    _connect();
  }

  void _connect() async {
    // Start hote hi data download karo
    await DataManager.loadData();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.cloud_sync, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('ClassMaster Cloud', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Color(0xFF00796B)),
            const SizedBox(height: 10),
            const Text('Connecting to Your Database...', style: TextStyle(color: Colors.grey)),
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
  final _nameCtrl = TextEditingController();

  void _login() {
    if (_nameCtrl.text.isNotEmpty) {
      if (_nameCtrl.text.toLowerCase() == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminPanel()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardScreen(name: _nameCtrl.text)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFF00796B), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.school, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text("ClassMaster", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              
              const SizedBox(height: 50),
              const Text("Welcome Back,", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Sign in to access live data.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: "Enter Username",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Login Online", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 3. DASHBOARD (PROFESSIONAL DESIGN) =================
class DashboardScreen extends StatefulWidget {
  final String name;
  const DashboardScreen({super.key, required this.name});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  void _refresh() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing Data...')));
    await DataManager.loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _tab == 0 ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.person, color: Color(0xFF00796B))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Hello, ${widget.name} 👋", style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Status: Online", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.black), onPressed: _refresh),
        ],
      ) : null,
      
      body: _tab == 0 ? _buildDashboard() : StudentList(onUpdate: () => setState((){})),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: const Color(0xFF00796B),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Students"),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _statCard("TOTAL STUDENTS", "${globalStudents.length}", Colors.green)),
              const SizedBox(width: 15),
              Expanded(child: _statCard("FEES PENDING", "₹${globalStudents.length * 1000}", Colors.orange)),
            ],
          ),
          const SizedBox(height: 30),
          
          const Text("QUICK ACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 15),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
            children: [
              _actionCard("Create Exam", Icons.description, true),
              _actionCard("Fees", Icons.currency_rupee, false),
              _actionCard("Attendance", Icons.check_circle_outline, false),
              _actionCard("Add Student", Icons.person_add_alt, false),
              _actionCard("Locker", Icons.folder_open, false),
              _actionCard("Schedule", Icons.calendar_today, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text("Live Sync", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _actionCard(String label, IconData icon, bool isHighlighted) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF00796B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isHighlighted ? Colors.white : const Color(0xFF00796B), size: 28),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: isHighlighted ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ================= 4. STUDENT LIST (CONNECTED) =================
class StudentList extends StatefulWidget {
  final VoidCallback onUpdate;
  const StudentList({super.key, required this.onUpdate});
  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final _textCtrl = TextEditingController();

  void _add() async {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("New Student"),
      content: TextField(controller: _textCtrl, decoration: const InputDecoration(labelText: "Student Name", border: OutlineInputBorder())),
      actions: [ElevatedButton(onPressed: () async {
        if (_textCtrl.text.isNotEmpty) {
          globalStudents.add({'name': _textCtrl.text});
          
          // API CALL: SAVE TO YOUR DATABASE
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saving to Cloud...')));
          await DataManager.saveData();
          
          widget.onUpdate();
          _textCtrl.clear();
          Navigator.pop(c);
        }
      }, child: const Text("Save Online"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("All Students"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: globalStudents.isEmpty 
        ? const Center(child: Text("Database Empty.\nAdd a student to test connection!")) 
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: globalStudents.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE0F2F1),
                    child: Text(globalStudents[index]['name'][0], style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(globalStudents[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Saved in Firebase", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  trailing: const Icon(Icons.cloud_done, color: Colors.green, size: 18),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: const Color(0xFF00796B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================= 5. ADMIN PANEL =================
class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Console"), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Students in DB", style: TextStyle(color: Colors.grey)),
            Text("${globalStudents.length}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: (){ DataManager.loadData(); }, child: const Text("Refresh Data"))
          ],
        ),
      ),
    );
  }
}
