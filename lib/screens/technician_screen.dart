import 'package:flutter/material.dart';
import 'service_request_screen.dart';

class TechnicianScreen extends StatelessWidget {
  const TechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        "title": "TV & Display",
        "icon": Icons.tv,
        "problems": ["Screen issues", "No power", "Sound problems", "Connectivity"],
      },
      {
        "title": "Kitchen Appliances",
        "icon": Icons.microwave,
        "problems": ["Microwave repair", "Oven issues", "Refrigerator", "Dishwasher"],
      },
      {
        "title": "Laundry",
        "icon": Icons.local_laundry_service,
        "problems": ["Washing machine", "Dryer repair", "Leaking", "Not spinning"],
      },
      {
        "title": "AC & Cooling",
        "icon": Icons.ac_unit,
        "problems": ["Not cooling", "Water leakage", "Strange noise", "Bad smell"],
      },
      {
        "title": "Computers",
        "icon": Icons.computer,
        "problems": ["Won't start", "Slow performance", "Virus removal", "Hardware upgrade"],
      },
      {
        "title": "Inspection",
        "icon": Icons.search,
        "problems": ["Diagnosis", "Maintenance", "Safety check", "Quote request"],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Technician Services"),
        backgroundColor: Colors.purple,
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
                colors: [Colors.purple, Colors.deepPurple],
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
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        services[index]["icon"] as IconData,
                        color: Colors.purple,
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
                                        avatar: const Icon(Icons.build, size: 16, color: Colors.purple),
                                        label: Text(problem),
                                        backgroundColor: Colors.purple.withOpacity(0.1),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ServiceRequestScreen(
                                                category: "Technician",
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
                                        category: "Technician",
                                        subCategory: services[index]["title"] as String,
                                        problem: "Custom Request",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Describe Your Problem"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
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