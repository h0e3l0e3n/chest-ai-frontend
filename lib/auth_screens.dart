import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.medical_services_outlined, size: 40, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 24),
              const Text('MediScan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              const Text(
                'Secure access to professional diagnostic insights and patient data.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              
              // Google Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                  label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MockGoogleAccountsScreen()));
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Email Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text('Login with Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailLoginScreen())),
                ),
              ),
              const SizedBox(height: 24),
              
              // Create Account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to MediScan? ', style: TextStyle(color: Color(0xFF64748B))),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
                    child: const Text('Create account', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class MockGoogleAccountsScreen extends StatelessWidget {
  const MockGoogleAccountsScreen({super.key});

  Future<void> _selectGoogleAccount(BuildContext context, String name, String email) async {
    // Add user to DB directly as a "Google" user so it persists
    await DatabaseHelper.instance.registerUser(name, email, 'google_oauth_mock_password');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    if (context.mounted) {
      final String? role = prefs.getString('userRole');
      if (role == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose an account', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.blue[100], child: const Text('JD', style: TextStyle(color: Colors.blue))),
            title: const Text('John Doe'),
            subtitle: const Text('johndoe@gmail.com'),
            onTap: () => _selectGoogleAccount(context, 'John Doe', 'johndoe@gmail.com'),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green[100], child: const Text('JS', style: TextStyle(color: Colors.green))),
            title: const Text('Jane Smith'),
            subtitle: const Text('janesmith.work@gmail.com'),
            onTap: () => _selectGoogleAccount(context, 'Jane Smith', 'janesmith.work@gmail.com'),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.orange[100], child: const Text('AW', style: TextStyle(color: Colors.orange))),
            title: const Text('Alex Wong'),
            subtitle: const Text('alex.wong@gmail.com'),
            onTap: () => _selectGoogleAccount(context, 'Alex Wong', 'alex.wong@gmail.com'),
          ),
        ],
      ),
    );
  }
}

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}
class _EmailLoginScreenState extends State<EmailLoginScreen> {
  List<Map<String, dynamic>> _savedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      _savedUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _login(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', user['email']);
    await prefs.setString('userName', user['name'] ?? 'User');
    
    if (mounted) {
      final String? role = prefs.getString('userRole');
      if (role == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Saved Account', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _savedUsers.isEmpty 
          ? const Center(child: Text("No saved accounts found. Please create one.", style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              itemCount: _savedUsers.length,
              itemBuilder: (context, index) {
                final user = _savedUsers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email']),
                  onTap: () => _login(user),
                );
              },
            ),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}
class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    // Email Validation Pattern
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address')));
      return;
    }

    setState(() => _isLoading = true);
    final id = await DatabaseHelper.instance.registerUser(name, email, password);
    setState(() => _isLoading = false);

    if (id != -1 && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name); // Save name locally

      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration failed (Email might exist)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC5B13)), // primary orange
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
