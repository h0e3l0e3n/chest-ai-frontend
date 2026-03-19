import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // We mock a database by storing a list of users in SharedPreferences
  Future<int> registerUser(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersList = prefs.getStringList('mock_users_db') ?? [];
      
      for (String userStr in usersList) {
        Map<String, dynamic> user = jsonDecode(userStr);
        if (user['email'] == email) return -1; // Duplicate
      }
      
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name,
        'email': email,
        'password': password,
        'created_at': DateTime.now().toIso8601String()
      };
      
      usersList.add(jsonEncode(newUser));
      await prefs.setStringList('mock_users_db', usersList);
      return newUser['id'] as int;
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersList = prefs.getStringList('mock_users_db') ?? [];
      
      for (String userStr in usersList) {
        Map<String, dynamic> user = jsonDecode(userStr);
        if (user['email'] == email && user['password'] == password) {
          return user;
        }
      }
    } catch (e) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> usersList = prefs.getStringList('mock_users_db') ?? [];
      return usersList.map((str) => Map<String, dynamic>.from(jsonDecode(str))).toList();
    } catch(e) {
      print('Database Error: $e');
      return [];
    }
  }
}


