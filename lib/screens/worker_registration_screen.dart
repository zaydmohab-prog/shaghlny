import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'worker_dashboard.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() => _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedCategory = "Plumber";
  File? _idImage;
  String? _base64Image;
  bool _isLoading = false;

  final List<String> _categories = [
    "Plumber",
    "Electrician",
    "Cleaner",
    "Carpenter",
    "Technician",
    "Landscaper",
  ];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 50,
    );
    if (picked != null) {
      setState(() {
        _idImage = File(picked.path);
      });
      
      final bytes = await _idImage!.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take a photo of your ID")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "role": "worker",
        "field": _selectedCategory,
        "idNumber": _idNumberController.text.trim(),
        "idImageBase64": _base64Image,
        "idVerified": false,
        "rating": 0.0,
        "totalReviews": 0,
        "totalJobs": 0,
        "earnings": 0.0,
        "monthlyEarnings": 0.0,
        "isBanned": false,
        "isGuest": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful! Welcome to SHAGHLNY."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorkerDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == 'weak-password') {
        message = "Password is too weak";
      } else if (e.code == 'email-already-in-use') {
        message = "Email already registered";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Registration"),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Your Worker Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join our network of service professionals",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle("Personal Information"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration("Full Name", Icons.person),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.contains("@") ? null : "Enter valid email",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration("Password", Icons.lock),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration("Phone Number", Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle("ID Verification"),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idNumberController,
                decoration: _buildInputDecoration("National ID Number", Icons.badge),
                validator: (value) => value!.isEmpty ? "Enter ID number" : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _idImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_idImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to take ID photo",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle("Service Category"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Register as Worker",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
    );
  }
}