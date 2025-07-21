import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PtdLayout extends StatelessWidget {
  final Widget child;
  const PtdLayout({super.key, required this.child});

  static final List<String> _routes = [
    RoutePaths.ptd.stocks,
    RoutePaths.ptd.option2,
    RoutePaths.ptd.option3,
  ];

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        currentIndex = i;
      }
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Stocks'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Option 2'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Option 3'),
        ],
      ),
    );
  }
}
