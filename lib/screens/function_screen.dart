import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import 'drawer_screen.dart';
import 'map_screen.dart';

class FunctionScreen extends StatefulWidget {
  const FunctionScreen({super.key});

  @override
  _FunctionScreenState createState() => _FunctionScreenState();
}

class _FunctionScreenState extends State<FunctionScreen> {
  File? _selectedImage;
  Uint8List? _webImage;
  final TextEditingController _commentsController = TextEditingController();
  bool _isUploading = false;
  String? userId;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString("user_id");
      userEmail = prefs.getString("user_email");
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  void _validateAndProceed() {
    if ((_selectedImage == null && _webImage == null) || _commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter a comment!')),
      );
      return;
    }

    _showConfirmationDialog();
  }

  Future<void> _uploadPost() async {
    if (userId == null || userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please login again!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    Position? position;
    try {
      position = await _getCurrentLocation();
    } catch (e) {
      debugPrint("Location Error: $e");
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://autolink.fun/api/upload_loc.php"),
      );

      request.fields["user_id"] = userId!;
      request.fields["email"] = userEmail!;
      request.fields["comments"] = _commentsController.text.trim();

      if (position != null) {
        request.fields["latitude"] = position.latitude.toString();
        request.fields["longitude"] = position.longitude.toString();
      }

      if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImage!,
          filename: "upload.png",
        ));
      } else if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (jsonResponse["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error, please try again!")),
      );
    }

    setState(() => _isUploading = false);
  }

  Future<Position?> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Upload"),
        content: const Text("Do you want to upload this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadPost();
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safe Ping"), backgroundColor: const Color(0xFF651FFF)),
      drawer: const DrawerScreen(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF904E95), Color(0xFFe96443)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        _buildImageHolder(),
                        const SizedBox(height: 20),
                        _buildCommentBox(),
                      ],
                    ),
                  ),
                ),
                _isUploading
                    ? const CircularProgressIndicator()
                    : _buildTagLocationButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageHolder() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: _selectedImage != null && !kIsWeb
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : _webImage != null && kIsWeb
            ? Image.memory(_webImage!, fit: BoxFit.cover)
            : const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey)),
      ),
    );
  }

  Widget _buildCommentBox() {
    return TextField(
      controller: _commentsController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Enter your comment...",
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTagLocationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _validateAndProceed,
        child: const Text("Upload Post", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Take Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
