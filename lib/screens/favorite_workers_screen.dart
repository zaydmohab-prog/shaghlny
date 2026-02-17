import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FavoriteWorkersScreen extends StatelessWidget {
  const FavoriteWorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          child: const Text(
            "Favorite Workers",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_favorites')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final favoriteIds = List<String>.from(
                (snapshot.data?.data() as Map<String, dynamic>?)?['workers'] ?? []
              );

              if (favoriteIds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No favorite workers yet",
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Heart workers to add them here",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(FieldPath.documentId, whereIn: favoriteIds.take(10).toList())
                    .get(),
                builder: (context, workersSnapshot) {
                  if (!workersSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final workers = workersSnapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      final worker = workers[index].data() as Map<String, dynamic>;
                      final rating = (worker["rating"] ?? 0).toDouble();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                            child: const Icon(Icons.person, color: Color(0xFF2196F3)),
                          ),
                          title: Text(worker["name"] ?? "Unknown"),
                          subtitle: Row(
                            children: [
                              RatingBarIndicator(
                                rating: rating,
                                itemSize: 16,
                                itemCount: 5,
                                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              ),
                              const SizedBox(width: 4),
                              Text("${worker["totalReviews"] ?? 0} reviews"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavorite(context, userId!, workers[index].id),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _removeFavorite(BuildContext context, String userId, String workerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final List<String> favorites = List<String>.from(data['workers'] ?? []);
      favorites.remove(workerId);
      
      await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(userId)
          .update({'workers': favorites});
    }
  }
}