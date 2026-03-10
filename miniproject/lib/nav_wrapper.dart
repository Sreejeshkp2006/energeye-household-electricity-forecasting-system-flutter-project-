import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/services_screen.dart';
import 'screens/monthly_prediction_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardScreen(),
      const ServicesScreen(),
      const MonthlyPredictionScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Services',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_graph_rounded),
                  label: 'Prediction',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.teal.shade400,
              unselectedItemColor: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5) ??
                  Colors.blueGrey.shade200,
              selectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              type: BottomNavigationBarType.fixed,
            ),
          ),
        ),
      ),
    );
  }
}
