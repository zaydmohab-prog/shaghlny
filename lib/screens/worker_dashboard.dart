import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OrdersTab(),   // <-- First tab
      const HistoryTab(),  // <-- Second tab
      const ProfileTab(),  // <-- THIRD TAB (PROFILE)
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 3,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(17),
            topRight: Radius.circular(17),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",  // <-- THIS IS THE PROFILE TAB
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ORDERS TAB ====================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final worker = auth.userModel;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome, ${worker?.name ?? 'Worker'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Category: ${worker?.field ?? 'Not set'}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (worker?.idVerified ?? false) 
                              ? Colors.green 
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (worker?.idVerified ?? false) ? "Verified" : "Pending",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TabBar(
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      labelColor: Color(0xFF2196F3),
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(text: "New", icon: Icon(Icons.new_releases)),
                        Tab(text: "For You", icon: Icon(Icons.person_add)),
                        Tab(text: "Active", icon: Icon(Icons.work)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNewRequestsTab(context, worker?.field),
                _buildForYouTab(context, auth.firebaseUser?.uid),
                _buildActiveTab(context, auth.firebaseUser?.uid),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequestsTab(BuildContext context, String? category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("service_requests")
          .where("category", isEqualTo: category)
          .where("status", isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("No new requests", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final requestId = requests[index].id;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            request["subCategory"] ?? "Service",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (request["isUrgent"] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF2196F3), size: 20),
                              SizedBox(width: 8),
                              Text("Client Location:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(request["location"] ?? "Not specified", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Problem: ${request["problem"] ?? "N/A"}"),
                    if (request["clientBudget"] != null)
                      Text("Budget: \$${request["clientBudget"]}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _declineRequest(context, requestId),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text("Decline"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _acceptRequest(context, requestId),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3)),
                            child: const Text("Accept"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForYouTab(BuildContext context, String? workerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("service_requests")
          .where("workerId", isEqualTo: workerId)
          .where("status", isEqualTo: "waiting_worker")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("No invitations yet", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text("Clients will invite you directly", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final requestId = requests[index].id;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.orange.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Client chose you!", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Text(request["subCategory"] ?? "Service", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF2196F3)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(request["location"] ?? "Not specified")),
                        ],
                      ),
                    ),
                    if (request["clientBudget"] != null)
                      Text("Budget: \$${request["clientBudget"]}", style: const TextStyle(color: Colors.green)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _declineInvitation(context, requestId),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text("Decline"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _acceptInvitation(context, requestId),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("Accept Job"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveTab(BuildContext context, String? workerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("service_requests")
          .where("workerId", isEqualTo: workerId)
          .where("status", isEqualTo: "accepted")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("No active jobs", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final requestId = requests[index].id;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.green.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Active Job", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Text(request["subCategory"] ?? "Service", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF2196F3)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(request["location"] ?? "Not specified")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _markComplete(context, requestId, request),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Mark as Completed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptRequest(BuildContext context, String requestId) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(requestId)
          .update({
        "workerId": auth.firebaseUser?.uid,
        "status": "accepted",
        "acceptedAt": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job accepted!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _declineRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(requestId)
          .update({
        "declinedBy": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job declined")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _acceptInvitation(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(requestId)
          .update({
        "status": "accepted",
        "workerAcceptedAt": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You accepted the job!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _declineInvitation(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(requestId)
          .update({
        "status": "pending",
        "workerId": null,
        "declinedBy": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invitation declined")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _markComplete(BuildContext context, String requestId, Map<String, dynamic> request) async {
    final priceController = TextEditingController(
      text: request["proposedPrice"]?.toString() ?? request["clientBudget"]?.toString() ?? "",
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mark Job as Complete?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter final price:"),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Final Price (USD)",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Complete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final finalPrice = double.tryParse(priceController.text) ?? 0;

    try {
      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(requestId)
          .update({
        "status": "completed",
        "finalPrice": finalPrice,
        "completedAt": FieldValue.serverTimestamp(),
      });

      final workerId = FirebaseAuth.instance.currentUser?.uid;
      if (workerId != null) {
        await FirebaseFirestore.instance.collection("users").doc(workerId).update({
          "earnings": FieldValue.increment(finalPrice),
          "monthlyEarnings": FieldValue.increment(finalPrice),
          "totalJobs": FieldValue.increment(1),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job completed! Payment recorded."), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

// ==================== HISTORY TAB ====================
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final workerId = auth.firebaseUser?.uid;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          child: const SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Service History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Your completed jobs",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("service_requests")
                .where("workerId", isEqualTo: workerId)
                .where("status", isEqualTo: "completed")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final jobs = snapshot.data!.docs;

              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No completed jobs yet",
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index].data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(job["subCategory"] ?? "Service"),
                      subtitle: Text(job["problem"] ?? "N/A"),
                      trailing: Text(
                        "\$${job["finalPrice"] ?? 0}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==================== PROFILE TAB (THIS IS IT!) ====================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final worker = auth.userModel;

    return SingleChildScrollView(
      child: Column(
        children: [
          // REAL-TIME HEADER WITH RATING
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(auth.firebaseUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final liveData = snapshot.data!.data() as Map<String, dynamic>?;
              final liveRating = (liveData?["rating"] ?? 0).toDouble();
              final liveReviews = liveData?["totalReviews"] ?? 0;
              final liveEarnings = (liveData?["earnings"] ?? 0).toDouble();
              final liveMonthly = (liveData?["monthlyEarnings"] ?? 0).toDouble();
              final liveJobs = liveData?["totalJobs"] ?? 0;

              return Column(
                children: [
                  // Header with live rating
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
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            worker?.name ?? "Worker Name",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            worker?.field ?? "Category",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // LIVE RATING STARS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBarIndicator(
                                rating: liveRating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${liveReviews})",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            liveRating > 0 ? "${liveRating.toStringAsFixed(1)} / 5.0" : "No reviews yet",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Stats cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Total Earnings",
                            "\$${liveEarnings.toStringAsFixed(2)}",
                            Icons.attach_money,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "This Month",
                            "\$${liveMonthly.toStringAsFixed(2)}",
                            Icons.calendar_today,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatCard(
                      "Total Jobs",
                      "$liveJobs",
                      Icons.work,
                      Colors.blue,
                      fullWidth: true,
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Leaderboard
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("role", isEqualTo: "worker")
                      .where("field", isEqualTo: worker?.field)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final workers = snapshot.data!.docs;
                    workers.sort((a, b) {
                      final ratingA = (a.data() as Map<String, dynamic>)["rating"] ?? 0;
                      final ratingB = (b.data() as Map<String, dynamic>)["rating"] ?? 0;
                      return ratingB.compareTo(ratingA);
                    });

                    if (workers.isEmpty) {
                      return const Text("No workers found");
                    }

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
                        children: workers.take(5).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final workerData = entry.value.data() as Map<String, dynamic>;
                          final isCurrentUser = entry.value.id == auth.firebaseUser?.uid;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: index < 3 
                                  ? [Colors.amber, Colors.grey, Colors.orange][index].withOpacity(0.2)
                                  : Colors.grey[200],
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: index < 3 
                                      ? [Colors.amber, Colors.grey, Colors.orange][index]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                            title: Text(
                              workerData["name"] ?? "Unknown",
                              style: TextStyle(
                                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text("${workerData["totalJobs"] ?? 0} jobs"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "${(workerData["rating"] ?? 0).toStringAsFixed(1)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            tileColor: isCurrentUser ? Colors.blue.withOpacity(0.05) : null,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(context, auth),
                icon: const Icon(Icons.logout),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthService auth) {
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