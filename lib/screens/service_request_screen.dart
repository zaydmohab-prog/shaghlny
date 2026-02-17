import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workers_list_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String category;
  final String subCategory;
  final String problem;

  const ServiceRequestScreen({
    super.key,
    required this.category,
    required this.subCategory,
    required this.problem,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isUrgent = false;
  bool _isLoading = false;
  final _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Service"),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subCategory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.problem,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            const Text(
              "Describe the problem in detail:",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Describe exactly what's wrong...",
                hintStyle: TextStyle(color: Colors.grey[400]),
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
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              "Your Location:",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Enter your address or landmark",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2196F3)),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: SwitchListTile(
                title: const Text(
                  "Urgent Request",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                subtitle: const Text(
                  "Get faster response (may cost extra)",
                  style: TextStyle(fontSize: 13),
                ),
                value: _isUrgent,
                activeColor: Colors.orange,
                activeTrackColor: Colors.orange.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value;
                  });
                },
              ),
            ),
            
                          const SizedBox(height: 24),
              
              const Text(
                "Your Budget (Optional):",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your budget in USD",
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2196F3)),
                  prefixText: "\$ ",
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
                ),
              ),
              
              const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF2196F3).withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Find Available Workers",
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Future<void> _submitRequest() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your location"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Not logged in");

      final requestRef = await FirebaseFirestore.instance.collection("service_requests").add({
        "clientId": currentUser.uid,
        "category": widget.category,
        "subCategory": widget.subCategory,
        "problem": widget.problem,
        "description": _descriptionController.text,
        "location": _locationController.text,
        "isUrgent": _isUrgent,
        "clientBudget": _budgetController.text.isEmpty ? null : double.tryParse(_budgetController.text),
        "proposedPrice": null,
        "finalPrice": null,
        "status": "pending",
        "workerId": null,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkersListScreen(
            category: widget.category,
            requestId: requestRef.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

        setState(() => _isLoading = false);
  }
}