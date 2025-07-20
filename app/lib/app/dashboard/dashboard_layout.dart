import 'package:app/app.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _selectedIndex = 0;

  final List<String> _tabKeys = ['option1', 'option2', 'option3'];
  final List<String> _routes = [
    routePaths.dashboard.option1.path,
    routePaths.dashboard.option2,
    routePaths.dashboard.option3,
  ];

  final Map<int, String> _tabHistory = {};
  late final VoidCallback _routeListener;

  @override
  void initState() {
    super.initState();
    _routeListener = () {
      final uriString = Routefly.currentUri.path;
      for (int i = 0; i < _tabKeys.length; i++) {
        if (uriString.contains(_tabKeys[i])) {
          _tabHistory[i] = uriString;
        }
      }
    };
    Routefly.listenable.addListener(_routeListener);
  }

  @override
  void dispose() {
    Routefly.listenable.removeListener(_routeListener);
    super.dispose();
  }

  void _onItemTapped(int index) {
    final currentUri = Routefly.currentUri.path;

    if (currentUri.contains(_tabKeys[index])) {
      // Se já navegou para um filho, restaura o último path
      Routefly.navigate(_routes[index]);
      return;
    }

    setState(() {
      _selectedIndex = index;
      // Se já navegou para um filho, restaura o último path, senão navega para root da tab
      final lastPath = _tabHistory[index] ?? _routes[index];
      Routefly.navigate(lastPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uri = Routefly.currentUri;
    final uriString = uri.toString();
    int currentIndex = _selectedIndex;
    for (int i = 0; i < _tabKeys.length; i++) {
      if (uriString.contains(_tabKeys[i])) {
        currentIndex = i;
      }
    }
    return Scaffold(
      body: const RouterOutlet(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Option 1',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Option 2'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Option 3'),
        ],
      ),
    );
  }
}
