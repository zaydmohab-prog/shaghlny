import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final locations = List<String>.from(userData['locations'] ?? []);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header with user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? "User Name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['email'] ?? "user@email.com",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userData['role'] == "worker" ? "Service Provider" : "Client Account",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Account"),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildListTile(
                        icon: Icons.person_outline,
                        title: "Edit Profile",
                        subtitle: "Change your name",
                        onTap: () => _showEditProfileDialog(context, userId!, userData['name'] ?? ""),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.location_on_outlined,
                        title: "My Locations",
                        subtitle: "${locations.length} saved address${locations.length != 1 ? 'es' : ''}",
                        onTap: () => _showLocationsDialog(context, userId!, locations),
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader("Support"),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildListTile(
                        icon: Icons.info_outline,
                        title: "About SHAGHLNY",
                        subtitle: "Version 1.0.0",
                        onTap: () => _showAboutDialog(context),
                      ),
                    ]),

                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context),
                        icon: const Icon(Icons.logout, size: 24),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey[200],
    );
  }

  void _showEditProfileDialog(BuildContext context, String userId, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Your Name",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name cannot be empty")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'name': newName});

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Name updated!"), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showLocationsDialog(BuildContext context, String userId, List<String> locations) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("My Locations"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locations.isEmpty)
                  const Text("No saved locations yet")
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Color(0xFF2196F3)),
                          title: Text(locations[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final updatedLocations = List<String>.from(locations);
                              updatedLocations.removeAt(index);
                              
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .update({'locations': updatedLocations});
                              
                              Navigator.pop(context);
                              _showLocationsDialog(context, userId, updatedLocations);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _showAddLocationDialog(context, userId, locations),
              child: const Text("Add Location"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showAddLocationDialog(BuildContext context, String userId, List<String> existingLocations) {
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Location"),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: "Address or Landmark",
              prefixIcon: Icon(Icons.location_on),
              hintText: "e.g., 123 Main St, Riyadh",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newLocation = locationController.text.trim();
                if (newLocation.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Location cannot be empty")),
                  );
                  return;
                }

                final updatedLocations = List<String>.from(existingLocations);
                updatedLocations.add(newLocation);

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'locations': updatedLocations});

                  Navigator.pop(context);
                  Navigator.pop(context);
                  _showLocationsDialog(context, userId, updatedLocations);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Location added!"), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About SHAGHLNY"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_repair_service, size: 64, color: Color(0xFF2196F3)),
              SizedBox(height: 16),
              Text(
                "SHAGHLNY",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text("Version 1.0.0"),
              SizedBox(height: 16),
              Text(
                "Your trusted service marketplace connecting clients with skilled workers.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.logout();
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}