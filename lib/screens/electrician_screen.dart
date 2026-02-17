import 'package:flutter/material.dart';
import 'service_request_screen.dart';

class ElectricianScreen extends StatelessWidget {
  const ElectricianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        "title": "Wiring",
        "icon": Icons.electrical_services,
        "problems": ["New wiring", "Rewiring", "Short circuit", "Wire replacement"],
      },
      {
        "title": "Installation",
        "icon": Icons.lightbulb,
        "problems": ["Light fixtures", "Ceiling fans", "Outlets", "Switches"],
      },
      {
        "title": "Repairs",
        "icon": Icons.build,
        "problems": ["Power outage", "Flickering lights", "Dead outlets", "Breaker issues"],
      },
      {
        "title": "Appliances",
        "icon": Icons.kitchen,
        "problems": ["AC connection", "Oven wiring", "Stove install", "Dishwasher"],
      },
      {
        "title": "Safety",
        "icon": Icons.security,
        "problems": ["Grounding", "Surge protection", "Safety inspection", "Code compliance"],
      },
      {
        "title": "Inspection",
        "icon": Icons.search,
        "problems": ["Safety check", "Load calculation", "Code inspection", "Quote request"],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Electrical Services"),
        backgroundColor: Colors.orange,
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
                colors: [Colors.orange, Colors.deepOrange],
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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        services[index]["icon"] as IconData,
                        color: Colors.orange,
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
                                        avatar: const Icon(Icons.build, size: 16, color: Colors.orange),
                                        label: Text(problem),
                                        backgroundColor: Colors.orange.withOpacity(0.1),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ServiceRequestScreen(
                                                category: "Electrician",
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
                                        category: "Electrician",
                                        subCategory: services[index]["title"] as String,
                                        problem: "Custom Request",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Describe Your Problem"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
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