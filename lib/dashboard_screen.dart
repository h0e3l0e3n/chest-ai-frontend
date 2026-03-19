import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'result_screen.dart';
import 'auth_screens.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _userRole = 'General User';
  String _userLanguage = 'English';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('userRole') ?? 'General User';
      _userLanguage = prefs.getString('userLanguage') ?? 'English';
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthSelectionScreen()));
    }
  }

  Future<void> _handleUpload() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:3000/analyze'));
      
      // Read bytes to make this safe for Flutter Web and Desktop
      final bytes = await image.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'xray', 
        bytes, 
        filename: image.name,
      );
      request.files.add(multipartFile);
      
      // Inject Role and Language into the request fields
      request.fields['role'] = _userRole;
      request.fields['language'] = _userLanguage;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                disease: data['disease'] ?? 'Unknown',
                explanation: data['explanation'] ?? 'No explanation provided.',
                imageBytes: bytes,
                role: _userRole,
              ),
            ),
          );
        }
      } else {
        String errorMsg = 'Status: ${response.statusCode}';
        try {
          var errData = json.decode(response.body);
          if (errData['error'] != null) {
            errorMsg = errData['error'];
          }
        } catch (_) {}
        _showError('Server Error: $errorMsg');
      }
    } catch (e) {
      _showError('Failed to connect to server: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    bool isPro = _userRole == 'Medical Professional';

    return Scaffold(
      backgroundColor: isPro ? const Color(0xFF1A120E) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isPro ? 'Medical Pro Dashboard' : 'Diagnostics', 
                 style: TextStyle(color: isPro ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 4),
            Text('Welcome back, $_userName', style: TextStyle(color: isPro ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: isPro ? Colors.white : Colors.black),
            onPressed: _logout,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPro ? const Color(0xFFEC5B13) : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.person, color: isPro ? Colors.white : const Color(0xFF2563EB)),
            ),
          )
        ],
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: isPro ? const Color(0xFFEC5B13) : const Color(0xFF2563EB)),
                const SizedBox(height: 20),
                Text('Analyzing X-Ray Imagery...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPro ? Colors.white : const Color(0xFF1E293B))),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isPro ? 'Diagnostic Uploads' : 'New Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isPro ? Colors.white : const Color(0xFF334155))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isPro ? const Color(0xFF271C19) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isPro ? Colors.grey[800]! : const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isPro ? Colors.grey[800] : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.document_scanner, size: 40, color: isPro ? const Color(0xFFEC5B13) : const Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 20),
                      Text('Upload X-Ray', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isPro ? Colors.white : const Color(0xFF0F172A))),
                      const SizedBox(height: 12),
                      Text(
                        isPro ? 'DICOM / JPEG / PNG' : 'Analyze chest or bone X-ray scans with AI assistance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isPro ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 13, height: 1.4, fontWeight: isPro ? FontWeight.bold : FontWeight.normal),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPro ? const Color(0xFFEC5B13) : const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _handleUpload,
                          child: const Text('Start X-Ray Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
