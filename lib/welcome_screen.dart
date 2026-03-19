import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedRole = 'General User';
  String _selectedLanguage = 'English';
  String _userName = '';

  final List<String> _languages = [
    'English', 'Spanish (Español)', 'French (Français)', 'Mandarin (普通话)', 'Arabic (العربية)', 'Hindi (हिन्दी)'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', _selectedRole);
    await prefs.setString('userLanguage', _selectedLanguage);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = _selectedRole == 'General User';

    return Scaffold(
      backgroundColor: isUser ? const Color(0xFFF0F7FF) : const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome, $_userName', 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isUser ? const Color(0xFF1E3A8A) : Colors.white)
              ),
              const SizedBox(height: 8),
              Text(
                'Please select your profile to continue',
                style: TextStyle(fontSize: 16, color: isUser ? const Color(0xFF64748B) : Colors.grey[400])
              ),
              const SizedBox(height: 40),
              
              // Role Toggle
              Container(
                decoration: BoxDecoration(
                  color: isUser ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'General User'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isUser ? [const BoxShadow(color: Colors.black12, blurRadius: 10)] : [],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: Colors.blue[100], child: const Icon(Icons.person, color: Colors.blue)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('General User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUser ? Colors.black87 : Colors.white)),
                                Text('Personal Health Tracking', style: TextStyle(color: isUser ? Colors.grey[600] : Colors.grey[400], fontSize: 12))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'Medical Professional'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: !isUser ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: !isUser ? [const BoxShadow(color: Colors.black26, blurRadius: 10)] : [],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: Colors.blueGrey[800], child: const Icon(Icons.medical_services, color: Colors.cyan)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Medical Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: !isUser ? Colors.white : Colors.grey[800])),
                                Text('Clinical Analysis Tools', style: TextStyle(color: !isUser ? Colors.grey[400] : Colors.grey[600], fontSize: 12))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              
              // Language Selection
              Text('PREFERRED LANGUAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isUser ? Colors.grey[600] : Colors.grey[400])),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isUser ? Colors.grey[300]! : Colors.grey[700]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    dropdownColor: isUser ? Colors.white : const Color(0xFF1E293B),
                    icon: Icon(Icons.arrow_drop_down, color: isUser ? Colors.black54 : Colors.white54),
                    style: TextStyle(color: isUser ? Colors.black87 : Colors.white, fontSize: 16),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _selectedLanguage = newValue);
                    },
                    items: _languages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUser ? const Color(0xFF2563EB) : const Color(0xFF06B6D4), // blue vs cyan
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  onPressed: _saveAndContinue,
                  child: const Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
