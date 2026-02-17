import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final clientId = auth.firebaseUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.work), text: 'Active'),
              Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveBookingsTab(clientId),
            _buildCompletedBookingsTab(context, clientId),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsTab(String? clientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('clientId', isEqualTo: clientId)
          .where('status', whereIn: ['pending', 'waiting_worker', 'accepted', 'negotiating'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var requests = snapshot.data?.docs ?? [];

        requests.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active bookings', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
            final status = request['status'] ?? 'pending';

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
                            request['subCategory'] ?? request['category'] ?? 'Service',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildStatusChip(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Problem: ${request['problem'] ?? 'N/A'}'),
                    if (request['clientBudget'] != null)
                      Text('Budget: \$${request['clientBudget']}', 
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (request['workerId'] != null)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(request['workerId'])
                            .get(),
                        builder: (context, workerSnapshot) {
                          if (!workerSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final worker = workerSnapshot.data!.data() as Map<String, dynamic>?;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: Color(0xFF2196F3)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Assigned Worker:', 
                                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(worker?['name'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _buildCompletedBookingsTab(BuildContext context, String? clientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var requests = snapshot.data?.docs ?? [];

        requests.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['completedAt'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['completedAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No completed bookings yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
            final workerId = request['workerId'] as String?;
            final hasReview = request['review'] != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.green.withOpacity(0.05),
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
                            request['subCategory'] ?? request['category'] ?? 'Service',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Chip(
                          label: Text('COMPLETED', style: TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Problem: ${request['problem'] ?? 'N/A'}'),
                    Text('Final Price: \$${request['finalPrice'] ?? 0}', 
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    if (workerId != null)
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(workerId)
                            .get(),
                        builder: (context, workerSnapshot) {
                          if (!workerSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final worker = workerSnapshot.data!.data() as Map<String, dynamic>?;
                          
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF2196F3),
                                      child: Text(
                                        (worker?['name'] ?? 'W')[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            worker?['name'] ?? 'Unknown Worker',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            worker?['field'] ?? 'Service Provider',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                if (hasReview) ...[
                                  const Text('Your Review:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: (request['review']['rating'] ?? 0).toDouble(),
                                        itemBuilder: (context, index) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${request['review']['rating']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showReviewDialog(context, requestId, workerId, worker?['name'] ?? 'Worker'),
                                      icon: const Icon(Icons.star),
                                      label: const Text('Rate Worker'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
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

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'PENDING';
        break;
      case 'waiting_worker':
        color = Colors.blue;
        label = 'WAITING';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'ACTIVE';
        break;
      case 'negotiating':
        color = Colors.purple;
        label = 'NEGOTIATING';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
    );
  }

  void _showReviewDialog(BuildContext context, String requestId, String workerId, String workerName) {
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate $workerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was the service?', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${rating.toStringAsFixed(1)} stars',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submitReview(context, requestId, workerId, rating),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(BuildContext context, String requestId, String workerId, double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('service_requests')
          .doc(requestId)
          .update({
        'review': {
          'rating': rating,
          'createdAt': FieldValue.serverTimestamp(),
        },
      });

      final workerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(workerId)
          .get();
      
      final workerData = workerDoc.data() as Map<String, dynamic>?;
      final currentRating = (workerData?['rating'] ?? 0).toDouble();
      final totalReviews = workerData?['totalReviews'] ?? 0;

      final newTotalReviews = totalReviews + 1;
      final newRating = ((currentRating * totalReviews) + rating) / newTotalReviews;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(workerId)
          .update({
        'rating': newRating,
        'totalReviews': newTotalReviews,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted! Thank you.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}