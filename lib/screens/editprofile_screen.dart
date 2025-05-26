import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _profileImage = "";
  String _userId = "";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");
    if (userId == null || userId.isEmpty) {
      _showMessage("User ID missing. Please log in again.");
      return;
    }
    _userId = userId;
    _fetchUserData(userId);
  }

  Future<void> _fetchUserData(String userId) async {
    if (!await _isConnected()) {
      _showMessage("No internet connection.");
      return;
    }

    final url = Uri.parse("https://srv1319-files.hstgr.io/3eed17af6d1cac21/files/public_html/api/get_users.php?id=$userId");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse["status"] == "success") {
          setState(() {
            _nameController.text = jsonResponse["user"]["first_name"] ?? "";
            _emailController.text = jsonResponse["user"]["email"] ?? "";
            _contactController.text = jsonResponse["user"]["contact_number"] ?? "";
            _addressController.text = jsonResponse["user"]["address"] ?? "";
          });
        } else {
          _showMessage("Error: ${jsonResponse['message']}");
        }
      } else {
        _showMessage("Failed to load user data.");
      }
    } on SocketException {
      _showMessage("Unable to reach server. Please check your internet.");
    } on TimeoutException {
      _showMessage("Request timed out. Try again.");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image.path;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!await _isConnected()) {
      _showMessage("No internet connection.");
      return;
    }

    if (_userId.isEmpty) {
      _showMessage("User ID is missing. Please log in again.");
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _addressController.text.isEmpty) {
      _showMessage("All fields are required.");
      return;
    }

    final body = jsonEncode({
      "id": _userId,
      "first_name": _nameController.text,
      "email": _emailController.text,
      "contact_number": _contactController.text,
      "address": _addressController.text,
      "profile_image": _profileImage,
    });

    try {
      setState(() => _isSaving = true);

      final response = await http.post(
        Uri.parse("https://autolink.fun/api/account_edit.php"),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse["status"] == "success") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("user_first_name", _nameController.text);
          await prefs.setString("user_email", _emailController.text);
          await prefs.setString("user_contact", _contactController.text);
          await prefs.setString("user_address", _addressController.text);
          await prefs.setString("profile_image", _profileImage);

          _showMessage("Profile updated successfully!", success: true);
          Navigator.pop(context);
        } else {
          _showMessage("Update failed: ${jsonResponse['message']}");
        }
      } else {
        _showMessage("Server error. Please try again later.");
      }
    } on SocketException {
      _showMessage("Unable to reach server.");
    } on TimeoutException {
      _showMessage("Request timed out.");
    } catch (e) {
      _showMessage("Network error. Please try again.");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<bool> _isConnected() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: success ? Colors.green : Colors.red)),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF904E95), Color(0xFFe96443)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage.isNotEmpty ? FileImage(File(_profileImage)) : null,
                        child: _profileImage.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.black) : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, "Name", Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, "Email", Icons.email),
                    const SizedBox(height: 10),
                    _buildTextField(_contactController, "Contact Number", Icons.phone),
                    const SizedBox(height: 10),
                    _buildTextField(_addressController, "Address", Icons.home),
                    const SizedBox(height: 20),
                    _isSaving
                        ? const CircularProgressIndicator()
                        : _roundedButton(Icons.save, "Save Changes", _saveUserData),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _roundedButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}
