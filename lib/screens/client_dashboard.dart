import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

// Import all category screens
import 'plumber_screen.dart';
import 'electrician_screen.dart';
import 'cleaner_screen.dart';
import 'carpenter_screen.dart';
import 'technician_screen.dart';
import 'landscaper_screen.dart';

// Import tab screens
import 'workers_search_screen.dart';
import 'bookings_screen.dart';
import 'favorite_workers_screen.dart';
import 'account_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    WorkersSearchScreen(),
    BookingScreen(),
    FavoriteWorkersScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF2196F3),
              width: 4,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2196F3),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              height: 1.5,
            ),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            iconSize: 26,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home, size: 28),
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.search_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.search, size: 28),
                ),
                label: "Workers",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.calendar_today, size: 28),
                ),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.favorite_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.favorite, size: 28),
                ),
                label: "Favorites",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person, size: 28),
                ),
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        "title": "Plumber",
        "icon": Icons.plumbing,
        "color": Colors.blue,
        "description": "Fix leaks, install pipes, repair toilets, and all water system services",
        "screen": const PlumberScreen(),
      },
      {
        "title": "Electrician",
        "icon": Icons.electrical_services,
        "color": Colors.orange,
        "description": "Wiring, installations, repairs, and electrical safety inspections",
        "screen": const ElectricianScreen(),
      },
      {
        "title": "Cleaner",
        "icon": Icons.cleaning_services,
        "color": Colors.green,
        "description": "Home cleaning, deep cleaning, office cleaning, and sanitization",
        "screen": const CleanerScreen(),
      },
      {
        "title": "Carpenter",
        "icon": Icons.chair,
        "color": Colors.brown,
        "description": "Furniture repair, custom woodwork, door installations, and fixes",
        "screen": const CarpenterScreen(),
      },
      {
        "title": "Technician",
        "icon": Icons.handyman,
        "color": Colors.purple,
        "description": "TV, appliances, electronics repair and technical troubleshooting",
        "screen": const TechnicianScreen(),
      },
      {
        "title": "Landscaper",
        "icon": Icons.yard,
        "color": Colors.teal,
        "description": "Garden maintenance, lawn care, tree trimming, and outdoor design",
        "screen": const LandscaperScreen(),
      },
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What service do you need?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a category to request a service",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => categories[index]["screen"] as Widget,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (categories[index]["color"] as Color).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (categories[index]["color"] as Color).withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: (categories[index]["color"] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categories[index]["icon"] as IconData,
                            size: 45,
                            color: categories[index]["color"] as Color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          categories[index]["title"] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            categories[index]["description"] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}