import 'package:flutter/material.dart';
import 'service_request_screen.dart';

class LandscaperScreen extends StatelessWidget {
  const LandscaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        "title": "Lawn Care",
        "icon": Icons.grass,
        "problems": ["Mowing", "Edging", "Fertilizing", "Weed control"],
      },
      {
        "title": "Tree Service",
        "icon": Icons.park,
        "problems": ["Tree trimming", "Tree removal", "Stump grinding", "Planting"],
      },
      {
        "title": "Garden Design",
        "icon": Icons.yard,
        "problems": ["Landscape design", "Flower beds", "Mulching", "Seasonal planting"],
      },
      {
        "title": "Irrigation",
        "icon": Icons.water,
        "problems": ["Sprinkler install", "Sprinkler repair", "Drip system", "Water management"],
      },
      {
        "title": "Hardscaping",
        "icon": Icons.architecture,
        "problems": ["Patio install", "Walkways", "Retaining walls", "Decking"],
      },
      {
        "title": "Inspection",
        "icon": Icons.search,
        "problems": ["Yard assessment", "Quote request", "Maintenance plan", "Seasonal cleanup"],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Landscaping Services"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What do you need?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select a service type or request an inspection",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        services[index]["icon"] as IconData,
                        color: Colors.teal,
                      ),
                    ),
                    title: Text(
                      services[index]["title"] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${(services[index]["problems"] as List).length} common issues",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Common Problems:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (services[index]["problems"] as List)
                                  .map((problem) => ActionChip(
                                        avatar: const Icon(Icons.build, size: 16, color: Colors.teal),
                                        label: Text(problem),
                                        backgroundColor: Colors.teal.withOpacity(0.1),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ServiceRequestScreen(
                                                category: "Landscaper",
                                                subCategory: services[index]["title"] as String,
                                                problem: problem,
                                              ),
                                            ),
                                          );
                                        },
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceRequestScreen(
                                        category: "Landscaper",
                                        subCategory: services[index]["title"] as String,
                                        problem: "Custom Request",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Describe Your Problem"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}