import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ================= GLOBAL DATA (REAL-TIME STORAGE) =================
// Shuru mein list khali rahegi (0 Students)
List<Map<String, dynamic>> globalStudents = [];

// Har student ki monthly fee (Calculation ke liye)
const double monthlyFee = 1000.0; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassMaster',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
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
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00695C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('ClassMaster', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 60, color: Color(0xFF00695C)),
            const SizedBox(height: 20),
            const Text('Teacher Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Enter Your Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => DashboardScreen(teacherName: nameController.text))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 3. DASHBOARD (REAL-TIME UPDATES) =================
class DashboardScreen extends StatefulWidget {
  final String teacherName;
  const DashboardScreen({super.key, required this.teacherName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  // Real-time calculation helpers
  int get totalStudents => globalStudents.length;
  
  double get totalPendingFees {
    // Count students who are 'Unpaid'
    int unpaidCount = globalStudents.where((s) => s['status'] == 'Pending').length;
    return unpaidCount * monthlyFee;
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen = _buildHomeContent();
    if (_selectedIndex == 1) currentScreen = StudentListScreen(onUpdate: _refresh);
    if (_selectedIndex == 2) currentScreen = const ResourceLockerScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _selectedIndex == 0 
        ? AppBar(
            title: Text('Hi, ${widget.teacherName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Admin Panel hatakar bas chota Settings icon diya hai
              IconButton(icon: const Icon(Icons.settings, color: Colors.grey), onPressed: (){
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings are restricted')));
              })
            ],
          )
        : null,
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00695C),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Library'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('TOTAL STUDENTS', '$totalStudents', Colors.blue)),
              const SizedBox(width: 16),
              // Shows dynamically calculated fees
              Expanded(child: _buildStatCard('PENDING FEES', '₹${totalPendingFees.toStringAsFixed(0)}', Colors.orange)),
            ],
          ),
          const SizedBox(height: 30),
          const Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
               _buildActionBtn('Add Student', Icons.person_add, () {
                 setState(() => _selectedIndex = 1); // Go to student list
               }),
               _buildActionBtn('Create Exam', Icons.description, () {}),
               _buildActionBtn('Collect Fee', Icons.currency_rupee, () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [Icon(icon, color: const Color(0xFF00695C)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12))]),
      ),
    );
  }
}

// ================= 4. STUDENT LIST (WORKING BUTTONS) =================
class StudentListScreen extends StatefulWidget {
  final VoidCallback onUpdate; // Parent ko batane ke liye
  const StudentListScreen({super.key, required this.onUpdate});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _nameCtrl = TextEditingController();

  // Function to Add Student
  void _addStudent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 10),
            const Text('Default Fee Status: Pending (₹1000)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.isNotEmpty) {
                setState(() {
                  globalStudents.add({
                    'name': _nameCtrl.text,
                    'status': 'Pending', // By default Pending
                    'color': Colors.red
                  });
                });
                _nameCtrl.clear();
                widget.onUpdate(); // Update Dashboard stats
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Student'),
          )
        ],
      ),
    );
  }

  // Toggle Fee Status (Pending <-> Paid)
  void _toggleFeeStatus(int index) {
    setState(() {
      if (globalStudents[index]['status'] == 'Pending') {
        globalStudents[index]['status'] = 'Paid';
        globalStudents[index]['color'] = Colors.green;
      } else {
        globalStudents[index]['status'] = 'Pending';
        globalStudents[index]['color'] = Colors.red;
      }
    });
    widget.onUpdate(); // Update Dashboard stats
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: globalStudents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No students yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Click + to add your first student', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: globalStudents.length,
              itemBuilder: (context, index) {
                final student = globalStudents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student['name'][0])),
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tap button to change status'),
                    trailing: InkWell(
                      onTap: () => _toggleFeeStatus(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: student['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: student['color'])
                        ),
                        child: Text(
                          student['status'],
                          style: TextStyle(color: student['color'], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        label: const Text('Add Student', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF00695C),
      ),
    );
  }
}

class ResourceLockerScreen extends StatelessWidget {
  const ResourceLockerScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Library Empty'));
}
        ),
      ),
    );
  }
  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

// ================= 3. LOGIN SCREEN =================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 60, color: Color(0xFF1565C0)),
              const SizedBox(height: 20),
              const Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const TextField(decoration: InputDecoration(hintText: 'Mobile Number', prefixText: '+91 ', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherProfileSetup())),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                  child: const Text('Get OTP', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 4. PROFILE SETUP =================
class TeacherProfileSetup extends StatelessWidget {
  const TeacherProfileSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'Coaching Name', border: OutlineInputBorder())),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Complete Setup', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= 5. DASHBOARD SCREEN =================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final Color primaryTeal = const Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('ClassMaster', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello, Sita 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatCard('TOTAL STUDENTS', '128', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('PENDING FEES', '₹45k', Colors.orange)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('QUICK ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildLinkButton(context, 'Create Exam', Icons.description, const GenerateExamScreen(), true),
                _buildLinkButton(context, 'Reports', Icons.analytics, const ReportCardScreen(), false),
                _buildLinkButton(context, 'Locker', Icons.archive, const ResourceLockerScreen(), false),
                _buildActionButton('Fees', Icons.money, false),
                _buildActionButton('Attendance', Icons.check_circle, false),
                _buildActionButton('Schedule', Icons.calendar_today, false),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentListScreen()));
        },
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildActionButton(String label, IconData icon, bool isActive) {
    return Container(
      decoration: BoxDecoration(color: isActive ? primaryTeal : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: isActive ? Colors.white : primaryTeal),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontSize: 12)),
      ]),
    );
  }

  Widget _buildLinkButton(BuildContext context, String label, IconData icon, Widget page, bool isActive) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: _buildActionButton(label, icon, isActive),
    );
  }
}

// ================= 6. GENERATE EXAM (Step 1) =================
class GenerateExamScreen extends StatelessWidget {
  const GenerateExamScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Exam')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Paper Blueprint', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildOption('Education Board', 'Select Board (CBSE)'),
            _buildOption('Academic Level', 'Select Class'),
            _buildOption('Subject', 'Select Subject'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BlueprintDesignScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Next Step', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildOption(String title, String subtitle) {
    return Card(child: ListTile(title: Text(title), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_drop_down)));
  }
}

// ================= 7. BLUEPRINT DESIGN (Step 2) =================
class BlueprintDesignScreen extends StatelessWidget {
  const BlueprintDesignScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Topics')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('Quantum Mechanics'), subtitle: Text('5 Easy, 2 Hard'), leading: Icon(Icons.check_box, color: Colors.teal)),
                ListTile(title: Text('Thermodynamics'), subtitle: Text('Not Selected'), leading: Icon(Icons.check_box_outline_blank)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuestionReviewScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Generate Paper', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= 8. REVIEW QUESTIONS (Step 3) =================
class QuestionReviewScreen extends StatelessWidget {
  const QuestionReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Questions')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                Card(child: ListTile(title: Text('Q1. What is Heisenberg Principle?'), subtitle: Text('3 Marks • Theory'), trailing: Icon(Icons.edit))),
                Card(child: ListTile(title: Text('Q2. Calculate photon energy.'), subtitle: Text('5 Marks • Numerical'), trailing: Icon(Icons.edit))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExamPreviewScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: const Text('Finalize', style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= 9. PREVIEW & SHARE (Step 4) =================
class ExamPreviewScreen extends StatelessWidget {
  const ExamPreviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Final Preview')),
      body: Center(
        child: Container(
          width: 300, height: 400, color: Colors.white,
          child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.picture_as_pdf, size: 50), Text('Physics Paper.pdf')])),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20), color: Colors.white,
        child: SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: () {}, icon: const Icon(Icons.share, color: Colors.white), label: const Text('Share PDF', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
      ),
    );
  }
}

// ================= 10. STUDENT LIST (CRM) =================
class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _studentTile('Arjun Sharma', 'Paid', Colors.green),
          _studentTile('Sarah Jenkins', 'Pending', Colors.red),
          _studentTile('Marcus Vane', 'Paid', Colors.green),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}, backgroundColor: const Color(0xFF00695C), child: const Icon(Icons.add, color: Colors.white)),
    );
  }
  Widget _studentTile(String name, String status, Color color) {
    return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(name), trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)))));
  }
}

// ================= 11. RESOURCE LOCKER =================
class ResourceLockerScreen extends StatelessWidget {
  const ResourceLockerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: GridView.count(
        crossAxisCount: 2, padding: const EdgeInsets.all(16), crossAxisSpacing: 10, mainAxisSpacing: 10,
        children: [
          _folder(context, 'Physics 12', Colors.blue[100]!),
          _folder(context, 'Maths 10', Colors.orange[100]!),
        ],
      ),
    );
  }
  Widget _folder(BuildContext context, String name, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecureFileViewer())),
      child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.folder, size: 40), Text(name)])),
    );
  }
}

// ================= 12. SECURE VIEWER =================
class SecureFileViewer extends StatelessWidget {
  const SecureFileViewer({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Secure View', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: const Center(child: Text('DO NOT COPY', style: TextStyle(color: Colors.white24, fontSize: 40, fontWeight: FontWeight.bold))),
    );
  }
}

// ================= 13. REPORT CARD =================
class ReportCardScreen extends StatelessWidget {
  const ReportCardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 100, color: Colors.teal),
            const Text('Student Performance Graph'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: (){}, child: const Text('Download Report PDF'))
          ],
        ),
      ),
    );
  }
}
