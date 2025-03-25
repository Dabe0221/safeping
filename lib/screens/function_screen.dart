import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
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
  String? _uploadedImageUrl;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileExtension = pickedFile.path.split('.').last.toLowerCase();
      List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!allowedFormats.contains(fileExtension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid image format! Only JPG, PNG, GIF, and WebP are allowed.')),
        );
        return;
      }

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    if ((_selectedImage == null && _webImage == null) || _emailController.text.isEmpty || _commentsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter email and comments.')),
      );
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('https://autolink.fun/imgs/upload.php'));
    request.fields['email'] = _emailController.text;
    request.fields['comments'] = _commentsController.text;

    if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('image', _webImage!, filename: 'upload.png'));
    } else if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      setState(() {
        _uploadedImageUrl = 'https://autolink.fun/imgs/$responseBody';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safe Ping"), backgroundColor: const Color(0xFF651FFF)),
      drawer: const DrawerScreen(),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularButton("Reports", Icons.message, () {}),
                _buildCircularButton("Ping Location", Icons.location_on, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()))),
                _buildCircularButton("Select Image", Icons.cloud_upload, _pickImage),
                if (_selectedImage != null || _webImage != null) ...[
                  const SizedBox(height: 10),
                  _buildUploadSection(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: const Text("Upload!!"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        if (_selectedImage != null && !kIsWeb) ...[
          Image.file(_selectedImage!, height: 100, width: 100),
        ],
        if (_webImage != null && kIsWeb) ...[
          Image.memory(_webImage!, height: 100, width: 100),
        ],
        if (_uploadedImageUrl != null) ...[
          Image.network(_uploadedImageUrl!, height: 100, width: 100),
        ],
        TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Enter your email", filled: true, fillColor: Colors.white)),
        const SizedBox(height: 10),
        TextField(controller: _commentsController, decoration: const InputDecoration(labelText: "Enter comments", filled: true, fillColor: Colors.white)),
      ],
    );
  }
}
