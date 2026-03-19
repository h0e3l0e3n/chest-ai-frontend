import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String disease;
  final String explanation;
  final Uint8List imageBytes;
  final String role; // 'General User' or 'Medical Professional'

  const ResultScreen({
    super.key,
    required this.disease,
    required this.explanation,
    required this.imageBytes,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    bool isPro = role == 'Medical Professional';
    bool isSerious = disease.isNotEmpty && 
                     !disease.toLowerCase().contains('normal') && 
                     !disease.toLowerCase().contains('healthy') &&
                     !disease.toLowerCase().contains('clear');

    return Scaffold(
      backgroundColor: isPro ? const Color(0xFF0A0A0C) : const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: isPro ? const Color(0xFF16161A) : Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isPro ? Colors.white : const Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isPro ? 'Diagnostic Results' : 'Analysis Result', 
          style: TextStyle(color: isPro ? Colors.white : const Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Insight Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isPro ? const Color(0xFF16161A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isPro ? const Color(0xFF334155) : const Color(0xFFDBEAFE)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPro ? Colors.grey[800] : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.analytics, color: isPro ? const Color(0xFFEF4444) : const Color(0xFF2563EB), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isPro ? 'AI Clinical Insights' : 'AI Insight',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isPro ? Colors.white : const Color(0xFF1E3A8A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(isPro ? 'DETECTED MARKERS' : 'Detected Condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isPro ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(
                      disease.isEmpty ? 'Unknown' : disease,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isPro ? Colors.black26 : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(left: BorderSide(color: isPro ? const Color(0xFFEF4444) : const Color(0xFF2563EB), width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isPro ? 'Diagnostic Summary:' : 'Clinical Details:', style: TextStyle(fontWeight: FontWeight.bold, color: isPro ? Colors.white : const Color(0xFF1E3A8A), fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            explanation.isEmpty ? 'No detailed explanation provided by the server.' : explanation,
                            style: TextStyle(color: isPro ? const Color(0xFF94A3B8) : const Color(0xFF1E3A8A), height: 1.6, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Nearest Hospitals (Only for General User and Only if Serious)
              if (!isPro && isSerious)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Action Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                    const SizedBox(height: 16),
                    const Text('Based on the AI findings, clinical action is recommended. Here are the nearest available medical centers:', style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5)),
                    const SizedBox(height: 24),
                    // Mock Nearest Hospitals Auto-Listed
                    const Text('Nearest Hospitals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 16),
                    _buildHospitalCard('City General Medical Center', '123 Health Blvd', '1.2 miles away'),
                    const SizedBox(height: 12),
                    _buildHospitalCard('St. Jude Emergency Care', '459 Oak St', '2.8 miles away'),
                  ],
                )
              else if (!isPro && !isSerious)
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text('The analysis appears stable. No immediate hospital actions are currently recommended.', style: TextStyle(color: Color(0xFF059669), fontSize: 14, fontWeight: FontWeight.bold)),
                )
              else
                // Footer for Medical Pro
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text('Priority Routing Enabled', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard(String name, String address, String distance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_hospital, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                      child: const Text('Open 24h', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(distance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
