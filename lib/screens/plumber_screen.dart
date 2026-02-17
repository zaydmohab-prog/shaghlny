import 'package:flutter/material.dart';
import 'service_request_screen.dart';

class PlumberScreen extends StatelessWidget {
  const PlumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        "title": "Leak Repair",
        "icon": Icons.water_drop,
        "problems": ["Pipe leak", "Faucet drip", "Toilet leak", "Shower leak"],
      },
      {
        "title": "Installation",
        "icon": Icons.handyman,
        "problems": ["New pipes", "Sink install", "Toilet install", "Shower install"],
      },
      {
        "title": "Drainage",
        "icon": Icons.cleaning_services,
        "problems": ["Clogged sink", "Blocked toilet", "Slow drain", "Sewer backup"],
      },
      {
        "title": "Water Heater",
        "icon": Icons.hot_tub,
        "problems": ["No hot water", "Strange noise", "Water smell", "Tank leak"],
      },
      {
        "title": "Emergency",
        "icon": Icons.emergency,
        "problems": ["Burst pipe", "Major leak", "Flooding", "No water"],
      },
      {
        "title": "Inspection",
        "icon": Icons.search,
        "problems": ["Leak detection", "Pipe inspection", "Pressure test", "Quote request"],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plumbing Services"),
        backgroundColor: Colors.blue,
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
                colors: [Colors.blue, Colors.blueAccent],
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        services[index]["icon"] as IconData,
                        color: Colors.blue,
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
                                        avatar: const Icon(Icons.build, size: 16, color: Colors.blue),
                                        label: Text(problem),
                                        backgroundColor: Colors.blue.withOpacity(0.1),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ServiceRequestScreen(
                                                category: "Plumber",
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
                                        category: "Plumber",
                                        subCategory: services[index]["title"] as String,
                                        problem: "Custom Request",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Describe Your Problem"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
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