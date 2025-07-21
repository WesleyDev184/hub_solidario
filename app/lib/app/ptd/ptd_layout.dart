import 'package:app/core/widgets/background_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../go_router.dart';

class PtdLayout extends StatefulWidget {
  final Widget child;
  const PtdLayout({super.key, required this.child});

  @override
  State<PtdLayout> createState() => _PtdLayoutState();
}

class _PtdLayoutState extends State<PtdLayout> {
  int _selectedIndex = 0;
  final List<String> _tabKeys = ['stocks', 'option2', 'option3'];
  final List<String> _routes = [
    RoutePaths.ptd.stocks,
    RoutePaths.ptd.option2,
    RoutePaths.ptd.option3,
  ];
  final Map<int, String> _tabHistory = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _tabKeys.length; i++) {
      if (location.contains(_tabKeys[i])) {
        _tabHistory[i] = location;
      }
    }
  }

  void _onItemTapped(int index) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains(_tabKeys[index])) {
      // Se já está na tab, restaura o último path salvo
      context.go(_routes[index]);
      return;
    }
    setState(() {
      _selectedIndex = index;
      final lastPath = _tabHistory[index] ?? _routes[index];
      context.go(lastPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = _selectedIndex;
    for (int i = 0; i < _tabKeys.length; i++) {
      if (location.contains(_tabKeys[i])) {
        currentIndex = i;
      }
    }
    return Scaffold(
      body: BackgroundWrapper(child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stocks'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Option 2'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Option 3'),
        ],
      ),
    );
  }
}
