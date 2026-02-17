import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WorkersSearchScreen extends StatefulWidget {
  const WorkersSearchScreen({super.key});

  @override
  State<WorkersSearchScreen> createState() => _WorkersSearchScreenState();
}

class _WorkersSearchScreenState extends State<WorkersSearchScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  List<String> favoriteWorkerIds = [];

  final categories = ["All", "Plumber", "Electrician", "Cleaner", "Carpenter", "Technician", "Landscaper"];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        favoriteWorkerIds = List<String>.from(data['workers'] ?? []);
      });
    }
  }

  Future<void> _toggleFavorite(String workerId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('user_favorites').doc(userId);

    setState(() {
      if (favoriteWorkerIds.contains(workerId)) {
        favoriteWorkerIds.remove(workerId);
      } else {
        favoriteWorkerIds.add(workerId);
      }
    });

    await docRef.set({
      'workers': favoriteWorkerIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search workers...",
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCategory == categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categories[index]),
                        selected: isSelected,
                        selectedColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("role", isEqualTo: "worker")
                .where("isBanned", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var workers = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data["name"] ?? "").toString().toLowerCase();
                final field = (data["field"] ?? "").toString();
                
                final matchesSearch = name.contains(searchQuery.toLowerCase());
                final matchesCategory = selectedCategory == "All" || field == selectedCategory;
                
                return matchesSearch && matchesCategory;
              }).toList();

              if (workers.isEmpty) {
                return const Center(
                  child: Text("No workers found"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index].data() as Map<String, dynamic>;
                  final workerId = workers[index].id;
                  final isFavorite = favoriteWorkerIds.contains(workerId);
                  
                  return WorkerCard(
                    worker: worker,
                    workerId: workerId,
                    isFavorite: isFavorite,
                    onToggleFavorite: () => _toggleFavorite(workerId),
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

class WorkerCard extends StatelessWidget {
  final Map<String, dynamic> worker;
  final String workerId;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.workerId,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final rating = (worker["rating"] ?? 0).toDouble();
    final reviews = worker["totalReviews"] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF2196F3)),
        ),
        title: Text(worker["name"] ?? "Unknown"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker["field"] ?? "General"),
            Row(
              children: [
                RatingBarIndicator(
                  rating: rating,
                  itemSize: 16,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                ),
                const SizedBox(width: 4),
                Text("($reviews)", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}